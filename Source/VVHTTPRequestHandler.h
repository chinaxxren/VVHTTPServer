//
//  VVHTTPRequestHandler.h
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVHTTPConfig.h"


@interface VVHTTPRequestHandler : NSObject

@property(nonatomic, readonly) VVHTTPRequestHead *requestHead;
@property(nonatomic, readonly) u_int64_t bodyDataLength;
@property(nonatomic, readonly) u_int64_t bodyDataOffset;


+ (instancetype)initWithHeadData:(NSData *)data
                        delegate:(id <VVHTTPRequestDelegate>)delegate
                         rootDir:(NSString *)dir;

- (instancetype)initWithHeadData:(NSData *)data
                        delegate:(id <VVHTTPRequestDelegate>)delegate
                         rootDir:(NSString *)dir;

//- (NSError *)refuseError;
- (NSError *)invalidError;

- (BOOL)isRequestFinish;

- (void)writeBodyData:(NSData *)data;

- (void)writeBodyDataError:(NSError *)error;

@end


@interface VVHTTPRequestHead (ZGHTTPPrivateAPI)

+ (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithData:(NSData *)data;

- (void)setMethod:(NSString *)method;

- (void)setPath:(NSString *)path;

- (void)setProtocol:(NSString *)pro;

- (void)setVersion:(NSString *)version;

- (void)setHost:(NSString *)host;

- (void)setHeadDict:(NSDictionary *)headDict;

- (BOOL)hasRangeHead;

- (NSRange)range;

@end
