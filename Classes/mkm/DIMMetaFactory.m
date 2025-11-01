// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMMetaFactory.m
//  DIMPlugins
//
//  Created by Albert Moky on 2023/12/9.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>
#import <DIMCore/Ext.h>

#import "DIMDefaultMeta.h"
#import "DIMBTCMeta.h"
#import "DIMETHMeta.h"

#import "DIMMetaFactory.h"

@implementation DIMMetaFactory

- (instancetype)initWithType:(NSString *)version {
    if (self = [super init]) {
        _type = version;
    }
    return self;
}

// Override
- (id<MKMMeta>)createMetaWithKey:(id<MKVerifyKey>)PK
                            seed:(nullable NSString *)name
                     fingerprint:(nullable id<MKTransportableData>)CT {
    id<MKMMeta> meta;
    NSString *version = _type;
    if ([version isEqualToString:MKMMetaType_MKM]) {
        meta = [[DIMDefaultMeta alloc] initWithType:version key:PK seed:name fingerprint:CT];
    } else if ([version isEqualToString:MKMMetaType_BTC]) {
        meta = [[DIMBTCMeta alloc] initWithType:version key:PK seed:name fingerprint:CT];
    } else if ([version isEqualToString:MKMMetaType_ETH]) {
        meta = [[DIMETHMeta alloc] initWithType:version key:PK seed:name fingerprint:CT];
    } else {
        NSAssert(false, @"meta type not supported: %@", version);
        meta = nil;
    }
    return meta;
}

// Override
- (id<MKMMeta>)generateMetaWithKey:(id<MKSignKey>)SK
                              seed:(nullable NSString *)name {
    id<MKTransportableData> CT;
    if (name.length > 0) {
        NSData *sig = [SK sign:MKUTF8Encode(name)];
        CT = MKTransportableDataCreate(sig, nil);
    } else {
        CT = nil;
    }
    id<MKPublicKey> PK = [(id<MKPrivateKey>)SK publicKey];
    return [self createMetaWithKey:PK seed:name fingerprint:CT];
}

// Override
- (nullable id<MKMMeta>)parseMeta:(NSDictionary *)info {
    // check 'type', 'key', 'seed', 'fingerprint'
    // ...
    id<MKMMeta> meta = nil;
    MKMSharedAccountExtensions *ext = [MKMSharedAccountExtensions sharedInstance];
    NSString *version = [ext.helper getMetaType:info defaultValue:nil];
    if ([version isEqualToString:MKMMetaType_MKM]) {
        meta = [[DIMDefaultMeta alloc] initWithDictionary:info];
    } else if ([version isEqualToString:MKMMetaType_BTC]) {
        meta = [[DIMBTCMeta alloc] initWithDictionary:info];
    } else if ([version isEqualToString:MKMMetaType_ETH]) {
        meta = [[DIMETHMeta alloc] initWithDictionary:info];
    } else {
        NSAssert(false, @"meta type not supported: %@", version);
        meta = nil;
    }
    return [meta isValid] ? meta : nil;
}

@end
