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

#import <DIMCore/DIMCore.h>

#import "DIMFormatGeneralFactory.h"

@interface DIMFormatGeneralFactory () {
    
    NSMutableDictionary<NSString *, id<MKTransportableDataFactory>> *_tedFactories;
    
    id<MKPortableNetworkFileFactory> _pnfFactory;
}

@end

@implementation DIMFormatGeneralFactory

- (instancetype)init {
    if (self = [super init]) {
        _tedFactories = [[NSMutableDictionary alloc] init];
        _pnfFactory = nil;
    }
    return self;
}

// Override
- (nullable NSString *)getFormatAlgorithm:(NSDictionary<NSString *,id> *)ted
                             defaultValue:(nullable NSString *)aValue {
    id algorithm = [ted objectForKey:@"algorithm"];
    return MKConvertString(algorithm, aValue);
}

#pragma mark TED - Transportable Encoded Data

// Override
- (void)setTransportableDataFactory:(id<MKTransportableDataFactory>)factory
                          algorithm:(NSString *)name {
    [_tedFactories setObject:factory forKey:name];
}

// Override
- (nullable id<MKTransportableDataFactory>)getTransportableDataFactory:(NSString *)algorithm {
    return [_tedFactories objectForKey:algorithm];
}

// Override
- (id<MKTransportableData>)createTransportableData:(NSData *)data
                                         algorithm:(NSString *)name {
    if ([name length] == 0) {
        name = MKEncodeAlgorithm_Default;
    }
    id<MKTransportableDataFactory> factory = [self getTransportableDataFactory:name];
    NSAssert(factory, @"TED algorithm not support: %@", name);
    return [factory createTransportableData:data];
}

// Override
- (nullable id<MKTransportableData>)parseTransportableData:(nullable id)ted {
    if (!ted) {
        return nil;
    } else if ([ted conformsToProtocol:@protocol(MKTransportableData)]) {
        return ted;
    }
    // unwrap
    NSDictionary *info = [self parseData:ted];
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

// Override
- (void)setPortableNetworkFileFactory:(id<MKPortableNetworkFileFactory>)factory {
    _pnfFactory = factory;
}

// Override
- (nullable id<MKPortableNetworkFileFactory>)getPortableNetworkFileFactory {
    return _pnfFactory;
}

// Override
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

// Override
- (nullable id<MKPortableNetworkFile>)parsePortableNetworkFile:(nullable id)pnf {
    if (!pnf) {
        return nil;
    } else if ([pnf conformsToProtocol:@protocol(MKPortableNetworkFile)]) {
        return pnf;
    }
    // unwrap
    NSDictionary *info = [self parseURL:pnf];
    if (!info) {
        //NSAssert(false, @"PNF error: %@", ted);
        return nil;
    }
    id<MKPortableNetworkFileFactory> factory = [self getPortableNetworkFileFactory];
    NSAssert(factory, @"PNF factory not ready");
    return [factory parsePortableNetworkFile:info];
}

@end

@implementation DIMFormatGeneralFactory (Convenience)

- (nullable NSDictionary *)parseURL:(nullable id)pnf {
    NSDictionary *info = [self getMap:pnf];
    if (!info) {
        // parse data URI from text string
        NSString *text = MKConvertString(pnf, nil);
        info = [self parseDataURI:text];
        if (!info) {
            // data URI
            NSAssert([text containsString:@"://"] != YES, @"PNF data error: %@", pnf);
            //if ([text containsString:@"://"] == YES) {
            //    [(NSMutableDictionary *)info setObject:text forKey:@"URI"];
            //}
        } else if ([text containsString:@"://"] == YES) {
            // [URL]
            info = @{
                @"URL": text,
            };
        }
    }
    return info;
}

- (nullable NSDictionary *)parseData:(nullable id)ted {
    NSDictionary *info = [self getMap:ted];
    if (!info) {
        // parse data URI from text string
        NSString *text = MKConvertString(ted, nil);
        info = [self parseDataURI:text];
        if (!info) {
            NSAssert([text containsString:@"://"] != YES, @"TED data error: %@", ted);
            // [TEXT]
            info = @{
                @"data": text,
            };
        }
    }
    return info;
}

- (nullable NSDictionary *)getMap:(nullable id)value {
    if (!value) {
        return nil;
    } else if ([value conformsToProtocol:@protocol(MKDictionary)]) {
        return [value dictionary];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    NSString *text = MKConvertString(value, nil);
    if ([text length] < 8) {
        return nil;
    } else if ([text hasPrefix:@"{"] && [text hasSuffix:@"}"]) {
        // from JSON string
        return MKJsonMapDecode(text);
    } else {
        return nil;
    }
}

- (nullable NSDictionary *)parseDataURI:(nullable NSString *)text {
    DIMDataURI *uri = [DIMDataURI parse:text];
    return [uri dictionary];
}

@end

#pragma mark -

@interface DIMDataURI ()

@property (strong, nonatomic, nullable) NSString *mimeType;
@property (strong, nonatomic, nullable) NSString *encoding;
@property (strong, nonatomic) NSString *body;

@end

@implementation DIMDataURI

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSString *date = nil;
    return [self initWithType:nil encoding:nil body:date];
}

/* designated initializer */
- (instancetype)initWithType:(nullable NSString *)mimeType
                    encoding:(nullable NSString *)algorithm
                        body:(NSString *)data {
    if (self = [super init]) {
        self.mimeType = mimeType;
        self.encoding = algorithm;
        self.body = data;
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:self.body forKey:@"data"];
    // 'mime-type'
    NSString *mimeType = self.mimeType;
    if (mimeType) {
        [info setObject:mimeType forKey:@"mime-type"];
    }
    // 'encoding'
    NSString *algorithm = self.encoding;
    if (algorithm) {
        [info setObject:algorithm forKey:@"algorithm"];
    }
    return info;
}

+ (instancetype)parse:(nullable NSString *)text {
    if ([text length] == 0) {
        return nil;
    }
    NSRange range;
    if ([text hasPrefix:@"data:"]) {
        // "data:image/png;base64,{BASE64_ENCODE}"
        text = [text substringFromIndex:5];
        range = [text rangeOfString:@","];
        if (range.location == NSNotFound) {
            NSAssert(false, @"data URI error: %@", text);
            return nil;
        }
    } else {
        // "base64,{BASE64_ENCODE}"
        range = [text rangeOfString:@","];
        if (range.location == NSNotFound || range.location > 8) {
            // "{TEXT}", or "{URL}"
            return nil;
        }
    }
    NSString *body = [text substringFromIndex:(range.location + 1)];
    NSString *head = [text substringToIndex:(range.location)];
    // split for 'mime-type' + 'encoding'
    range = [head rangeOfString:@";"];
    if (range.location == NSNotFound) {
        // "base64,{BASE64_ENCODE}"
        return [[DIMDataURI alloc] initWithType:nil encoding:head body:body];
    }
    NSAssert(range.location > 0, @"data URI error: %@", text);
    // "data:image/png;base64,{BASE64_ENCODE}"
    NSString *mimeType = [head substringToIndex:(range.location)];
    NSString *encoding = [head substringFromIndex:(range.location + 1)];
    return [[DIMDataURI alloc] initWithType:mimeType encoding:encoding body:body];
}

+ (nullable NSString *)build:(NSDictionary *)info {
    //
    //  1. check encoded data & content type
    //
    NSString *data = [info objectForKey:@"data"];
    NSString *mime = [info objectForKey:@"mime-type"];
    if (!data || !mime) {
        // params not matched
        return nil;
    } else {
        NSAssert([data isKindOfClass:[NSString class]] && [mime isKindOfClass:[NSString class]], @"params error: %@", info);
    }
    //
    //  2. check extra params
    //
    NSInteger count = [info count];
    if ([info objectForKey:@"filename"]) {
        count -= 1;
    }
    NSString *algorithm = [info objectForKey:@"algorithm"];
    if (algorithm) {
        count -= 1;
    } else {
        algorithm = MKEncodeAlgorithm_BASE64;
    }
    if (count != 2) {
        // extra params exist, cannot build data URI
        return nil;
    }
    //
    //  3. build string: 'data:...;...,...'
    //
    return [[NSString alloc] initWithFormat:@"data:%@;%@,%@", mime, algorithm, data];
}

@end
