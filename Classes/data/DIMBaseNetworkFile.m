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

#import "DIMBaseNetworkFile.h"

@interface DIMBaseNetworkFile() {
    
    DIMBaseFileWrapper *_wrapper;
}

@end

@implementation DIMBaseNetworkFile

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = [self dictionary];
        _wrapper = [[DIMBaseFileWrapper alloc] initWithDictionary:dict];
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        NSMutableDictionary *dict = [self dictionary];
        _wrapper = [[DIMBaseFileWrapper alloc] initWithDictionary:dict];
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
    NSString *urlString = [self _urlString];
    if (urlString) {
        // only contains 'URL', return the URL string directly
        return urlString;
    }
    // not a single URL, encode the entire dictionary
    return MKJsonMapEncode([self dictionary]);
}

// Override
- (NSObject *)object {
    NSString *urlString = [self _urlString];
    if (urlString) {
        // only contains 'URL', return the URL string directly
        return urlString;
    }
    // not a single URL, return the entire dictionary
    return [self dictionary];
}

- (NSString *)_urlString {
    NSUInteger count = [self count];
    if (count == 1) {
        // if only contains 'URL' field, return the URL string directly
        return [self stringForKey:@"URL" defaultValue:nil];
    } else if (count == 2 && [self objectForKey:@"filename"]) {
        // ignore 'filename' field
        return [self stringForKey:@"URL" defaultValue:nil];
    } else {
        // not a single URL
        return nil;
    }
}

@end

@implementation DIMBaseFileFactory

- (id<MKPortableNetworkFile>)createPortableNetworkFile:(id<MKTransportableData>)data
                                              filename:(NSString *)name
                                                   url:(NSURL *)locator
                                              password:(id<MKDecryptKey>)key {
    return [[DIMBaseNetworkFile alloc] initWithData:data
                                           filename:name
                                                url:locator
                                           password:key];
}

- (id<MKPortableNetworkFile>)parsePortableNetworkFile:(NSDictionary *)pnf {
    return [[DIMBaseNetworkFile alloc] initWithDictionary:pnf];
}

@end
