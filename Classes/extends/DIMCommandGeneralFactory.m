// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
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
//  DIMCommandGeneralFactory.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/DIMCore.h>

#import "DIMCommandGeneralFactory.h"

@interface DIMCommandGeneralFactory () {
    
    NSMutableDictionary<NSString *, id<DKDCommandFactory>> *_commandFactories;
}

@end

@implementation DIMCommandGeneralFactory

- (instancetype)init {
    if (self = [super init]) {
        _commandFactories = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (nullable NSString *)getCmd:(NSDictionary<NSString *,id> *)content defaultValue:(nullable NSString *)aValue {
    id cmd = [content objectForKey:@"command"];
    return MKConvertString(cmd, aValue);
}

#pragma mark Command

- (void)setCommandFactory:(id<DKDCommandFactory>)factory cmd:(NSString *)cmd {
    [_commandFactories setObject:factory forKey:cmd];
}

- (nullable id<DKDCommandFactory>)getCommandFactory:(NSString *)cmd {
    return [_commandFactories objectForKey:cmd];
}

- (nullable id<DKDCommand>)parseCommand:(nullable id)content { 
    if (!content) {
        return content;
    } else if ([content conformsToProtocol:@protocol(DKDCommand)]) {
        return content;
    }
    NSDictionary *info = MKGetMap(content);
    if (!info) {
        NSAssert(false, @"command content error: %@", content);
        return nil;
    }
    NSString *cmd = [self getCmd:info defaultValue:nil];
    NSAssert([cmd length] > 0, @"command name error: %@", content);
    id<DKDCommandFactory> factory = [self getCommandFactory:cmd];
    if (!factory) {
        // unknown command name, get base command factory
        factory = [DIMCommandGeneralFactory defaultFactory:info];
        NSAssert(factory, @"cannot parse command: %@", content);
    }
    return [factory parseCommand:info];
}

// private
+ (id<DKDCommandFactory>)defaultFactory:(NSDictionary *)info {
    DKDSharedMessageExtensions *ext = [DKDSharedMessageExtensions sharedInstance];
    // get factory by content type
    NSString *type = [ext.helper getContentType:info defaultValue:nil];
    if ([type length] > 0) {
        id factory = [ext.contentHelper getContentFactory:type];
        if ([factory conformsToProtocol:@protocol(DKDCommandFactory)]) {
            return factory;
        }
    }
    NSAssert(false, @"cannot parse command: %@", info);
    return nil;
}

@end
