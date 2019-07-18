//
//  VVHTTPConfig.m
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
//

#import "VVHTTPConfig.h"


@implementation VVHTTPRequestHead

- (void)setMethod:(NSString *)method {
    _method = [method copy];
}

- (void)setPath:(NSString *)path {
    _path = [path copy];
}

- (void)setProtocol:(NSString *)pro {
    _protocol = [pro copy];
}

- (void)setVersion:(NSString *)version {
    _version = [version copy];
}

- (void)setHost:(NSString *)host {
    _host = [host copy];
}

- (void)setHeadDict:(NSDictionary *)headDict {
    _headDict = [headDict copy];
}

@end

@implementation VVHTTPResponseHead

- (void)setProtocol:(NSString *)protocol {
    _protocol = [protocol copy];
}

- (void)setVersion:(NSString *)version {
    _version = [version copy];
}

- (void)setStateCode:(NSInteger)stateCode {
    _stateCode = stateCode;
}

- (void)setStateDesc:(NSString *)stateDesc {
    _stateDesc = [stateDesc copy];
}

- (void)setHeadDic:(NSDictionary *)headDic {
    _headDic = [headDic copy];
}

@end

@implementation VVHTTPResourceInfo

@end

@interface VVHTTPConfig ()

@property(nonatomic, strong) dispatch_queue_t taskQueue;

@end


@implementation VVHTTPConfig

@end


