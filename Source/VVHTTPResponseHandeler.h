//
//  VVHTTPResponseHandeler.h
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVHTTPConfig.h"

@interface VVHTTPResponseHandeler : NSObject

@property(nonatomic, readonly) VVHTTPResponseHead *responseHead;
@property(nonatomic, readonly) VVHTTPRequestHead *requestHead;
@property(nonatomic, readonly) NSError *error;
@property(nonatomic, readonly) u_int64_t bodyDataOffset;
@property(nonatomic, readonly) u_int64_t bodyDataLength;


+ (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head;

+ (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head
                           delegate:(id <VVHTTPResponseDelegate>)delegate
                            rootDir:(NSString *)dir;

- (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head;

- (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head
                           delegate:(id <VVHTTPResponseDelegate>)delegate
                            rootDir:(NSString *)dir;


- (BOOL)shouldConnectKeepLive;

- (BOOL)bodyEnd;

- (NSData *)readAllHeadData;

- (NSData *)readBodyData;

@end


@interface VVHTTPResponseHead (ZGHTTPPrivateAPI)

+ (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head;

+ (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head;

- (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head;

- (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head;

- (void)setHeadValue:(NSString *)value WithField:(NSString *)field;

- (NSData *)dataOfHead;

- (void)setPro:(NSString *)pro;

- (void)setVersion:(NSString *)version;

- (void)setStateCode:(NSInteger)stateCode;

- (void)setStateDesc:(NSString *)stateDesc;

- (void)setHeadDict:(NSDictionary *)headDic;

@end
