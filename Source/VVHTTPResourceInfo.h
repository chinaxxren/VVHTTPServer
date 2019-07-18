//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VVHTTPResourceInfo : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL isDirectory;
@property(nonatomic, copy) NSString *relativeUrl;
@property(nonatomic, copy) NSString *modifyTime;
@property(nonatomic, assign) u_int64_t size;

@end