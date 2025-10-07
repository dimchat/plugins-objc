// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
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
//  DIMPlainKey.h
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Symmetric key for broadcast message,
 *  which will do nothing when en/decoding message data
 *
 *      keyInfo forma t: {
 *          algorithm : "PLAIN",
 *          data      : ""       // empty data
 *      }
 */
@interface DIMPlainKey : DIMSymmetricKey

+ (instancetype)sharedInstance;

@end

@interface DIMPlainKeyFactory : NSObject <MKSymmetricKeyFactory>

@end

NS_ASSUME_NONNULL_END
