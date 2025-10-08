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
//  DIMPluginLoader.h
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMPluginLoader : NSObject

/**
 *  Register plugins
 */
- (void)load;

@end

// protected
@interface DIMPluginLoader (DataCoder)

- (void)registerCoders;

- (void)registerBase58Coder;
- (void)registerBase64Coder;
- (void)registerHexCoder;
- (void)registerUTF8Coder;
- (void)registerJSONCoder;
- (void)registerPNFFactory;
- (void)registerTEDFactory;

@end

// protected
@interface DIMPluginLoader (MessageDigest)

- (void)registerDigesters;

- (void)registerSHA256Digester;
- (void)registerKECCAK256Digester;
- (void)registerRIPEMD160Digester;

@end

// protected
@interface DIMPluginLoader (SymmetricKey)

- (void)registerSymmetricKeyFactories;

- (void)registerAESKeyFactory;
- (void)registerPlainKeyFactory;

@end

// protected
@interface DIMPluginLoader (AsymmetricKey)

- (void)registerAsymmetricKeyFactories;

- (void)registerRSAKeyFactories;
- (void)registerECCKeyFactories;

@end

// protected
@interface DIMPluginLoader (Entity)

- (void)registerEntityFactories;

- (void)registerIDFactory;
- (void)registerAddressFactory;
- (void)registerMetaFactories;
- (void)registerDocumentFactories;

@end

NS_ASSUME_NONNULL_END
