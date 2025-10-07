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
//  DIMCommandFactories.m
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import "DIMCommandFactories.h"

@implementation DIMGeneralCommandFactory

// Override
- (nullable __kindof id<DKDContent>)parseContent:(NSDictionary *)content {
    DIMSharedCommandExtensions *ext = [DIMSharedCommandExtensions sharedInstance];
    // get factory by command name
    NSString *cmd = [ext.helper getCmd:content defaultValue:nil];
    id<DKDCommandFactory> factory = nil;
    if ([cmd length] > 0) {
        factory = [ext.cmdHelper getCommandFactory:cmd];
    }
    if (!factory) {
        // check for group command
        if ([content objectForKey:@"group"]) {
            factory = [ext.cmdHelper getCommandFactory:@"group"];
        }
        if (!factory) {
            factory = self;
        }
    }
    return [factory parseCommand:content];
}

// Override
- (nullable id<DKDCommand>)parseCommand:(NSDictionary *)content {
    // check 'sn', 'command'
    if ([content objectForKey:@"sn"] && [content objectForKey:@"command"]) {
        // OK
        return [[DIMCommand alloc] initWithDictionary:content];
    } else {
        // content.sn should not be empty
        // content.command should not be empty
        NSAssert(false, @"command error: %@", content);
        return nil;
    }
}

@end

@implementation DIMHistoryCommandFactory

// Override
- (nullable id<DKDCommand>)parseCommand:(NSDictionary *)content {
    // check 'sn', 'command', 'time'
    if ([content objectForKey:@"sn"] && [content objectForKey:@"command"] && [content objectForKey:@"time"]) {
        // OK
        return [[DIMHistoryCommand alloc] initWithDictionary:content];
    } else {
        // content.sn should not be empty
        // content.command should not be empty
        // content.time should not be empty
        NSAssert(false, @"command error: %@", content);
        return nil;
    }
}

@end

@implementation DIMGroupCommandFactory

// Override
- (nullable __kindof id<DKDContent>)parseContent:(NSDictionary *)content {
    DIMSharedCommandExtensions *ext = [DIMSharedCommandExtensions sharedInstance];
    // get factory by command name
    NSString *cmd = [ext.helper getCmd:content defaultValue:nil];
    id<DKDCommandFactory> factory = nil;
    if ([cmd length] > 0) {
        factory = [ext.cmdHelper getCommandFactory:cmd];
    }
    if (!factory) {
        factory = self;
    }
    return [factory parseCommand:content];
}

// Override
- (nullable id<DKDCommand>)parseCommand:(NSDictionary *)content {
    // check 'sn', 'command', 'group'
    if ([content objectForKey:@"sn"] && [content objectForKey:@"command"] && [content objectForKey:@"group"]) {
        // OK
        return [[DIMGroupCommand alloc] initWithDictionary:content];
    } else {
        // content.sn should not be empty
        // content.command should not be empty
        // content.group should not be empty
        NSAssert(false, @"group command error: %@", content);
        return nil;
    }
}

@end
