// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
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
//  DIMPlainKey.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import "DIMPlainKey.h"

@implementation DIMPlainKey

static DIMPlainKey *s_sharedPlainKey = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_sharedPlainKey) {
            s_sharedPlainKey = [[DIMPlainKey alloc] init];
        }
    });
    return s_sharedPlainKey;
}

- (instancetype)init {
    NSDictionary *dict = @{@"algorithm": MKSymmetricAlgorithm_Plain};
    if (self = [super initWithDictionary:dict]) {
        //
    }
    return self;
}

// Override
- (NSData *)data {
    return nil;
}

// Override
- (NSData *)encrypt:(NSData *)plaintext
              extra:(nullable NSMutableDictionary<NSString *,id> *)params {
    return plaintext;
}

// Override
- (nullable NSData *)decrypt:(NSData *)ciphertext
                      params:(nullable NSDictionary<NSString *,id> *)extra {
    return ciphertext;
}

@end

@implementation DIMPlainKeyFactory

// Override
- (id<MKSymmetricKey>)generateSymmetricKey {
    return [DIMPlainKey sharedInstance];
}

// Override
- (nullable id<MKSymmetricKey>)parseSymmetricKey:(NSDictionary *)key {
    return [DIMPlainKey sharedInstance];
}

@end
