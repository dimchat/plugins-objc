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
//  DIMFormatGeneralFactory.h
//  DIMPlugins
//
//  Created by Albert Moky on 2025/10/8.
//

#import <DIMCore/Ext.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMFormatGeneralFactory : NSObject <MKGeneralFormatHelper,
                                               MKPortableNetworkFileHelper,
                                               MKTransportableDataHelper>

@end

// protected
@interface DIMFormatGeneralFactory (Convenience)

/**
 *  Parse PNF
 */
- (nullable NSDictionary *)parseURL:(nullable id)pnf;

/**
 *  Parse TED
 */
- (nullable NSDictionary *)parseData:(nullable id)ted;

- (nullable NSDictionary *)getMap:(nullable id)value;

- (nullable NSDictionary *)parseDataURI:(nullable NSString *)text;

@end

#pragma mark -

/**
 *  "data:image/png;base64,{BASE64_ENCODE}"
 */
@interface DIMDataURI : NSObject

@property (readonly, strong, nonatomic, nullable) NSString *mimeType;
@property (readonly, strong, nonatomic, nullable) NSString *encoding;
@property (readonly, strong, nonatomic) NSString *body;

// toMap()
@property (readonly, copy, nonatomic) NSDictionary *dictionary;

- (instancetype)initWithType:(nullable NSString *)mimeType
                    encoding:(nullable NSString *)algorithm
                        body:(NSString *)data
NS_DESIGNATED_INITIALIZER;

/**
 *  Split text string for data URI
 *
 *      0. "{TEXT}", or "{URL}"
 *      1. "base64,{BASE64_ENCODE}"
 *      2. "data:image/png;base64,{BASE64_ENCODE}"
 */
+ (instancetype)parse:(nullable NSString *)text;

/**
 *  Build data URI
 *
 *      format: "data:image/png;base64,{BASE64_ENCODE}"
 */
+ (nullable NSString *)build:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
