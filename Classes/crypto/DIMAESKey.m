// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMAESKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Crypto.h"

#import "DIMAESKey.h"

static inline NSData *random_data(NSUInteger size) {
    unsigned char *buf = malloc(size * sizeof(unsigned char));
    arc4random_buf(buf, size);
    return [[NSData alloc] initWithBytesNoCopy:buf length:size freeWhenDone:YES];
}

@interface DIMAESKey ()

@property (readonly, nonatomic) NSUInteger keySize;
@property (readonly, nonatomic) NSUInteger blockSize;

@property (strong, nonatomic) id<MKTransportableData> tedKey;  // Key Data

@end

@implementation DIMAESKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        // TODO: check algorithm parameters
        // 1. check mode = 'CBC'
        // 2. check padding = 'PKCS7Padding'

        // lazy load
        _tedKey = nil;
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMAESKey *key = [super copyWithZone:zone];
    if (key) {
        key.tedKey = _tedKey;
    }
    return key;
}

+ (instancetype)newKey {
    return [self newKey:kCCKeySizeAES256]; // 32
}

+ (instancetype)newKey:(NSUInteger)keySize {
    NSData *data = random_data(keySize);
    id<MKTransportableData> ted = MKTransportableDataCreate(data, nil);
    DIMAESKey *key = [[DIMAESKey alloc] initWithDictionary:@{
        @"algorithm": MKSymmetricAlgorithm_AES,
        @"data": ted.object,
        //@"mode": @"CBC",
        //@"padding": @"PKCS7",
    }];
    key.tedKey = ted;
    return key;
}

// protected
- (NSUInteger)keySize {
    // TODO: get from key data
    return [self unsignedIntegerForKey:@"keySize"
                          defaultValue:kCCKeySizeAES256]; // 32
}

// protected
- (NSUInteger)blockSize {
    // TODO: get from iv data
    return [self unsignedIntegerForKey:@"blockSize"
                          defaultValue:kCCBlockSizeAES128]; // 16
}

// Override
- (NSData *)data {
    id<MKTransportableData> ted = _tedKey;
    if (!ted) {
        id base64 = [self objectForKey:@"data"];
        if (base64) {
            ted = MKTransportableDataParse(base64);
            NSAssert(ted, @"key data error: %@", base64);
            _tedKey = ted;
        } else {
            NSAssert(false, @"AES key data not found: %@", self);
        }
    }
    return [ted data];
}

// protected
- (nullable NSData *)getInitVector:(NSDictionary *)params {
    // get base64 encoded IV from params
    NSString *base64;
    if (!params) {
        NSAssert(false, @"params must provided to fetch IV for AES");
    } else {
        base64 = [params objectForKey:@"IV"];
        if (!base64) {
            [params objectForKey:@"iv"];
        }
    }
    if (!base64) {
        // compatible with old version
        base64 = [self stringForKey:@"iv" defaultValue:nil];
        if (!base64) {
            base64 = [self stringForKey:@"IV" defaultValue:nil];
        }
    }
    // decode IV data
    id<MKTransportableData> ted = MKTransportableDataParse(base64);
    NSData *ivData = [ted data];
    NSAssert([ivData length] > 0, @"IV data error: %@", base64);
    return ivData;
}

// protected
- (NSData *)zeroInitVector {
    NSUInteger blockSize = [self blockSize];
    return [[NSMutableData alloc] initWithLength:blockSize];
}

// protected
- (NSData *)newInitVector:(NSMutableDictionary *)extra {
    // random IV data
    NSUInteger blockSize = [self blockSize];
    NSData *iv = random_data(blockSize);
    // put encoded IV into extra
    NSAssert(extra, @"extra dict must provided to store IV for AES");
    id<MKTransportableData> ted = MKTransportableDataCreate(iv, nil);
    [extra setObject:ted.object forKey:@"iv"];
    // OK
    return iv;
}

// Override
- (NSData *)encrypt:(NSData *)plaintext
              extra:(nullable NSMutableDictionary<NSString *,id> *)params {
    NSAssert(self.keySize == kCCKeySizeAES256, @"only support AES-256 now");
    // 1. if 'IV' not found in extra params, new a random 'IV'
    NSData *iv = [self getInitVector:params];
    if (!iv) {
        iv = [self newInitVector:params];
    }
    // 2. get cipher key
    NSData *key = [self data];
    // 3. try to encrypt
    NSData *ciphertext = nil;
    @try {
        ciphertext = [plaintext AES256EncryptWithKey:key
                                initializationVector:iv];
    } @catch (NSException *exception) {
        NSLog(@"[AES] failed to encrypt: %@", exception);
    } @finally {
        //
    }
    NSAssert(ciphertext, @"AES encrypt failed");
    return ciphertext;
}

// Override
- (nullable NSData *)decrypt:(NSData *)ciphertext
                      params:(nullable NSDictionary<NSString *,id> *)extra {
    NSAssert(self.keySize == kCCKeySizeAES256, @"only support AES-256 now");
    // 1. if 'IV' not found in extra params, use an empty 'IV'
    NSData *iv = [self getInitVector:extra];
    if (!iv) {
        iv = [self zeroInitVector];
    }
    // 2. get cipher key
    NSData *key = [self data];
    // 3. try to decrypt
    NSData *plaintext = nil;
    @try {
        // AES decrypt algorithm
        plaintext = [ciphertext AES256DecryptWithKey:key
                                initializationVector:iv];
    } @catch (NSException *exception) {
        NSLog(@"[AES] failed to decrypt: %@", exception);
    } @finally {
        //
    }
    //NSAssert(plaintext, @"AES decrypt failed");
    return plaintext;
}

@end

@implementation DIMAESKeyFactory

// Override
- (id<MKSymmetricKey>)generateSymmetricKey {
    return [DIMAESKey newKey];
}

// Override
- (nullable id<MKSymmetricKey>)parseSymmetricKey:(NSDictionary *)key {
    // check 'data'
    if ([key objectForKey:@"data"] == nil) {
        // key.data should not be empty
        NSAssert(false, @"AES key error: %@", key);
        return nil;
    }
    return [[DIMAESKey alloc] initWithDictionary:key];
}

@end
