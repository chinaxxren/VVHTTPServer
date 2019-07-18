//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVHTTPResourceInfo;


@interface VVHTTPHTMLDirectory : NSObject

@property(nonatomic, readonly) NSData *htmlData;
@property(nonatomic, readonly) NSArray<VVHTTPResourceInfo *> *resourceInfos;

+ (instancetype)initWithResources:(NSArray<VVHTTPResourceInfo *> *)resources
                          dirName:(NSString *)name;

- (instancetype)initWithResources:(NSArray<VVHTTPResourceInfo *> *)resourceInfos
                          dirName:(NSString *)name;
@end