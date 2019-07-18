//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVHTTPRequestHead;

/**
 该协议用于请求权限控制，以及POST、PUT等方法修改本地资源时的控制，若不实现这些委托方法，将按默认方式处理
 */
@protocol VVHTTPRequestDelegate <NSObject>

@optional

/**
 请求头解析完成

 @param head 请求头信息
 */
- (void)requestHeadFinish:(VVHTTPRequestHead *)head;


/**
  请求体读取完成

 @param head 请求头信息
 */
- (void)requestBodyFinish:(VVHTTPRequestHead *)head;

/**
 请求权限控制

 @param head 请求头信息
 @return 是否拒绝该请求
 */
- (BOOL)requestRefuse:(VVHTTPRequestHead *)head;


/**
 请求体写入路径重定向，POST，PUT使用

 @param path 将要写入的本地路径
 @param head 请求头信息
 @return 重定向的本地路径
 */
- (NSString *)requestBodyDataWritePath:(NSString *)path head:(VVHTTPRequestHead *)head;

/**
 写数据
 */
- (void)requestBodyData:(NSData *)data
               atOffset:(u_int64_t)offset
               filePath:(NSString *)path
                   head:(VVHTTPRequestHead *)head;


/**
 出现错误
 */
- (void)requestBodyDataError:(NSError *)error
                        head:(VVHTTPRequestHead *)head;


@end