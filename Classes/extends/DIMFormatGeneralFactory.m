// license: https://mit-license.org
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
//  DIMFormatGeneralFactory.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import "DIMFormatGeneralFactory.h"

@interface DIMFormatGeneralFactory () {
    
    NSMutableDictionary<NSString *, id<MKTransportableDataFactory>> *_tedFactories;
    
    id<MKPortableNetworkFileFactory> _pnfFactory;
}

@end

static inline NSInteger _index_of(NSString *sub, NSString *text) {
    NSRange range = [text rangeOfString:sub];
    NSUInteger pos = range.location;
    if (pos == NSNotFound) {
        return -1;
    }
    return pos;
}

static inline NSString *_sub_string(NSString *text, NSUInteger start, NSUInteger end) {
    NSRange rang = NSMakeRange(start, end - start);
    return [text substringWithRange:rang];
}

@implementation DIMFormatGeneralFactory

- (instancetype)init {
    if (self = [super init]) {
        _tedFactories = [[NSMutableDictionary alloc] init];
        _pnfFactory = nil;
    }
    return self;
}

/**
 *  Split text string to array: ["{TEXT}", "{algorithm}", "{content-type}"]
 */
- (NSArray<NSString *> *)split:(NSString *)text {
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
    // "{TEXT}", or
    // "base64,{BASE64_ENCODE}", or
    // "data:image/png;base64,{BASE64_ENCODE}"
    NSInteger pos1 = _index_of(@"://", text);
    if (pos1 > 0) {
        //
        //  1. [URL]
        //
        [array addObject:text];
        return array;
    } else {
        // skip 'data:'
        pos1 = _index_of(@":", text) + 1;
    }
    // seeking for 'content-type'
    NSInteger pos2 = _index_of(@";", text) + 1;
    if (pos2 == 0) {
        pos2 = pos1;
    }
    // seeking for 'algorithm'
    NSInteger pos3 = _index_of(@",", text) + 1;
    if (pos3 == 0) {
        pos3 = pos2;
    }
    if (pos3 == 0) {
        //
        //  2. [data]
        //
        [array addObject:text];
        return array;
    } else {
        // add 'data'
        NSString *data = [text substringFromIndex:pos3];
        [array addObject:data];
    }
    // add 'algorithm'
    if (pos3 > pos2) {
        NSString *algorithm = _sub_string(text, pos2, pos3);
        [array addObject:algorithm];
    }
    // add 'content-type'
    if (pos2 > pos1) {
        NSString *type = _sub_string(text, pos1, pos2);
        [array addObject:type];
    }
    //
    //  3. [data, algorithm, type]
    //
    return array;
}

- (NSDictionary *)decode:(id)data defaultKey:(NSString *)aKey {
    if ([data conformsToProtocol:@protocol(MKDictionary)]) {
        return [data dictionary];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        return data;
    }
    NSString *text = [data isKindOfClass:[NSString class]] ? data : [data description];
    if ([text length] == 0) {
        return nil;
    } else if ([text hasPrefix:@"{"] && [text hasSuffix:@"}"]) {
        return MKJsonMapDecode(text);
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSArray *array = [self split:text];
    NSUInteger size = [array count];
    if (size == 1) {
        [info setObject:array.firstObject forKey:aKey];
    } else if (size == 2) {
        [info setObject:array.firstObject forKey:@"data"];
        [info setObject:array.lastObject forKey:@"algorithm"];
    } else {
        NSAssert(size == 3, @"split error: %@ => %@", text, array);
        // 'data:...;...,...'
        [info setObject:[array objectAtIndex:0] forKey:@"data"];
        [info setObject:[array objectAtIndex:1] forKey:@"algorithm"];
        [info setObject:[array objectAtIndex:2] forKey:@"content-type"];
        if ([text hasPrefix:@"data:"]) {
            [info setObject:text forKey:@"URL"];
        }
    }
    return info;
}

- (nullable NSString *)getFormatAlgorithm:(NSDictionary<NSString *,id> *)ted
                             defaultValue:(nullable NSString *)aValue {
    id algorithm = [ted objectForKey:@"algorithm"];
    return MKConvertString(algorithm, aValue);
}

#pragma mark TED - Transportable Encoded Data

- (void)setTransportableDataFactory:(id<MKTransportableDataFactory>)factory
                          algorithm:(NSString *)name {
    [_tedFactories setObject:factory forKey:name];
}

- (nullable id<MKTransportableDataFactory>)getTransportableDataFactory:(NSString *)algorithm {
    return [_tedFactories objectForKey:algorithm];
}

- (id<MKTransportableData>)createTransportableData:(NSData *)data
                                         algorithm:(NSString *)name {
    if ([name length] == 0) {
        name = MKEncodeAlgorithm_Default;
    }
    id<MKTransportableDataFactory> factory = [self getTransportableDataFactory:name];
    NSAssert(factory, @"TED algorithm not support: %@", name);
    return [factory createTransportableData:data];
}

- (nullable id<MKTransportableData>)parseTransportableData:(nullable id)ted {
    if (!ted) {
        return nil;
    } else if ([ted conformsToProtocol:@protocol(MKTransportableData)]) {
        return ted;
    }
    // unwrap
    NSDictionary *info = [self decode:ted defaultKey:@"data"];
    if (!info) {
        //NSAssert(false, @"TED error: %@", ted);
        return nil;
    }
    NSString *algo = [self getFormatAlgorithm:info defaultValue:nil];
    //NSAssert([algo length] > 0, @"TED error: %@", ted);
    id<MKTransportableDataFactory> factory = [self getTransportableDataFactory:algo];
    if (!factory) {
        // unknown algorithm, get default factory
        factory = [self getTransportableDataFactory:@"*"];  // unknown
        NSAssert(factory, @"default TED factory not found");
    }
    return [factory parseTransportableData:info];
}

#pragma mark PNF - Portable Network File

- (void)setPortableNetworkFileFactory:(id<MKPortableNetworkFileFactory>)factory {
    _pnfFactory = factory;
}

- (nullable id<MKPortableNetworkFileFactory>)getPortableNetworkFileFactory {
    return _pnfFactory;
}

- (id<MKPortableNetworkFile>)createPortableNetworkFile:(nullable id<MKTransportableData>)data
                                              filename:(nullable NSString *)name
                                                   url:(nullable NSURL *)location
                                              password:(nullable id<MKDecryptKey>)key {
    id<MKPortableNetworkFileFactory> factory = [self getPortableNetworkFileFactory];
    NSAssert(factory, @"PNF factory not ready");
    return [factory createPortableNetworkFile:data
                                     filename:name
                                          url:location
                                     password:key];
}

- (nullable id<MKPortableNetworkFile>)parsePortableNetworkFile:(nullable id)pnf { 
    if (!pnf) {
        return nil;
    } else if ([pnf conformsToProtocol:@protocol(MKPortableNetworkFile)]) {
        return pnf;
    }
    // unwrap
    NSDictionary *info = [self decode:pnf defaultKey:@"URL"];
    if (!info) {
        //NSAssert(false, @"PNF error: %@", ted);
        return nil;
    }
    id<MKPortableNetworkFileFactory> factory = [self getPortableNetworkFileFactory];
    NSAssert(factory, @"PNF factory not ready");
    return [factory parsePortableNetworkFile:info];
}

@end
