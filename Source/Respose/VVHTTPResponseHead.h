//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVHTTPRequestHead;


@interface VVHTTPResponseHead : NSObject

@property(nonatomic, copy) NSString *pro;
@property(nonatomic, copy) NSString *version;
@property(nonatomic, assign) NSInteger stateCode;
@property(nonatomic, copy) NSString *stateDesc;
@property(nonatomic, strong) NSDictionary *headDict;

@end

@interface VVHTTPResponseHead (PrivateAPI)

+ (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head;

+ (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head;

- (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head;

- (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head;

- (void)setHeadValue:(NSString *)value withField:(NSString *)field;

- (NSData *)dataOfHead;

@end
