// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2022 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2022 Albert Moky
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
//  DIMIDFactory.m
//  DIMCore
//
//  Created by Albert Moky on 2020/12/12.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import <DIMCore/DIMCore.h>

#import "DIMAddressFactory.h"

#import "DIMIDFactory.h"

@implementation DIMIDFactory

- (instancetype)init {
    if (self = [super init]) {
        _identifiers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// Override
- (id<MKMID>)generateIdentifier:(MKMEntityType)network
                       withMeta:(id<MKMMeta>)meta
                       terminal:(nullable NSString *)locater {
    id<MKMAddress> address = MKMAddressGenerate(network, meta);
    NSAssert(address, @"failed to generate address with meta: %@", meta);
    return MKMIDCreate(meta.seed, address, locater);
}

// Override
- (id<MKMID>)createIdentifierWithName:(NSString *)name
                              address:(id<MKMAddress>)address
                             terminal:(NSString *)location {
    NSString *string = MKMIDConcat(name, address, location);
    id<MKMID> ID = [_identifiers objectForKey:string];
    if (!ID) {
        ID = [self newID:string name:name address:address terminal:location];
        [_identifiers setObject:ID forKey:string];
    }
    return ID;
}

- (nullable id<MKMID>)parseIdentifier:(NSString *)identifier {
    id<MKMID> ID = [_identifiers objectForKey:identifier];
    if (!ID) {
        ID = [self parse:identifier];
        if (ID) {
            [_identifiers setObject:ID forKey:identifier];
        }
    }
    return ID;
}

- (id<MKMID>)newID:(NSString *)identifier
              name:(nullable NSString *)seed
           address:(id<MKMAddress>)main
          terminal:(nullable NSString *)loc {
    // override for customized ID
    return [[MKMID alloc] initWithString:identifier
                                    name:seed
                                 address:main
                                terminal:loc];
}

// protected
- (nullable id<MKMID>)parse:(NSString *)identifier {
    NSString *name;
    id<MKMAddress> address;
    NSString *terminal;
    // split ID string
    NSArray<NSString *> *pair = [identifier componentsSeparatedByString:@"/"];
    NSAssert(pair.firstObject.length > 0, @"ID error: %@", identifier);
    // terminal
    if (pair.count == 1) {
        // no terminal
        terminal = nil;
    } else {
        // got terminal
        NSAssert(pair.count == 2, @"ID error: %@", identifier);
        NSAssert(pair.lastObject.length > 0, @"ID.terminal error: %@", identifier);
        terminal = pair.lastObject;
    }
    // name @ address
    pair = [pair.firstObject componentsSeparatedByString:@"@"];
    NSAssert(pair.lastObject.length > 0, @"ID.address error: %@", identifier);
    if (pair.count == 1) {
        // got address without name
        name = nil;
    } else {
        // got name & address
        NSAssert(pair.count == 2, @"ID error: %@", identifier);
        NSAssert(pair.firstObject.length > 0, @"ID error: %@", identifier);
        name = pair.firstObject;
    }
    address = MKMAddressParse(pair.lastObject);
    if (address == nil) {
        NSAssert(false, @"cannot get address from ID: %@", identifier);
        return nil;
    }
    return [self newID:identifier name:name address:address terminal:terminal];
}

@end
