//
//  VVHTTPConnectTask.h
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 konka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVHTTPRequestHandler.h"
#import "VVHTTPConfig.h"
#import "GCDAsyncSocket.h"

@class VVHTTPConnectTask;

typedef void(^ZGHTTPTaskCompleteBlock)(VVHTTPConnectTask *task);
/**
 * 用于处理每一个连接任务，通过TCP连接完成数据的收发
 */
@interface VVHTTPConnectTask : NSObject

+ (instancetype)initWithConfig:(VVHTTPConfig *)config
                        socket:(GCDAsyncSocket *)socket
                      complete:(ZGHTTPTaskCompleteBlock)completeBlock;

- (instancetype)initWithConfig:(VVHTTPConfig *)config
                        socket:(GCDAsyncSocket *)socket
                      complete:(ZGHTTPTaskCompleteBlock)completeBlock;

- (void)execute;

@end

@interface VVHTTPConfig (ZGHTTPPrivateAPI)

@property(nonatomic, strong) dispatch_queue_t taskQueue;

@end
