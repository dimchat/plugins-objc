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
//  DIMPluginLoader.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/DIMCore.h>

#import "DIMDigesters.h"
#import "DIMDataCoders.h"
#import "DIMDataParsers.h"

#import "DIMBase64Data.h"
#import "DIMBaseNetworkFile.h"

#import "DIMAESKey.h"
#import "DIMPlainKey.h"

#import "DIMECCPrivateKey.h"
#import "DIMECCPublicKey.h"
#import "DIMRSAPrivateKey.h"
#import "DIMRSAPublicKey.h"

#import "DIMIDFactory.h"
#import "DIMAddressFactory.h"
#import "DIMMetaFactory.h"
#import "DIMDocumentFactory.h"

#import "DIMPluginLoader.h"

@implementation DIMPluginLoader

- (void)load {
    
    [self registerCoders];
    [self registerDigesters];
    
    [self registerSymmetricKeyFactories];
    [self registerAsymmetricKeyFactories];
    
    [self registerEntityFactories];
    
}

@end

@implementation DIMPluginLoader (DataCoder)

- (void)registerCoders {
    
    [self registerBase58Coder];
    [self registerBase64Coder];
    [self registerHexCoder];
    
    [self registerUTF8Coder];
    [self registerJSONCoder];
    
    [self registerPNFFactory];
    [self registerTEDFactory];
    
}

- (void)registerBase58Coder {
    // Base58 coding
    id<MKDataCoder> coder = [[DIMBase58Coder alloc] init];
    [MKBase58 setCoder:coder];
}

- (void)registerBase64Coder {
    // Base64 coding
    id<MKDataCoder> coder = [[DIMBase64Coder alloc] init];
    [MKBase64 setCoder:coder];
}

- (void)registerHexCoder {
    // HEX coding
    id<MKDataCoder> coder = [[DIMHexCoder alloc] init];
    [MKHex setCoder:coder];
}

- (void)registerUTF8Coder {
    // UTF8
    id<MKStringCoder> coder = [[DIMUTF8Coder alloc] init];
    [MKUTF8 setCoder:coder];
}

- (void)registerJSONCoder {
    // JSON
    id<MKObjectCoder> coder = [[DIMJSONCoder alloc] init];
    [MKJSON setCoder:coder];
}

- (void)registerPNFFactory {
    // PNF
    id<MKPortableNetworkFileFactory> factory = [[DIMBaseFileFactory alloc] init];
    MKPortableNetworkFileSetFactory(factory);
}

- (void)registerTEDFactory {
    // TED
    id<MKTransportableDataFactory> factory = [[DIMBase64DataFactory alloc] init];
    MKTransportableDataSetFactory(MKEncodeAlgorithm_BASE64, factory);
    //MKTransportableDataSetFactory(MKEncodeAlgorithm_Default, factory);
    MKTransportableDataSetFactory(@"*", factory);
}

@end

@implementation DIMPluginLoader (MessageDigest)

- (void)registerDigesters {
    
    [self registerSHA256Digester];
    
    [self registerKECCAK256Digester];
    
    [self registerRIPEMD160Digester];
    
}

- (void)registerSHA256Digester {
    // SHA256
    id<MKMessageDigester> md = [[DIMSHA256Digester alloc] init];
    [MKSHA256 setDigester:md];
}

- (void)registerKECCAK256Digester {
    // Keccak256
    id<MKMessageDigester> md = [[DIMKECCAK256Digester alloc] init];
    [MKKECCAK256 setDigester:md];
}

- (void)registerRIPEMD160Digester {
    // RIPEMD160
    id<MKMessageDigester> md = [[DIMRIPEMD160Digester alloc] init];
    [MKRIPEMD160 setDigester:md];
}

@end

@implementation DIMPluginLoader (SymmetricKey)

- (void)registerSymmetricKeyFactories {
    
    [self registerAESKeyFactory];
    
    [self registerPlainKeyFactory];
    
}

- (void)registerAESKeyFactory {
    // AES
    id<MKSymmetricKeyFactory> factory = [[DIMAESKeyFactory alloc] init];
    MKSymmetricKeySetFactory(MKSymmetricAlgorithm_AES, factory);
    MKSymmetricKeySetFactory(@"AES/CBC/PKCS7Padding", factory);
}

- (void)registerPlainKeyFactory {
    // Plain
    id<MKSymmetricKeyFactory> factory = [[DIMPlainKeyFactory alloc] init];
    MKSymmetricKeySetFactory(MKSymmetricAlgorithm_Plain, factory);
}

@end

@implementation DIMPluginLoader (AsymmetricKey)

- (void)registerAsymmetricKeyFactories {
    
    [self registerRSAKeyFactories];
    
    [self registerECCKeyFactories];
    
}

- (void)registerRSAKeyFactories {
    // RSA
    id<MKPublicKeyFactory> pub = [[DIMRSAPublicKeyFactory alloc] init];
    MKPublicKeySetFactory(MKAsymmetricAlgorithm_RSA, pub);
    MKPublicKeySetFactory(@"SHA256withRSA", pub);
    MKPublicKeySetFactory(@"RSA/ECB/PKCS1Padding", pub);
    
    id<MKPrivateKeyFactory> pri = [[DIMRSAPrivateKeyFactory alloc] init];
    MKPrivateKeySetFactory(MKAsymmetricAlgorithm_RSA, pri);
    MKPrivateKeySetFactory(@"SHA256withRSA", pri);
    MKPrivateKeySetFactory(@"RSA/ECB/PKCS1Padding", pri);
}

- (void)registerECCKeyFactories {
    // ECC
    id<MKPublicKeyFactory> pub = [[DIMECCPublicKeyFactory alloc] init];
    MKPublicKeySetFactory(MKAsymmetricAlgorithm_ECC, pub);
    MKPublicKeySetFactory(@"SHA256withECDSA", pub);
    
    id<MKPrivateKeyFactory> pri = [[DIMECCPrivateKeyFactory alloc] init];
    MKPrivateKeySetFactory(MKAsymmetricAlgorithm_ECC, pri);
    MKPrivateKeySetFactory(@"SHA256withECDSA", pri);
}

@end

static inline void _set_meta_factory(NSString *type, NSString *alias) {
    id<MKMMetaFactory> factory = [[DIMMetaFactory alloc] initWithType:type];
    MKMMetaSetFactory(type, factory);
    MKMMetaSetFactory(alias, factory);
}

static inline void _set_doc_factory(NSString *type) {
    id<MKMDocumentFactory> factory = [[DIMDocumentFactory alloc] initWithType:type];
    MKMDocumentSetFactory(type, factory);
}

@implementation DIMPluginLoader (Entity)

- (void)registerEntityFactories {
    
    [self registerIDFactory];
    [self registerAddressFactory];
    [self registerMetaFactories];
    [self registerDocumentFactories];
    
}

- (void)registerIDFactory {
    MKMIDSetFactory([[DIMIDFactory alloc] init]);
}

- (void)registerAddressFactory {
    MKMAddressSetFactory([[DIMAddressFactory alloc] init]);
}

- (void)registerMetaFactories {
    _set_meta_factory(MKMMetaType_MKM, @"mkm");
    _set_meta_factory(MKMMetaType_BTC, @"btc");
    _set_meta_factory(MKMMetaType_ETH, @"eth");
}

- (void)registerDocumentFactories {
    _set_doc_factory(@"*");
    _set_doc_factory(MKMDocumentType_Visa);
    _set_doc_factory(MKMDocumentType_Profile);
    _set_doc_factory(MKMDocumentType_Bulletin);
}

@end
