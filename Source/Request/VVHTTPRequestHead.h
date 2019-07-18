//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VVHTTPRequestHead : NSObject

@property(nonatomic, copy) NSString *method;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *pro;
@property(nonatomic, copy) NSString *version;
@property(nonatomic, copy) NSString *host;
@property(nonatomic, strong) NSDictionary *headDict;

@end

@interface VVHTTPRequestHead (NSData)

+ (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithData:(NSData *)data;

- (BOOL)hasRangeHead;

- (NSRange)range;

@end
