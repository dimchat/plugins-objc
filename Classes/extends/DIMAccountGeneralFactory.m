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
//  DIMAccountGeneralFactory.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/DIMCore.h>

#import "DIMAccountGeneralFactory.h"

@interface DIMAccountGeneralFactory () {
    
    id<MKMAddressFactory> _addressFactory;
    id<MKMIDFactory>      _idFactory;
    
    NSMutableDictionary<NSString *, id<MKMMetaFactory>>     *_metaFactories;
    NSMutableDictionary<NSString *, id<MKMDocumentFactory>> *_docsFactories;
}

@end

@implementation DIMAccountGeneralFactory

- (instancetype)init {
    if (self = [super init]) {
        _addressFactory = nil;
        _idFactory = nil;
        _metaFactories = [[NSMutableDictionary alloc] init];
        _docsFactories = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (nullable NSString *)getMetaType:(NSDictionary<NSString *,id> *)meta defaultValue:(nullable NSString *)aValue {
    id version = [meta objectForKey:@"type"];
    return MKConvertString(version, aValue);
}

- (nullable NSString *)getDocumentType:(NSDictionary<NSString *,id> *)doc defaultValue:(nullable NSString *)aValue {
    id docType = [doc objectForKey:@"type"];
    if (docType) {
        return MKConvertString(docType, aValue);
    } else if (aValue) {
        return aValue;
    }
    // get type for did
    id<MKMID> did = MKMIDParse([doc objectForKey:@"did"]);
    if (!did) {
        NSAssert(false, @"document error: %@", doc);
        return nil;
    } else if ([did isUser]) {
        return MKMDocumentType_Visa;
    } else if ([did isGroup]) {
        return MKMDocumentType_Bulletin;
    } else {
        return MKMDocumentType_Profile;
    }
}

#pragma mark Address

- (void)setAddressFactory:(id<MKMAddressFactory>)factory {
    _addressFactory = factory;
}

- (nullable id<MKMAddressFactory>)getAddressFactory { 
    return _addressFactory;
}

- (nullable id<MKMAddress>)parseAddress:(nullable id)address {
    if (!address) {
        return nil;
    } else if ([address conformsToProtocol:@protocol(MKMAddress)]) {
        return address;
    }
    NSString *str = MKGetString(address);
    if (!str) {
        NSAssert(false, @"address error: %@", address);
        return nil;
    }
    id<MKMAddressFactory> factory = [self getAddressFactory];
    NSAssert(factory, @"address factory not ready");
    return [factory parseAddress:address];
}

- (__kindof id<MKMAddress>)generateAddressWithMeta:(id<MKMMeta>)meta
                                              type:(MKMEntityType)network {
    id<MKMAddressFactory> factory = [self getAddressFactory];
    NSAssert(factory, @"address factory not ready");
    return [factory generateAddressWithMeta:meta type:network];
}

#pragma mark ID

- (void)setIDFactory:(id<MKMIDFactory>)factory {
    _idFactory = factory;
}

- (nullable id<MKMIDFactory>)getIDFactory {
    return _idFactory;
}

- (nullable id<MKMID>)parseID:(nullable id)identifier {
    if (!identifier) {
        return nil;
    } else if ([identifier conformsToProtocol:@protocol(MKMID)]) {
        return identifier;
    }
    NSString *str = MKGetString(identifier);
    if (!str) {
        NSAssert(false, @"ID error: %@", identifier);
        return nil;
    }
    id<MKMIDFactory> factory = [self getIDFactory];
    NSAssert(factory, @"ID factory not ready");
    return [factory parseID:identifier];
}

- (id<MKMID>)createIDWithAddress:(id<MKMAddress>)address
                            name:(nullable NSString *)seed
                        terminal:(nullable NSString *)location {
    id<MKMIDFactory> factory = [self getIDFactory];
    NSAssert(factory, @"ID factory not ready");
    return [factory createIDWithAddress:address name:seed terminal:location];
}

- (id<MKMID>)generateIDWithMeta:(id<MKMMeta>)meta
                           type:(MKMEntityType)network
                       terminal:(nullable NSString *)location {
    id<MKMIDFactory> factory = [self getIDFactory];
    NSAssert(factory, @"ID factory not ready");
    return [factory generateIDWithMeta:meta type:network terminal:location];
}

#pragma mark Meta

- (void)setMetaFactory:(id<MKMMetaFactory>)factory forType:(NSString *)type {
    [_metaFactories setObject:factory forKey:type];
}

- (nullable id<MKMMetaFactory>)getMetaFactory:(NSString *)type {
    return [_metaFactories objectForKey:type];
}

- (nullable id<MKMMeta>)parseMeta:(nullable id)meta {
    if (!meta) {
        return nil;
    } else if ([meta conformsToProtocol:@protocol(MKMMeta)]) {
        return meta;
    }
    NSDictionary *info = MKGetMap(meta);
    if (!info) {
        NSAssert(false, @"meta error: %@", meta);
        return nil;
    }
    NSString *type = [self getMetaType:info defaultValue:nil];
    NSAssert([type length] > 0, @"meta error: %@", meta);
    id<MKMMetaFactory> factory = [self getMetaFactory:type];
    if (!factory) {
        // unknown meta type, get default meta factory
        factory = [self getMetaFactory:@"*"];  // unknown
        NSAssert(factory, @"default meta factory not found");
    }
    return [factory parseMeta:info];
}

- (id<MKMMeta>)createMetaWithKey:(id<MKVerifyKey>)PK
                            seed:(nullable NSString *)name
                     fingerprint:(nullable id<MKTransportableData>)sig
                         forType:(NSString *)type {
    id<MKMMetaFactory> factory = [self getMetaFactory:type];
    NSAssert(factory, @"meta type not supported: %@", type);
    return [factory createMetaWithKey:PK seed:name fingerprint:sig];
}

- (id<MKMMeta>)generateMetaWithKey:(id<MKSignKey>)SK
                              seed:(nullable NSString *)name
                           forType:(NSString *)type {
    id<MKMMetaFactory> factory = [self getMetaFactory:type];
    NSAssert(factory, @"meta type not supported: %@", type);
    return [factory generateMetaWithKey:SK seed:name];
}

#pragma mark Document

- (void)setDocumentFactory:(id<MKMDocumentFactory>)factory forType:(NSString *)type {
    [_docsFactories setObject:factory forKey:type];
}

- (nullable id<MKMDocumentFactory>)getDocumentFactory:(NSString *)type {
    return [_docsFactories objectForKey:type];
}

- (nullable id<MKMDocument>)parseDocument:(nullable id)doc {
    if (!doc) {
        return nil;
    } else if ([doc conformsToProtocol:@protocol(MKMDocument)]) {
        return doc;
    }
    NSDictionary *info = MKGetMap(doc);
    if (!info) {
        NSAssert(false, @"document error: %@", doc);
        return nil;
    }
    NSString *type = [self getDocumentType:info defaultValue:nil];
    //NSAssert([type length] > 0, @"document error: %@", doc);
    id<MKMDocumentFactory> factory = [self getDocumentFactory:type];
    if (!factory) {
        // unknown document type, get default document factory
        factory = [self getDocumentFactory:@"*"];  // unknown
        NSAssert(factory, @"default document factory not found");
    }
    return [factory parseDocument:info];
}

- (id<MKMDocument>)createDocument:(id<MKMID>)did
                             data:(nullable NSString *)json
                        signature:(nullable id<MKTransportableData>)sig
                          forType:(nonnull NSString *)type {
    id<MKMDocumentFactory> factory = [self getDocumentFactory:type];
    NSAssert(factory, @"document type not supported: %@", type);
    return [factory createDocument:did data:json signature:sig];
}

@end
