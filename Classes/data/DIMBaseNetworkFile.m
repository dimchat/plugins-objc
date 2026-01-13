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
//  DIMBaseNetworkFile.m
//  DIMPlugins
//
//  Created by Albert Moky on 2023/12/9.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMFormatGeneralFactory.h"

#import "DIMBaseNetworkFile.h"

@interface DIMBaseNetworkFile() {
    
    id<DIMPNFWrapper> _wrapper;
}

@end

@implementation DIMBaseNetworkFile

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

- (instancetype)initWithData:(nullable id<MKTransportableData>)data
                    filename:(nullable NSString *)name
                         url:(nullable NSURL *)locator
                    password:(nullable id<MKDecryptKey>)key {
    if (self = [self init]) {
        // file data
        if (data) {
            [_wrapper setData:data];
        }
        // file name
        if (name) {
            [_wrapper setFilename:name];
        }
        // remote URL
        if (locator) {
            [_wrapper setURL:locator];
        }
        // decrypt key
        if (key) {
            [_wrapper setPassword:key];
        }
    }
    return self;
}

// Override
- (NSMutableDictionary<NSString *, id> *)dictionary {
    // serialize data
    [_wrapper dictionary];
    return [super dictionary];
}

// Override
- (NSData *)data {
    id<MKTransportableData> ted = [_wrapper data];
    return [ted data];
}

// Override
- (void)setData:(NSData *)data {
    [_wrapper setBinary:data];
}

// Override
- (NSString *)filename {
    return [_wrapper filename];
}

// Override
- (void)setFilename:(NSString *)filename {
    [_wrapper setFilename:filename];
}

// Override
- (NSURL *)URL {
    return [_wrapper URL];
}

// Override
- (void)setURL:(NSURL *)url {
    [_wrapper setURL:url];
}

// Override
- (id<MKDecryptKey>)password {
    return [_wrapper password];
}

// Override
- (void)setPassword:(id<MKDecryptKey>)password {
    [_wrapper setPassword:password];
}

// Override
- (NSString *)string {
    NSDictionary *info = [self dictionary];
    NSString *text = [self _getUrlString:info];
    if (text) {
        // only contains 'URL',
        // or this info can be built to a data URI
        return text;
    }
    // not a single URL, encode the entire dictionary
    return MKJsonMapEncode(info);
}

// Override
- (NSObject *)object {
    NSDictionary *info = [self dictionary];
    NSString *text = [self _getUrlString:info];
    if (text) {
        // only contains 'URL',
        // or this info can be built to a data URI
        return text;
    }
    // not a single URL, return the entire dictionary
    return info;
}

- (NSString *)_getUrlString:(NSDictionary *)info {
    //
    //  check URL
    //
    NSString *urlString = MKConvertString([info objectForKey:@"URL"], nil);
    if (!urlString) {
        //
        //  check data URI
        //
        return [DIMDataURI build:info];
    } else if ([urlString hasPrefix:@"data:"]) {
        // 'data:...;...,...'
        return urlString;
    }
    //
    //  check extra params
    //
    NSUInteger count = [info count];
    if (count == 1) {
        // if only contains 'URL' field, return the URL string directly
        return urlString;
    } else if (count == 2 && [self objectForKey:@"filename"]) {
        // ignore 'filename' field
        return urlString;
    } else {
        // not a single URL
        return nil;
    }
}

@end

@implementation DIMBaseFileFactory

// Override
- (id<MKPortableNetworkFile>)createPortableNetworkFile:(id<MKTransportableData>)data
                                              filename:(NSString *)name
                                                   url:(NSURL *)locator
                                              password:(id<MKDecryptKey>)key {
    return [[DIMBaseNetworkFile alloc] initWithData:data
                                           filename:name
                                                url:locator
                                           password:key];
}

// Override
- (id<MKPortableNetworkFile>)parsePortableNetworkFile:(NSDictionary *)pnf {
    // check 'data', 'URL', 'filename'
    if ([pnf objectForKey:@"data"] == nil &&
        [pnf objectForKey:@"URL"] == nil &&
        [pnf objectForKey:@"filename"] == nil) {
        // pnf.data and pnf.URL and pnf.filename should not be empty at the same time
        NSAssert(false, @"PNF error: %@", pnf);
        return nil;
    }
    return [[DIMBaseNetworkFile alloc] initWithDictionary:pnf];
}

@end
