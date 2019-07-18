//
//  VVHTTPConfig.h
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
// 用于配置一些HTTP服务的初始化信息如端口、根目录、委托源等

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


@class VVHTTPResourceInfo;

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


@interface VVHTTPRequestHead : NSObject

@property(nonatomic, readonly) NSString *method;
@property(nonatomic, readonly) NSString *path;
@property(nonatomic, readonly) NSString *protocol;
@property(nonatomic, readonly) NSString *version;
@property(nonatomic, readonly) NSString *host;
@property(nonatomic, readonly) NSDictionary *headDict;

@end


@interface VVHTTPResponseHead : NSObject

@property(nonatomic, readonly) NSString *protocol;
@property(nonatomic, readonly) NSString *version;
@property(nonatomic, readonly) NSInteger stateCode;
@property(nonatomic, readonly) NSString *stateDesc;
@property(nonatomic, readonly) NSDictionary *headDic;

@end

@interface VVHTTPResourceInfo : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL isDirectory;
@property(nonatomic, copy) NSString *relativeUrl;
@property(nonatomic, copy) NSString *modifyTime;
@property(nonatomic, assign) u_int64_t size;

@end


@interface VVHTTPConfig : NSObject

@property(nonatomic, assign) uint16_t port;
@property(nonatomic, copy) NSString *rootDirectory;
@property(nonatomic, weak) id <VVHTTPRequestDelegate> requestDelegate;
@property(nonatomic, weak) id <VVHTTPResponseDelegate> responseDelegate;

@end
