// license: https://mit-license.org
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  DIMCryptoKeyGeneralFactory.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/DIMCore.h>

#import "DIMCryptoKeyGeneralFactory.h"

@interface DIMCryptoKeyGeneralFactory () {
    
    NSMutableDictionary<NSString *, id<MKSymmetricKeyFactory>> *_symmetricFactories;
    NSMutableDictionary<NSString *, id<MKPrivateKeyFactory>>   *_privateFactories;
    NSMutableDictionary<NSString *, id<MKPublicKeyFactory>>    *_publicFactories;
}

@end

@implementation DIMCryptoKeyGeneralFactory

- (instancetype)init {
    if (self = [super init]) {
        _symmetricFactories = [[NSMutableDictionary alloc] init];
        _privateFactories   = [[NSMutableDictionary alloc] init];
        _publicFactories    = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (nullable NSString *)getKeyAlgorithm:(NSDictionary<NSString *,id> *)key
                          defaultValue:(nullable NSString *)aValue {
    id algo = [key objectForKey:@"algorithm"];
    return MKConvertString(algo, aValue);
}

#pragma mark SymmetricKey

- (void)setSymmetricKeyFactory:(id<MKSymmetricKeyFactory>)factory
                     algorithm:(NSString *)name {
    [_symmetricFactories setObject:factory forKey:name];
}

- (nullable id<MKSymmetricKeyFactory>)getSymmetricKeyFactory:(NSString *)algorithm {
    return [_symmetricFactories objectForKey:algorithm];
}

- (nullable id<MKSymmetricKey>)generateSymmetricKey:(NSString *)algorithm {
    id<MKSymmetricKeyFactory> factory = [self getSymmetricKeyFactory:algorithm];
    NSAssert(factory, @"key algorithm not support: %@", algorithm);
    return [factory generateSymmetricKey];
}

- (nullable id<MKSymmetricKey>)parseSymmetricKey:(nullable id)key {
    if (!key) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKSymmetricKey)]) {
        return key;
    }
    NSDictionary *info = MKGetMap(key);
    if (!info) {
        NSAssert(false, @"symmetric key error: %@", key);
        return nil;
    }
    NSString *algo = [self getKeyAlgorithm:info defaultValue:nil];
    NSAssert([algo length] > 0, @"symmetric key error: %@", key);
    id<MKSymmetricKeyFactory> factory = [self getSymmetricKeyFactory:algo];
    if (!factory) {
        // unknown algorithm, get default key factory
        factory = [self getSymmetricKeyFactory:@"*"];  // unknown
        NSAssert(factory, @"default symmetric key factory not found");
    }
    return [factory parseSymmetricKey:info];
}

#pragma mark PrivateKey

- (void)setPrivateKeyFactory:(id<MKPrivateKeyFactory>)factory
                   algorithm:(NSString *)name {
    [_privateFactories setObject:factory forKey:name];
}

- (nullable id<MKPrivateKeyFactory>)getPrivateKeyFactory:(NSString *)algorithm {
    return [_privateFactories objectForKey:algorithm];
}

- (nullable id<MKPrivateKey>)generatePrivateKey:(NSString *)algorithm {
    id<MKPrivateKeyFactory> factory = [self getPrivateKeyFactory:algorithm];
    NSAssert(factory, @"key algorithm not support: %@", algorithm);
    return [factory generatePrivateKey];
}

- (nullable id<MKPrivateKey>)parsePrivateKey:(nullable id)key { 
    if (!key) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKPrivateKey)]) {
        return key;
    }
    NSDictionary *info = MKGetMap(key);
    if (!info) {
        NSAssert(false, @"private key error: %@", key);
        return nil;
    }
    NSString *algo = [self getKeyAlgorithm:info defaultValue:nil];
    NSAssert([algo length] > 0, @"private key error: %@", key);
    id<MKPrivateKeyFactory> factory = [self getPrivateKeyFactory:algo];
    if (!factory) {
        // unknown algorithm, get default key factory
        factory = [self getPrivateKeyFactory:@"*"];  // unknown
        NSAssert(factory, @"default private key factory not found");
    }
    return [factory parsePrivateKey:info];
}

#pragma mark PublicKey

- (void)setPublicKeyFactory:(id<MKPublicKeyFactory>)factory
                  algorithm:(NSString *)name {
    [_publicFactories setObject:factory forKey:name];
}

- (nullable id<MKPublicKeyFactory>)getPublicKeyFactory:(NSString *)algorithm {
    return [_publicFactories objectForKey:algorithm];
}

- (nullable id<MKPublicKey>)parsePublicKey:(nullable id)key { 
    if (!key) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKPublicKey)]) {
        return key;
    }
    NSDictionary *info = MKGetMap(key);
    if (!info) {
        NSAssert(false, @"public key error: %@", key);
        return nil;
    }
    NSString *algo = [self getKeyAlgorithm:info defaultValue:nil];
    NSAssert([algo length] > 0, @"public key error: %@", key);
    id<MKPublicKeyFactory> factory = [self getPublicKeyFactory:algo];
    if (!factory) {
        // unknown algorithm, get default key factory
        factory = [self getPublicKeyFactory:@"*"];  // unknown
        NSAssert(factory, @"default public key factory not found");
    }
    return [factory parsePublicKey:info];
}

@end
