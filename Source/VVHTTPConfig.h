//
//  VVHTTPConfig.h
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
// 用于配置一些HTTP服务的初始化信息如端口、根目录、委托源等

#import <Foundation/Foundation.h>

@protocol VVHTTPRequestDelegate;
@protocol VVHTTPResponseDelegate;

@interface VVHTTPConfig : NSObject

@property(nonatomic, assign) uint16_t port;
@property(nonatomic, copy) NSString *rootDirectory;
@property(nonatomic, weak) id <VVHTTPRequestDelegate> requestDelegate;
@property(nonatomic, weak) id <VVHTTPResponseDelegate> responseDelegate;

@end
