//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import <Foundation/Foundation.h>


@class VVHTTPResourceInfo;
@class VVHTTPRequestHead;

@protocol VVHTTPResponseDelegate <NSObject>

@optional

- (void)startLoadResource:(VVHTTPRequestHead *)head;

- (void)finishLoadResource:(VVHTTPRequestHead *)head;

- (BOOL)shouldUsedDelegate:(VVHTTPRequestHead *)head;

- (NSString *)redirect:(VVHTTPRequestHead *)head;

- (NSString *)resourceRelativePath:(VVHTTPRequestHead *)head;

- (BOOL)isDirectory:(VVHTTPRequestHead *)head;

- (BOOL)isResourceExist:(VVHTTPRequestHead *)head;

- (NSArray<VVHTTPResourceInfo *> *)dirItemInfoList:(VVHTTPRequestHead *)head;

- (u_int64_t)resourceLength:(VVHTTPRequestHead *)head;

- (NSData *)readResource:(NSString *)path
                atOffset:(u_int64_t)offset
                  length:(u_int64_t)length
                    head:(VVHTTPRequestHead *)head;
@end

