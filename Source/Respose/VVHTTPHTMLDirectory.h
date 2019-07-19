//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVHTTPResource;


@interface VVHTTPHTMLDirectory : NSObject

@property(nonatomic, readonly) NSData *htmlData;
@property(nonatomic, readonly) NSArray<VVHTTPResource *> *resources;

+ (instancetype)initWithResources:(NSArray<VVHTTPResource *> *)resources
                          dirName:(NSString *)name;

- (instancetype)initWithResources:(NSArray<VVHTTPResource *> *)resources
                          dirName:(NSString *)name;
@end