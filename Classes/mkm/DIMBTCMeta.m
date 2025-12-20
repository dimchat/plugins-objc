// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMBTCMeta.m
//  DIMPlugins
//
//  Created by Albert Moky on 2020/12/12.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import "DIMBTCAddress.h"

#import "DIMBTCMeta.h"

@implementation DIMBTCMeta

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _cachedAddresses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(NSString *)version
                         key:(id<MKVerifyKey>)publicKey
                        seed:(NSString *)seed
                 fingerprint:(id<MKTransportableData>)CT {
    if (self = [super initWithType:version
                               key:publicKey
                              seed:seed
                       fingerprint:CT]) {
        _cachedAddresses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithType:(NSString *)type key:(id<MKVerifyKey>)PK {
    return [self initWithType:type key:PK seed:nil fingerprint:nil];
}

// Override
- (BOOL)hasSeed {
    return NO;
    //return [self objectForKey:@"seed"] && [self objectForKey:@"fingerprint"];
}

// Override
- (id<MKMAddress>)generateAddress:(MKMEntityType)network {
    NSAssert([self.type isEqualToString:MKMMetaType_BTC] || [self.type isEqualToString:MKMMetaType_ExBTC],
             @"meta version error: %@", self.type);
    DIMBTCAddress *address = [_cachedAddresses objectForKey:@(network)];
    if (!address) {
        // TODO: compress public key?
        id<MKVerifyKey> key = [self publicKey];
        NSData *data = [key data];
        // generate and cache it
        address = [DIMBTCAddress generate:data type:network];
        [_cachedAddresses setObject:address forKey:@(network)];
    }
    return address;
}

@end
