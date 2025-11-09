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
//  DIMDocumentFactory.m
//  DIMPlugins
//
//  Created by Albert Moky on 2023/12/9.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMCore/Ext.h>

#import "DIMDocumentFactory.h"

@implementation DIMDocumentFactory

- (instancetype)initWithType:(NSString *)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (NSString *)getType:(NSString *)type forIdentifier:(id<MKMID>)did {
    if (![type isEqualToString:@"*"]) {
        return type;
    } else if ([did isGroup]) {
        return MKMDocumentType_Bulletin;
    } else if ([did isUser]) {
        return MKMDocumentType_Visa;
    } else {
        return MKMDocumentType_Profile;
    }
}

// Override
- (id<MKMDocument>)createDocument:(id<MKMID>)did
                             data:(nullable NSString *)json
                        signature:(nullable id<MKTransportableData>)CT {
    NSString *type = [self getType:_type forIdentifier:did];
    if (json && CT) {
        if ([type isEqualToString:MKMDocumentType_Visa]) {
            return [[DIMVisa alloc] initWithIdentifier:did data:json signature:CT];
        }
        if ([type isEqualToString:MKMDocumentType_Bulletin]) {
            return [[DIMBulletin alloc] initWithIdentifier:did data:json signature:CT];
        }
        return [[DIMDocument alloc] initWithIdentifier:did data:json signature:CT];
    } else {
        // create a new empty document with entity ID
        if ([type isEqualToString:MKMDocumentType_Visa]) {
            return [[DIMVisa alloc] initWithIdentifier:did];
        }
        if ([type isEqualToString:MKMDocumentType_Bulletin]) {
            return [[DIMBulletin alloc] initWithIdentifier:did];
        }
        return [[DIMDocument alloc] initWithIdentifier:did type:type];
    }
}

// Override
- (nullable id<MKMDocument>)parseDocument:(NSDictionary *)doc {
    id<MKMID> did = MKMIDParse([doc objectForKey:@"did"]);
    if (!did) {
        NSAssert(false, @"document ID not found: %@", doc);
        return nil;
    } else if ([doc objectForKey:@"data"] && [doc objectForKey:@"signature"]) {
        // OK
    } else {
        // doc.data should not be empty
        // doc.signature should not be empty
        NSAssert(false, @"document error: %@", doc);
        return nil;
    }
    MKMSharedAccountExtensions *ext = [MKMSharedAccountExtensions sharedInstance];
    NSString *type = [ext.helper getDocumentType:doc defaultValue:nil];
    if (!type) {
        type = [self getType:@"I" forIdentifier:did];
    }
    if ([type isEqualToString:MKMDocumentType_Visa]) {
        return [[DIMVisa alloc] initWithDictionary:doc];
    }
    if ([type isEqualToString:MKMDocumentType_Bulletin]) {
        return [[DIMBulletin alloc] initWithDictionary:doc];
    }
    return [[DIMDocument alloc] initWithDictionary:doc];
}

@end
