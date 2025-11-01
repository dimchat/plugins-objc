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
//  DIMExtensionLoader.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import "DIMCryptoKeyGeneralFactory.h"
#import "DIMFormatGeneralFactory.h"
#import "DIMAccountGeneralFactory.h"
#import "DIMMessageGeneralFactory.h"
#import "DIMCommandGeneralFactory.h"

#import "DIMCommandFactories.h"
#import "DIMMessageFactories.h"

#import "DIMExtensionLoader.h"

@implementation DIMExtensionLoader

- (void)load {
    
    [self registerCoreHelpers];
    
    [self registerMessageFactories];
    
    [self registerContentFactories];
    [self registerCommandFactories];
    
}

@end

@implementation DIMExtensionLoader (Core)

- (void)registerCoreHelpers {
    
    [self registerCryptoHelpers];
    [self registerFormatHelpers];
    
    [self registerAccountHelpers];
    
    [self registerMessageHelpers];
    [self registerCommandHelpers];
    
}

- (void)registerCryptoHelpers {
    // crypto
    DIMCryptoKeyGeneralFactory *helper = [[DIMCryptoKeyGeneralFactory alloc] init];
    MKSharedCryptoExtensions *ext = [MKSharedCryptoExtensions sharedInstance];
    [ext setSymmetricHelper:helper];
    [ext setPrivateHelper:helper];
    [ext setPublicHelper:helper];
    [ext setHelper:helper];
}

- (void)registerFormatHelpers {
    // format
    DIMFormatGeneralFactory *helper = [[DIMFormatGeneralFactory alloc] init];
    MKSharedFormatExtensions *ext = [MKSharedFormatExtensions sharedInstance];
    [ext setPnfHelper:helper];
    [ext setTedHelper:helper];
    [ext setHelper:helper];
}

- (void)registerAccountHelpers {
    // mkm
    DIMAccountGeneralFactory *helper = [[DIMAccountGeneralFactory alloc] init];
    MKMSharedAccountExtensions *ext = [MKMSharedAccountExtensions sharedInstance];
    [ext setAddressHelper:helper];
    [ext setIdHelper:helper];
    [ext setMetaHelper:helper];
    [ext setDocHelper:helper];
    [ext setHelper:helper];
}

- (void)registerMessageHelpers {
    // dkd
    DIMMessageGeneralFactory *helper = [[DIMMessageGeneralFactory alloc] init];
    DKDSharedMessageExtensions *ext = [DKDSharedMessageExtensions sharedInstance];
    [ext setContentHelper:helper];
    [ext setEnvelopeHelper:helper];
    [ext setInstantHelper:helper];
    [ext setSecureHelper:helper];
    [ext setReliableHelper:helper];
    [ext setHelper:helper];
}

- (void)registerCommandHelpers {
    // cmd
    DIMCommandGeneralFactory *helper = [[DIMCommandGeneralFactory alloc] init];
    DKDSharedCommandExtensions *ext = [DKDSharedCommandExtensions sharedInstance];
    [ext setCmdHelper:helper];
    [ext setHelper:helper];
}

@end

@implementation DIMExtensionLoader (Message)

- (void)registerMessageFactories {
    
    // Envelope factory
    DKDEnvelopeSetFactory([[DIMEnvelopeFactory alloc] init]);
    
    // Message factories
    DKDInstantMessageSetFactory([[DIMInstantMessageFactory alloc] init]);
    DKDSecureMessageSetFactory([[DIMSecureMessageFactory alloc] init]);
    DKDReliableMessageSetFactory([[DIMReliableMessageFactory alloc] init]);
    
}

@end

@implementation DIMExtensionLoader (Content)

- (void)registerContentFactories {
    
    // Text
    DIMContentRegisterClass(DKDContentType_Text, DIMTextContent);
    
    // File
    DIMContentRegisterClass(DKDContentType_File, DIMFileContent);
    // Image
    DIMContentRegisterClass(DKDContentType_Image, DIMImageContent);
    // Audio
    DIMContentRegisterClass(DKDContentType_Audio, DIMAudioContent);
    // Video
    DIMContentRegisterClass(DKDContentType_Video, DIMVideoContent);
    
    // Web Page
    DIMContentRegisterClass(DKDContentType_Page, DIMPageContent);
    
    // Name Card
    DIMContentRegisterClass(DKDContentType_NameCard, DIMNameCard);
    
    // Quote
    DIMContentRegisterClass(DKDContentType_Quote, DIMQuoteContent);
    
    // Money
    DIMContentRegisterClass(DKDContentType_Money, DIMMoneyContent);
    DIMContentRegisterClass(DKDContentType_Transfer, DIMTransferContent);
    
    // Command
    id<DKDContentFactory> cmdFact = [[DIMGeneralCommandFactory alloc] init];
    DIMContentRegister(DKDContentType_Command, cmdFact);
    
    // History Command
    id<DKDContentFactory> hisFact = [[DIMHistoryCommandFactory alloc] init];
    DIMContentRegister(DKDContentType_History, hisFact);
    
    // Content Array
    DIMContentRegisterClass(DKDContentType_Array, DIMArrayContent);

    // Top-Secret
    DIMContentRegisterClass(DKDContentType_Forward, DIMForwardContent);

    // unknown content type
    DIMContentRegisterClass(DKDContentType_Any, DIMContent);
    
    // Application Customized Content
    [self registerCustomizedFactories];
}

- (void)registerCustomizedFactories {

    // Application Customized
    DIMContentRegisterClass(DKDContentType_Customized, DIMCustomizedContent);
    //DIMContentRegisterClass(DKDContentType_Application, DIMCustomizedContent);

}

//- (void)setContentFactory:(id<DKDContentFactory>)factory forType:(NSString *)type {
//    
//}

@end

@implementation DIMExtensionLoader (Command)

//- (void)setCommandFactory:(id<DKDCommandFactory>)factory forCmd:(NSString *)cmd {
//    
//}

- (void)registerCommandFactories {
    
    // Meta Command
    DIMCommandRegisterClass(DKDCommand_Meta, DIMMetaCommand);

    // Document Command
    DIMCommandRegisterClass(DKDCommand_Documents, DIMDocumentCommand);
    
    // Receipt Command
    DIMCommandRegisterClass(DKDCommand_Receipt, DIMReceiptCommand);

    // Group Commands
    DIMCommandRegister(@"group", [[DIMGroupCommandFactory alloc] init]);
    DIMCommandRegisterClass(DKDGroupCommand_Invite, DIMInviteGroupCommand);
    // 'expel' is deprecated (use 'reset' instead)
    DIMCommandRegisterClass(DKDGroupCommand_Expel, DIMExpelGroupCommand);
    DIMCommandRegisterClass(DKDGroupCommand_Join, DIMJoinGroupCommand);
    DIMCommandRegisterClass(DKDGroupCommand_Quit, DIMQuitGroupCommand);
    //DIMCommandRegisterClass(DKDGroupCommand_Query, DIMQueryGroupCommand);
    DIMCommandRegisterClass(DKDGroupCommand_Reset, DIMResetGroupCommand);
    // Group Admin Commands
    DIMCommandRegisterClass(DKDGroupCommand_Hire, DIMHireGroupCommand);
    DIMCommandRegisterClass(DKDGroupCommand_Fire, DIMFireGroupCommand);
    DIMCommandRegisterClass(DKDGroupCommand_Resign, DIMResignGroupCommand);
    
}

@end

#pragma mark -

@interface DIMContentFactory () {
    
    DIMContentParserBlock _block;
}

@end

@implementation DIMContentFactory

- (instancetype)init {
    NSAssert(false, @"don't call me!");
    DIMContentParserBlock block = NULL;
    return [self initWithBlock:block];
}

/* NS_DESIGNATED_INITIALIZER */
- (instancetype)initWithBlock:(DIMContentParserBlock)block {
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (nullable id<DKDContent>)parseContent:(NSDictionary *)content {
    return _block(content);
}

@end

#pragma mark -

@interface DIMCommandFactory () {
    
    DIMCommandParserBlock _block;
}

@end

@implementation DIMCommandFactory

- (instancetype)init {
    NSAssert(false, @"don't call me!");
    DIMCommandParserBlock block = NULL;
    return [self initWithBlock:block];
}

/* NS_DESIGNATED_INITIALIZER */
- (instancetype)initWithBlock:(DIMCommandParserBlock)block {
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (nullable id<DKDCommand>)parseCommand:(NSDictionary *)content {
    return _block(content);
}

@end
