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
//  DIMRSAPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMSecKeyHelper.h"
#import "DIMRSAPublicKey.h"

#import "DIMRSAPrivateKey.h"

extern NSData *NSDataFromSecKeyRef(SecKeyRef keyRef);
extern NSString *NSStringFromKeyContent(NSString *content, NSString *tag);

@interface DIMRSAPrivateKey () {
    
    SecKeyRef _privateKeyRef;
    
    id<MKPublicKey> _pubKey;
}

@property (readonly, nonatomic) NSUInteger keySize;

@property (strong, nonatomic, nullable) NSData *keyData;

@property (nonatomic) SecKeyRef privateKeyRef;

@end

@implementation DIMRSAPrivateKey

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        // lazy load
        _keyData = nil;
        _privateKeyRef = NULL;
        _pubKey = nil;
    }
    
    return self;
}

- (void)dealloc {
    
    // clear key ref
    self.privateKeyRef = NULL;
    
    //[super dealloc];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMRSAPrivateKey *key = [super copyWithZone:zone];
    if (key) {
        key.keyData = _keyData;
        key.privateKeyRef = _privateKeyRef;
        key.publicKey = _pubKey;
    }
    return key;
}

+ (instancetype)newKey {
    return [self newKey:(1024 / 8)]; // 128
}

+ (instancetype)newKey:(NSUInteger)keySize {
    // 2. prepare parameters
    NSDictionary *params;
    params = @{(id)kSecAttrKeyType      :(id)kSecAttrKeyTypeRSA,
               (id)kSecAttrKeySizeInBits:@(keySize * 8),
               //(id)kSecAttrIsPermanent:@YES,
               };
    // 3. generate
    CFErrorRef error = NULL;
    SecKeyRef keyRef = SecKeyCreateRandomKey((CFDictionaryRef)params,
                                             &error);
    if (error) {
        NSAssert(!keyRef, @"RSA key ref should be empty when failed");
        NSAssert(false, @"RSA failed to generate key: %@", error);
        CFRelease(error);
        error = NULL;
        return nil;
    }
    NSAssert(keyRef, @"RSA private key ref should be set here");
    
    // 4. key to data
    NSData *data = NSDataFromSecKeyRef(keyRef);
    NSString *base64 = MKBase64Encode(data);
    NSString *pem = NSStringFromKeyContent(base64, @"RSA PRIVATE");
    //NSString *pem = [DIMSecKeyHelper serializePrivateKey:keyRef
    //                                           algorithm:MKAsymmetricAlgorithm_RSA];
    //data = [DIMSecKeyHelper privateKeyDataFromContent:pem
    //                                        algorithm:MKAsymmetricAlgorithm_RSA];
    // 5. build key info
    DIMRSAPrivateKey *key = [[DIMRSAPrivateKey alloc] initWithDictionary:@{
        @"algorithm" : MKAsymmetricAlgorithm_RSA,
        @"data"      : pem,
        @"mode"      : @"ECB",
        @"padding"   : @"PKCS1",
        @"digest"    : @"SHA256",
    }];
    key.keyData = data;
    key.privateKeyRef = keyRef;
    return key;
}

// protected
- (NSUInteger)keySize {
    // get from key data
    if (_privateKeyRef || [self objectForKey:@"data"]) {
        size_t bytes = SecKeyGetBlockSize(self.privateKeyRef);
        return bytes * sizeof(uint8_t);
    }
    return [self unsignedIntegerForKey:@"keySize"
                          defaultValue:(1024 / 8)]; // 128
}

// Override
- (NSData *)data {
    NSData *bin = _keyData;
    if (bin) {
        return bin;
    }
    NSString *pem = [self objectForKey:@"data"];
    NSUInteger len = pem.length;
    if (len > 0) {
        // PEM
        bin = [DIMSecKeyHelper privateKeyDataFromContent:pem
                                               algorithm:MKAsymmetricAlgorithm_RSA];
    } else {
        NSAssert(false, @"RSA private key data not found: %@", self);
    }
    _keyData = bin;
    return bin;
}

// protected
- (void)setPrivateKeyRef:(SecKeyRef)privateKeyRef {
    if (_privateKeyRef != privateKeyRef) {
        if (_privateKeyRef) {
            CFRelease(_privateKeyRef);
            _privateKeyRef = NULL;
        }
        if (privateKeyRef) {
            _privateKeyRef = (SecKeyRef)CFRetain(privateKeyRef);
        }
    }
}

// protected
- (SecKeyRef)privateKeyRef {
    SecKeyRef key = _privateKeyRef;
    NSData *data = [self data];
    if (data && !key) {
        key = [DIMSecKeyHelper privateKeyFromData:data
                                        algorithm:MKAsymmetricAlgorithm_RSA];
        _privateKeyRef = key;
    }
    return key;
}

// protected
- (void)setPublicKey:(nullable id<MKPublicKey>)publicKey {
    _pubKey = publicKey;
}

// Override
- (id<MKPublicKey>)publicKey {
    if (!_pubKey) {
        // get public key content from private key
        SecKeyRef publicKeyRef = SecKeyCopyPublicKey(self.privateKeyRef);
        NSString *pem;
        pem = [DIMSecKeyHelper serializePublicKey:publicKeyRef
                                        algorithm:MKAsymmetricAlgorithm_RSA];
        _pubKey = [[DIMRSAPublicKey alloc] initWithDictionary:@{
            @"algorithm" : MKAsymmetricAlgorithm_RSA,
            @"data"      : pem,
            @"mode"      : @"ECB",
            @"padding"   : @"PKCS1",
            @"digest"    : @"SHA256",
        }];
    }
    return _pubKey;
}

// Override
- (NSData *)sign:(NSData *)data {
    NSAssert(self.privateKeyRef != NULL, @"RSA private key cannot be empty");
    NSAssert(data.length > 0, @"RSA data cannot be empty");
    NSData *signature = nil;
    
    CFErrorRef error = NULL;
    SecKeyAlgorithm alg = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
    CFDataRef CT;
    CT = SecKeyCreateSignature(self.privateKeyRef,
                               alg,
                               (CFDataRef)data,
                               &error);
    if (error) {
        NSLog(@"[RSA] failed to sign: %@", error);
        NSAssert(!CT, @"RSA signature should be empty when failed");
        NSAssert(false, @"RSA sign error: %@", error);
        CFRelease(error);
        error = NULL;
    } else {
        NSAssert(CT, @"RSA signature should not be empty");
        signature = (__bridge_transfer NSData *)CT;
    }
    
    NSAssert(signature, @"RSA sign failed");
    return signature;
}

// Override
- (nullable NSData *)decrypt:(NSData *)ciphertext
                      params:(nullable NSDictionary<NSString *, id> *)extra {
    if (ciphertext.length != (self.keySize)) {
        NSLog(@"[RSA] ciphertext length not correct: %lu", ciphertext.length);
        return nil;
    }
    NSData *plaintext = nil;
    
    @try {
        SecKeyRef keyRef = self.privateKeyRef;
        NSAssert(keyRef != NULL, @"RSA private key error");
        
        CFErrorRef error = NULL;
        SecKeyAlgorithm alg = kSecKeyAlgorithmRSAEncryptionPKCS1;
        CFDataRef data;
        data = SecKeyCreateDecryptedData(keyRef,
                                         alg,
                                         (CFDataRef)ciphertext,
                                         &error);
        if (error) {
            NSLog(@"[RSA] failed to decrypt: %@", error);
            NSAssert(!data, @"RSA decrypted data should be empty when failed");
            //NSAssert(false, @"RSA decrypt error: %@", error);
            CFRelease(error);
            error = NULL;
        } else {
            NSAssert(data, @"RSA decrypted data should not be empty");
            plaintext = (__bridge_transfer NSData *)data;
        }
    } @catch (NSException *exception) {
        NSLog(@"[RSA] failed to decrypt: %@", exception);
    } @finally {
        //
    }
    
    //NSAssert(plaintext, @"RSA decrypt failed");
    return plaintext;
}

// Override
- (BOOL)matchEncryptKey:(id<MKEncryptKey>)pKey {
    return DIMCryptoMatchEncryptKey(pKey, self);
}

@end

@implementation DIMRSAPrivateKeyFactory

- (id<MKPrivateKey>)generatePrivateKey {
    return [DIMRSAPrivateKey newKey];
}

- (nullable id<MKPrivateKey>)parsePrivateKey:(NSDictionary *)key { 
    // check 'data'
    if ([key objectForKey:@"data"] == nil) {
        // key.data should not be empty
        NSAssert(false, @"RSA key error: %@", key);
        return nil;
    }
    return [[DIMRSAPrivateKey alloc] initWithDictionary:key];
}

@end
