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
//  DIMRSAPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMSecKeyHelper.h"
#import "DIMRSAPrivateKey.h"

#import "DIMRSAPublicKey.h"

@interface DIMRSAPublicKey () {
    
    SecKeyRef _publicKeyRef;
}

@property (readonly, nonatomic) NSUInteger keySize;

@property (strong, nonatomic, nullable) NSData *keyData;

@property (nonatomic) SecKeyRef publicKeyRef;

@end

@implementation DIMRSAPublicKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        // lazy load
        _keyData = nil;
        _publicKeyRef = NULL;
    }
    
    return self;
}

- (void)dealloc {
    
    // clear key ref
    self.publicKeyRef = NULL;
    
    //[super dealloc];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMRSAPublicKey *key = [super copyWithZone:zone];
    if (key) {
        key.keyData = _keyData;
        key.publicKeyRef = _publicKeyRef;
    }
    return key;
}

// protected
- (NSUInteger)keySize {
    // get from key data
    if (_publicKeyRef || [self objectForKey:@"data"]) {
        size_t bytes = SecKeyGetBlockSize(self.publicKeyRef);
        return bytes * sizeof(uint8_t);
    }
    return [self unsignedIntegerForKey:@"keySize"
                          defaultValue:(1024 / 8)]; // 128
}

// Override
- (NSData *)data {
    NSData *bin = _keyData;
    if (!bin) {
        NSString *pem = [self objectForKey:@"data"];
        bin = [DIMSecKeyHelper publicKeyDataFromContent:pem
                                              algorithm:MKAsymmetricAlgorithm_RSA];
        _keyData = bin;
    }
    return bin;
}

- (void)setPublicKeyRef:(SecKeyRef)publicKeyRef {
    if (_publicKeyRef != publicKeyRef) {
        if (_publicKeyRef) {
            CFRelease(_publicKeyRef);
            _publicKeyRef = NULL;
        }
        if (publicKeyRef) {
            _publicKeyRef = (SecKeyRef)CFRetain(publicKeyRef);
        }
    }
}

- (SecKeyRef)publicKeyRef {
    if (!_publicKeyRef) {
        @try {
            _publicKeyRef = [DIMSecKeyHelper publicKeyFromData:self.data algorithm:MKAsymmetricAlgorithm_RSA];
        } @catch (NSException *exception) {
            NSLog(@"[RSA] public key error: %@", exception);
        } @finally {
            //
        }
    }
    return _publicKeyRef;
}

// Override
- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    NSAssert(data.length > 0, @"[RSA] data cannot be empty");
    if (signature.length != (self.keySize)) {
        NSLog(@"[RSA] signature length not match: %lu", signature.length);
        return NO;
    }
    BOOL OK = NO;
    
    @try {
        SecKeyRef keyRef = self.publicKeyRef;
        NSAssert(keyRef != NULL, @"RSA public key error");
        
        CFErrorRef error = NULL;
        SecKeyAlgorithm alg = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
        OK = SecKeyVerifySignature(keyRef,
                                   alg,
                                   (CFDataRef)data,
                                   (CFDataRef)signature,
                                   &error);
        if (error) {
            NSLog(@"[RSA] failed to verify: %@", error);
            NSAssert(!OK, @"RSA verify error");
            //NSAssert(false, @"RSA verify error: %@", error);
            CFRelease(error);
            error = NULL;
        }
    } @catch (NSException *exception) {
        NSLog(@"[RSA] failed to verify: %@", exception);
    } @finally {
        //
    }
    
    return OK;
}

// Override
- (NSData *)encrypt:(NSData *)plaintext
              extra:(nullable NSMutableDictionary<NSString *, id> *)params {
    NSAssert(plaintext.length > 0, @"[RSA] data cannot be empty");
    NSAssert(plaintext.length <= (self.keySize - 11), @"[RSA] data too long: %lu", plaintext.length);
    NSData *ciphertext = nil;
    
    @try {
        SecKeyRef keyRef = self.publicKeyRef;
        NSAssert(keyRef != NULL, @"RSA public key error");
        
        CFErrorRef error = NULL;
        SecKeyAlgorithm alg = kSecKeyAlgorithmRSAEncryptionPKCS1;
        CFDataRef CT;
        CT = SecKeyCreateEncryptedData(keyRef,
                                       alg,
                                       (CFDataRef)plaintext,
                                       &error);
        if (error) {
            NSLog(@"[RSA] failed to encrypt: %@", error);
            NSAssert(!CT, @"RSA encrypted data should be empty when failed");
            NSAssert(false, @"RSA encrypt error: %@", error);
            CFRelease(error);
            error = NULL;
        } else {
            NSAssert(CT, @"RSA encrypted should not be empty");
            ciphertext = (__bridge_transfer NSData *)CT;
        }
    } @catch (NSException *exception) {
        NSLog(@"[RSA] failed to encrypt: %@", exception);
    } @finally {
        //
    }
    
    NSAssert(ciphertext, @"RSA encrypt failed");
    return ciphertext;
}

@end

@implementation DIMRSAPublicKeyFactory

- (nullable id<MKPublicKey>)parsePublicKey:(NSDictionary *)key {
    // check 'data'
    if ([key objectForKey:@"data"] == nil) {
        // key.data should not be empty
        NSAssert(false, @"RSA key error: %@", key);
        return nil;
    }
    return [[DIMRSAPublicKey alloc] initWithDictionary:key];
}

@end
