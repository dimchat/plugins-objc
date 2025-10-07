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
//  DIMAddressFactory.m
//  DIMCore
//
//  Created by Albert Moky on 2020/12/12.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import <DIMCore/DIMCore.h>

#import "DIMBTCAddress.h"
#import "DIMETHAddress.h"

#import "DIMAddressFactory.h"

@implementation DIMAddressFactory

- (instancetype)init {
    if (self = [super init]) {
        _addresses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// Override
- (id<MKMAddress>)generateAddress:(MKMEntityType)network
                         withMeta:(id<MKMMeta>)meta {
    id<MKMAddress> address = [meta generateAddress:network];
    NSAssert(address, @"failed to generate address: %@", meta);
    [_addresses setObject:address forKey:address.string];
    return address;
}

// Override
- (nullable id<MKMAddress>)parseAddress:(NSString *)address {
    id<MKMAddress> addr = [_addresses objectForKey:address];
    if (!addr) {
        addr = [self parse:address];
        if (addr) {
            [_addresses setObject:addr forKey:address];
        }
    }
    return addr;
}

- (nullable id<MKMAddress>)parse:(NSString *)address {
    NSComparisonResult res;
    NSUInteger len = [address length];
    if (len == 0) {
        NSAssert(false, @"address should not be empty");
        return nil;
    } else if (len == 8) {
        // "anywhere"
        res = [MKMAnywhere.string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMAnywhere;
        }
    } else if (len == 10) {
        // "everywhere"
        res = [MKMEverywhere.string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMEverywhere;
        }
    }
    id<MKMAddress> addr;
    if (26 <= len && len <= 35) {
        // BTC
        addr = [DIMBTCAddress parse:address];
    } else if (len == 42) {
        // ETH
        addr = [DIMETHAddress parse:address];
    } else {
        NSAssert(false, @"invalid address: %@", address);
        addr = nil;
    }
    // TODO: other types of address
    NSAssert(addr, @"invalid address: %@", address);
    return addr;
}

@end
