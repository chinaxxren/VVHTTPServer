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

- (NSError *)start;

- (void)stop;

- (uint16_t)port;

- (void)setPort:(uint16_t)port;

- (NSString *)IP;

- (NSString *)urlString;

@end

