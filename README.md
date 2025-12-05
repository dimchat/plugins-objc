# DIM Plugins (Objective-C)

[![License](https://img.shields.io/github/license/dimchat/plugins-objc)](https://github.com/dimchat/plugins-objc/blob/main/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dimchat/plugins-objc/pulls)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20OSX%20%7C%20watchOS%20%7C%20tvOS-brightgreen.svg)](https://github.com/dimchat/plugins-objc/wiki)
[![Issues](https://img.shields.io/github/issues/dimchat/plugins-objc)](https://github.com/dimchat/plugins-objc/issues)
[![Repo Size](https://img.shields.io/github/repo-size/dimchat/plugins-objc)](https://github.com/dimchat/plugins-objc/archive/refs/heads/main.zip)
[![Tags](https://img.shields.io/github/tag/dimchat/plugins-objc)](https://github.com/dimchat/plugins-objc/tags)
[![Version](https://img.shields.io/cocoapods/v/DIMPlugins
)](https://cocoapods.org/pods/DIMPlugins)

[![Watchers](https://img.shields.io/github/watchers/dimchat/plugins-objc)](https://github.com/dimchat/plugins-objc/watchers)
[![Forks](https://img.shields.io/github/forks/dimchat/plugins-objc)](https://github.com/dimchat/plugins-objc/forks)
[![Stars](https://img.shields.io/github/stars/dimchat/plugins-objc)](https://github.com/dimchat/plugins-objc/stargazers)
[![Followers](https://img.shields.io/github/followers/dimchat)](https://github.com/orgs/dimchat/followers)

## Plugins

1. Data Coding
   * Base-58
   * Base-64
   * Hex
   * UTF-8
   * JsON
   * PNF _(Portable Network File)_
   * TED _(Transportable Encoded Data)_
2. Digest Digest
   * MD-5
   * SHA-1
   * SHA-256
   * Keccak-256
   * RipeMD-160
3. Cryptography
   * AES-256 _(AES/CBC/PKCS7Padding)_
   * RSA-1024 _(RSA/ECB/PKCS1Padding)_, _(SHA256withRSA)_
   * ECC _(Secp256k1)_
4. Address
   * BTC
   * ETH
5. Meta
   * MKM _(Default)_
   * BTC
   * ETH
6. Document
   * Visa _(User)_
   * Profile
   * Bulletin _(Group)_

## Extends

### Address

```objective-c
#import <DIMPlugins/DIMPlugins.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMCompatibleAddressFactory : DIMAddressFactory

@end

#pragma mark -

@interface DIMUnknownAddress : MKString <MKMAddress>

@end

NS_ASSUME_NONNULL_END
```

```objective-c
#import "DIMCompatibleAddressFactory.h"

@implementation DIMCompatibleAddressFactory

// Override
- (id<MKMAddress>)parse:(NSString *)address {
    NSComparisonResult res;
    NSUInteger len = [address length];
    if (len == 0) {
        NSAssert(false, @"address empty");
        return nil;
    } else if (len == 8) {
        // "anywhere"
        res = [MKMAnywhere.string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMAnywhere;
        }
    } else if (len == 10) {
        // "everywhere"
        res = [MKMEverywhere.string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMEverywhere;
        }
    }
    id<MKMAddress> addr;
    if (26 <= len && len <= 35) {
        // BTC address
        addr = [DIMBTCAddress parse:address];
    } else if (len == 42) {
        // ETH address
        addr = [DIMETHAddress parse:address];
    } else {
        NSAssert(false, @"invalid address: %@", address);
        addr = nil;
    }
    //
    //  TODO: parse for other types of address
    //
    if (addr == nil && 4 <= len && len <= 64) {
        return [[DIMUnknownAddress alloc] initWithString:address];
    }
    NSAssert(addr, @"invalid address: %@", address);
    return addr;
}

@end

#pragma mark -

@implementation DIMUnknownAddress

// Override
- (MKMEntityType)network {
    return MKMEntityType_User;  // 0
}

@end
```

### Meta

```objective-c
#import <DIMPlugins/DIMPlugins.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMCompatibleMetaFactory : DIMMetaFactory

@end

NS_ASSUME_NONNULL_END
```

```objective-c
#import "DIMCompatibleMetaFactory.h"

@implementation DIMCompatibleMetaFactory

// Override
- (nullable id<MKMMeta>)parseMeta:(NSDictionary *)info {
    id<MKMMeta> meta = nil;
    MKMSharedAccountExtensions *ext = [MKMSharedAccountExtensions sharedInstance];
    NSString *version = [ext.helper getMetaType:info defaultValue:nil];
    if ([version length] == 0) {
        NSAssert(false, @"meta type error: %@", info);
    } else if ([version isEqualToString:@"MKM"] ||
               [version isEqualToString:@"mkm"] ||
               [version isEqualToString:@"1"]) {
        meta = [[DIMDefaultMeta alloc] initWithDictionary:info];
    } else if ([version isEqualToString:@"BTC"] ||
               [version isEqualToString:@"btc"] ||
               [version isEqualToString:@"2"]) {
        meta = [[DIMBTCMeta alloc] initWithDictionary:info];
    } else if ([version isEqualToString:@"ETH"] ||
               [version isEqualToString:@"eth"] ||
               [version isEqualToString:@"4"]) {
        meta = [[DIMETHMeta alloc] initWithDictionary:info];
    } else {
        // TODO: other types of meta
        NSAssert(false, @"meta type not supported: %@", version);
    }
    return [meta isValid] ? meta : nil;
}

@end
```

### Plugin Loader

```objective-c
#import <DIMPlugins/DIMPlugins.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMCompatiblePluginLoader : DIMPluginLoader

@end

NS_ASSUME_NONNULL_END
```

```objective-c
#import "DIMCompatibleAddressFactory.h"
#import "DIMCompatibleMetaFactory.h"

#import "DIMCompatiblePluginLoader.h"

@implementation DIMCompatiblePluginLoader

// Override
- (void)registerAddressFactory {
    MKMAddressSetFactory([[DIMCompatibleAddressFactory alloc] init]);
}

// Override
- (void)registerMetaFactories {
    id mkm = [[DIMCompatibleMetaFactory alloc] initWithType:MKMMetaType_MKM];
    id btc = [[DIMCompatibleMetaFactory alloc] initWithType:MKMMetaType_BTC];
    id eth = [[DIMCompatibleMetaFactory alloc] initWithType:MKMMetaType_ETH];
    
    MKMMetaSetFactory(@"1", mkm);
    MKMMetaSetFactory(@"2", btc);
    MKMMetaSetFactory(@"4", eth);
    
    MKMMetaSetFactory(@"mkm", mkm);
    MKMMetaSetFactory(@"btc", btc);
    MKMMetaSetFactory(@"eth", eth);
    
    MKMMetaSetFactory(@"MKM", mkm);
    MKMMetaSetFactory(@"BTC", btc);
    MKMMetaSetFactory(@"ETH", eth);
}

@end
```

### ExtensionLoader

```objective-c
#import <DIMPlugins/DIMPlugins.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommonExtensionLoader : DIMExtensionLoader

@end

NS_ASSUME_NONNULL_END
```

```objective-c
#import "DIMHandshakeCommand.h"

#import "DIMCommonExtensionLoader.h"

@implementation DIMCommonExtensionLoader

// Override
- (void)registerCustomizedFactories {
    
    // Application Customized
    DIMContentRegisterClass(DKDContentType_Customized, DIMCustomizedContent);
    DIMContentRegisterClass(DKDContentType_Application, DIMCustomizedContent);

    // [super registerCustomizedFactories];
}

// Override
- (void)registerCommandFactories {
    [super registerCommandFactories];
    
    // Handshake
    DIMCommandRegisterClass(DKDCommand_Handshake, DIMHandshakeCommand);
    // ...
}

@end

```

## Usage

You must load all plugins before your business run:

```objective-c
#import <DIMPlugins/DIMPlugins.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMLibraryLoader : NSObject

@property (readonly, strong, nonatomic) __kindof DIMExtensionLoader *extensionLoader;
@property (readonly, strong, nonatomic) __kindof DIMPluginLoader *pluginLoader;

- (instancetype)initWithExtensionLoader:(DIMExtensionLoader *)extensionLoader
                        andPluginLoader:(DIMPluginLoader *)pluginLoader
NS_DESIGNATED_INITIALIZER;

- (void)run;

// protected
- (void)load;

@end

NS_ASSUME_NONNULL_END
```

```objective-c
#import "DIMCommonExtensionLoader.h"
#import "DIMCompatiblePluginLoader.h"

#import "DIMLibraryLoader.h"

@interface DIMLibraryLoader () {
    
    BOOL _loaded;
}

@property (strong, nonatomic) __kindof DIMExtensionLoader *extensionLoader;
@property (strong, nonatomic) __kindof DIMPluginLoader *pluginLoader;

@end

@implementation DIMLibraryLoader

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    DIMExtensionLoader *extensionLoader = nil;
    DIMPluginLoader *pluginLoader = nil;
    return [self initWithExtensionLoader:extensionLoader andPluginLoader:pluginLoader];
}

/* designated initializer */
- (instancetype)initWithExtensionLoader:(DIMExtensionLoader *)extensionLoader
                        andPluginLoader:(DIMPluginLoader *)pluginLoader {
    if (!extensionLoader) {
        extensionLoader = [[DIMCommonExtensionLoader alloc] init];
    }
    if (!pluginLoader) {
        pluginLoader = [[DIMCompatiblePluginLoader alloc] init];
    }
    if (self = [super init]) {
        self.extensionLoader = extensionLoader;
        self.pluginLoader = pluginLoader;
        _loaded = NO;
    }
    return self;
}

- (void)run {
    if (_loaded) {
        // no need to load it again
        return;
    } else {
        // mark it to loaded
        _loaded = YES;
    }
    // try to load all plugins
    [self load];
}

- (void)load {
    [self.extensionLoader load];
    [self.pluginLoader load];
}

@end
```

```objective-c

int main(int argc, char * argv[]) {
    DIMLibraryLoader *loader = [[DIMLibraryLoader alloc] init];
    [loader run];
    
    // do your jobs after all extensions & plugins loaded
}
```

You must ensure that every ```Address``` you extend has a ```Meta``` type that can correspond to it one by one.

----

Copyright &copy; 2018-2025 Albert Moky
[![Followers](https://img.shields.io/github/followers/moky)](https://github.com/moky?tab=followers)
