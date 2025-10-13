// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
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
//  DIMExtensionLoader.h
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMExtensionLoader : NSObject

/**
 *  Register core factories
 */
- (void)load;

@end

// protected
@interface DIMExtensionLoader (Core)

- (void)registerCoreHelpers;

- (void)registerCryptoHelpers;
- (void)registerFormatHelpers;
- (void)registerAccountHelpers;
- (void)registerMessageHelpers;
- (void)registerCommandHelpers;

@end

// protected
@interface DIMExtensionLoader (Message)

- (void)registerMessageFactories;

@end

// protected
@interface DIMExtensionLoader (Content)

- (void)registerContentFactories;

- (void)registerCustomizedFactories;

//- (void)setContentFactory:(id<DKDContentFactory>)factory forType:(NSString *)type;

@end

// protected
@interface DIMExtensionLoader (Command)

- (void)registerCommandFactories;

//- (void)setCommandFactory:(id<DKDCommandFactory>)factory forCmd:(NSString *)cmd;

@end

#pragma mark -

typedef id<DKDContent>_Nullable(^DIMContentParserBlock)(NSDictionary *content);

/**
 *  Base Content Factory
 *  ~~~~~~~~~~~~~~~~~~~~
 */
@interface DIMContentFactory : NSObject <DKDContentFactory>

@property (readonly, nonatomic, nullable) DIMContentParserBlock block;

- (instancetype)initWithBlock:(DIMContentParserBlock)block
NS_DESIGNATED_INITIALIZER;

@end

#define DIMContentFactoryWithBlock(block)                                      \
            [[DIMContentFactory alloc] initWithBlock:(block)]                  \
                                   /* EOF 'DIMContentFactoryWithBlock(block)' */

#define DIMContentFactoryWithClass(clazz)                                      \
            DIMContentFactoryWithBlock(^(NSDictionary *content) {              \
                return [[clazz alloc] initWithDictionary:content];             \
            })                                                                 \
                                   /* EOF 'DIMContentFactoryWithClass(clazz)' */

#define DIMContentRegister(type, factory)                                      \
            DKDContentSetFactory(type, factory)                                \
                            /* EOF 'DIMContentFactoryRegister(type, factory)' */

#define DIMContentRegisterBlock(type, block)                                   \
            DKDContentSetFactory((type), DIMContentFactoryWithBlock(block))    \
                                /* EOF 'DIMContentRegisterBlock(type, block)' */

#define DIMContentRegisterClass(type, clazz)                                   \
            DKDContentSetFactory((type), DIMContentFactoryWithClass(clazz))    \
                                /* EOF 'DIMContentRegisterClass(type, clazz)' */

#pragma mark -

typedef id<DKDCommand>_Nullable(^DIMCommandParserBlock)(NSDictionary *content);

/**
 *  Base Command Factory
 *  ~~~~~~~~~~~~~~~~~~~~
 */
@interface DIMCommandFactory : NSObject <DKDCommandFactory>

@property (readonly, nonatomic) DIMCommandParserBlock block;

- (instancetype)initWithBlock:(DIMCommandParserBlock)block
NS_DESIGNATED_INITIALIZER;

@end

#define DIMCommandFactoryWithBlock(block)                                      \
            [[DIMCommandFactory alloc] initWithBlock:(block)]                  \
                                   /* EOF 'DIMCommandFactoryWithBlock(block)' */

#define DIMCommandFactoryWithClass(clazz)                                      \
            DIMCommandFactoryWithBlock(^(NSDictionary *content) {              \
                return [[clazz alloc] initWithDictionary:content];             \
            })                                                                 \
                                   /* EOF 'DIMCommandFactoryWithClass(clazz)' */

#define DIMCommandRegister(name, factory)                                      \
            DKDCommandSetFactory(name, factory)                                \
                            /* EOF 'DIMCommandRegister(name, factory)' */

#define DIMCommandRegisterBlock(name, block)                                   \
            DKDCommandSetFactory((name), DIMCommandFactoryWithBlock(block))    \
                                /* EOF 'DIMCommandRegisterBlock(name, block)' */

#define DIMCommandRegisterClass(name, clazz)                                   \
            DKDCommandSetFactory((name), DIMCommandFactoryWithClass(clazz))    \
                                /* EOF 'DIMCommandRegisterClass(name, clazz)' */

NS_ASSUME_NONNULL_END
