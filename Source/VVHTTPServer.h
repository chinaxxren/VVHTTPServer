//
//  VVHTTPServer.h
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVHTTPConfig.h"

@interface VVHTTPServer : NSObject

@property(nonatomic, readonly) VVHTTPConfig *config;

+ (instancetype)initWithConfig:(void (^)(VVHTTPConfig *config))configBlock;

- (instancetype)initWithConfig:(void (^)(VVHTTPConfig *config))configBlock;

// 启动服务器
- (NSError *)start;

// 停止服务器
- (void)stop;

// 获取端口号
- (uint16_t)port;

// 设置端口号
- (void)setPort:(uint16_t)port;

// 获取端IP地址
- (NSString *)IP;

// 获取服务器访问链接
- (NSString *)urlString;

@end

