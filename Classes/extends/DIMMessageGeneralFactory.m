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
//  DIMMessageGeneralFactory.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/DIMCore.h>

#import "DIMMessageGeneralFactory.h"

@interface DIMMessageGeneralFactory () {
    
    NSMutableDictionary<NSString *, id<DKDContentFactory>> *_contentFactories;
    
    id<DKDEnvelopeFactory>        _envelopeFactory;
    id<DKDInstantMessageFactory>  _instantMessageFactory;
    id<DKDSecureMessageFactory>   _secureMessageFactory;
    id<DKDReliableMessageFactory> _reliableMessageFactory;
}

@end

@implementation DIMMessageGeneralFactory

- (instancetype)init {
    if (self = [super init]) {
        _contentFactories = [[NSMutableDictionary alloc] init];
        _envelopeFactory        = nil;
        _instantMessageFactory  = nil;
        _secureMessageFactory   = nil;
        _reliableMessageFactory = nil;
    }
    return self;
}

// Override
- (nullable NSString *)getContentType:(NSDictionary<NSString *,id> *)content
                         defaultValue:(nullable NSString *)aValue {
    id type = [content objectForKey:@"type"];
    return MKConvertString(type, aValue);
}

#pragma mark Content

// Override
- (void)setContentFactory:(id<DKDContentFactory>)factory forType:(NSString *)type {
    [_contentFactories setObject:factory forKey:type];
}

// Override
- (nullable id<DKDContentFactory>)getContentFactory:(NSString *)type {
    return [_contentFactories objectForKey:type];
}

// Override
- (id<DKDContent>)parseContent:(nullable id)content {
    if (!content) {
        return nil;
    } else if ([content conformsToProtocol:@protocol(DKDContent)]) {
        return content;
    }
    NSDictionary *info = MKGetMap(content);
    if (!info) {
        NSAssert(false, @"content error: %@", content);
        return nil;
    }
    // get factory by content type
    NSString *type = [self getContentType:info defaultValue:nil];
    NSAssert([type length] > 0, @"content error: %@", content);
    id<DKDContentFactory> factory = [self getContentFactory:type];
    if (!factory) {
        // unknown content type, get default content factory
        factory = [self getContentFactory:@"*"];  // unknown
        NSAssert(factory, @"default content factory not found");
    }
    return [factory parseContent:info];
}

#pragma mark Envelope

// Override
- (void)setEnvelopeFactory:(id<DKDEnvelopeFactory>)factory {
    _envelopeFactory = factory;
}

// Override
- (nullable id<DKDEnvelopeFactory>)getEnvelopeFactory {
    return _envelopeFactory;
}

// Override
- (id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                   receiver:(id<MKMID>)to
                                       time:(nullable NSDate *)when {
    id<DKDEnvelopeFactory> factory = [self getEnvelopeFactory];
    NSAssert(factory, @"envelope factory not ready");
    return [factory createEnvelopeWithSender:from receiver:to time:when];
}

// Override
- (nullable id<DKDEnvelope>)parseEnvelope:(nullable id)env {
    if (!env) {
        return nil;
    } else if ([env conformsToProtocol:@protocol(DKDEnvelope)]) {
        return env;
    }
    NSDictionary *info = MKGetMap(env);
    if (!info) {
        NSAssert(false, @"envelope error: %@", env);
        return nil;
    }
    id<DKDEnvelopeFactory> factory = [self getEnvelopeFactory];
    NSAssert(factory, @"envelope factory not ready");
    return [factory parseEnvelope:info];
}

#pragma mark InstantMessage

// Override
- (void)setInstantMessageFactory:(id<DKDInstantMessageFactory>)factory {
    _instantMessageFactory = factory;
}

// Override
- (nullable id<DKDInstantMessageFactory>)getInstantMessageFactory {
    return _instantMessageFactory;
}

// Override
- (id<DKDInstantMessage>)createInstantMessageWithEnvelope:(id<DKDEnvelope>)head
                                                  content:(id<DKDContent>)body {
    id<DKDInstantMessageFactory> factory = [self getInstantMessageFactory];
    NSAssert(factory, @"instant message factory not ready");
    return [factory createInstantMessageWithEnvelope:head content:body];
}

// Override
- (DKDSerialNumber)generateSerialNumberForType:(NSString *)type time:(NSDate *)now {
    id<DKDInstantMessageFactory> factory = [self getInstantMessageFactory];
    NSAssert(factory, @"instant message factory not ready");
    return [factory generateSerialNumberForType:type time:now];
}

// Override
- (nullable id<DKDInstantMessage>)parseInstantMessage:(nullable id)msg {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDInstantMessage)]) {
        return msg;
    }
    NSDictionary *info = MKGetMap(msg);
    if (!info) {
        NSAssert(false, @"instant message error: %@", msg);
        return nil;
    }
    id<DKDInstantMessageFactory> factory = [self getInstantMessageFactory];
    NSAssert(factory, @"instant message factory not ready");
    return [factory parseInstantMessage:info];
}

#pragma mark SecureMessage

// Override
- (void)setSecureMessageFactory:(id<DKDSecureMessageFactory>)factory {
    _secureMessageFactory = factory;
}

// Override
- (nullable id<DKDSecureMessageFactory>)getSecureMessageFactory {
    return _secureMessageFactory;
}

// Override
- (nullable id<DKDSecureMessage>)parseSecureMessage:(nullable id)msg {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDSecureMessage)]) {
        return msg;
    }
    NSDictionary *info = MKGetMap(msg);
    if (!info) {
        NSAssert(false, @"secure message error: %@", msg);
        return nil;
    }
    id<DKDSecureMessageFactory> factory = [self getSecureMessageFactory];
    NSAssert(factory, @"secure message factory not ready");
    return [factory parseSecureMessage:info];
}

#pragma mark ReliableMessage

// Override
- (void)setReliableMessageFactory:(id<DKDReliableMessageFactory>)factory {
    _reliableMessageFactory = factory;
}

// Override
- (nullable id<DKDReliableMessageFactory>)getReliableMessageFactory {
    return _reliableMessageFactory;
}

// Override
- (nullable id<DKDReliableMessage>)parseReliableMessage:(nullable id)msg {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDReliableMessage)]) {
        return msg;
    }
    NSDictionary *info = MKGetMap(msg);
    if (!info) {
        NSAssert(false, @"reliable message error: %@", msg);
        return nil;
    }
    id<DKDReliableMessageFactory> factory = [self getReliableMessageFactory];
    NSAssert(factory, @"reliable message factory not ready");
    return [factory parseReliableMessage:info];
}

@end
