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
//  DIMBase64Data.m
//  DIMPlugins
//
//  Created by Albert Moky on 2023/12/9.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMBase64Data.h"

@interface DIMBase64Data() {
    
    id<DIMTEDWrapper> _wrapper;
}

@end

@implementation DIMBase64Data

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _wrapper = [self createWrapper];
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _wrapper = [self createWrapper];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)binary {
    if (self = [self init]) {
        // encode algorithm
        _wrapper.algorithm = MKEncodeAlgorithm_BASE64;
        // binary data
        if ([binary length] > 0) {
            _wrapper.data = binary;
        }
    }
    return self;
}

// Override
- (NSMutableDictionary<NSString *, id> *)dictionary {
    // serialize data
    [_wrapper encode];
    return [super dictionary];
}

// Override
- (NSString *)algorithm {
    return [_wrapper algorithm];
}

// Override
- (NSData *)data {
    return [_wrapper data];
}

// Override
- (NSObject *)object {
    return [self string];
}

// Override
- (NSString *)string {
    // 0. "{BASE64_ENCODE}"
    // 1. "base64,{BASE64_ENCODE}"
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return [_wrapper encode];
}

- (NSString *)encode:(NSString *)mimeType {
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return [_wrapper encode:mimeType];
}

@end

@implementation DIMBase64Data (Wrapper)

- (id<DIMTEDWrapper>)createWrapper {
    NSMutableDictionary<NSString *, id> *info = [super dictionary];
    DIMSharedNetworkFormatAccess *access = [DIMSharedNetworkFormatAccess sharedInstance];
    id<DIMTEDWrapperFactory> factory = [access tedWrapperFactory];
    return [factory createTEDWrapper:info];
}

@end

#pragma mark -

@implementation DIMBase64DataFactory

// Override
- (id<MKTransportableData>)createTransportableData:(NSData *)data {
    return [[DIMBase64Data alloc] initWithData:data];
}

// Override
- (nullable id<MKTransportableData>)parseTransportableData:(NSDictionary *)ted {
    // check 'data'
    if ([ted objectForKey:@"data"] == nil) {
        // ted.data should not be empty
        NSAssert(false, @"TED error: %@", ted);
        return nil;
    }
    // TODO: 1. check algorithm
    //       2. check data format
    return [[DIMBase64Data alloc] initWithDictionary:ted];
}

@end
