//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import "VVHTTPRequestHead.h"


@implementation VVHTTPRequestHead

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation VVHTTPRequestHead (NSData)

+ (instancetype)initWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [self init]) {
        if (![self parseData:data])return nil;
    }
    return self;
}

- (BOOL)parseData:(NSData *)data {
    NSString *headStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *headArray = [headStr componentsSeparatedByString:@"\r\n"];
    NSMutableDictionary *headDict = @{}.mutableCopy;
    __block BOOL res = YES;
    [headArray enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.length == 0)return;
        if (idx == 0) {
            NSArray *lineItems = [obj componentsSeparatedByString:@" "];
            if (lineItems.count != 3) {
                *stop = YES;
                res = NO;
                return;
            }
            self.method = lineItems[0];
            self.path = [lineItems[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSArray *array = [lineItems[2] componentsSeparatedByString:@"/"];
            if (array.count != 2) {
                *stop = YES;
                res = NO;
            }
            self.pro = array[0];
            self.version = array[1];
            return;
        }

        NSArray *headItems = [obj componentsSeparatedByString:@": "];
        if (headItems.count != 2)return;
        headDict[headItems[0]] = [headItems[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }];

    self.host = headDict[@"Host"];
    self.headDict = headDict;
    return res;
}

- (BOOL)hasRangeHead {
    return [self.headDict[@"Range"] hasPrefix:@"bytes="];
}

- (NSRange)range {
    if ([self hasRangeHead]) {
        NSString *rangeStr = [self.headDict[@"Range"] stringByReplacingOccurrencesOfString:@"bytes=" withString:@""];
        NSArray *strs = [rangeStr componentsSeparatedByString:@"-"];
        NSUInteger start = [strs.firstObject unsignedIntegerValue];
        NSUInteger end = [strs.lastObject unsignedIntegerValue];
        NSUInteger length = end - start;
        length = length != 0 ? length + 1 : NSUIntegerMax;
        return NSMakeRange(start, length);
    }

    return NSMakeRange(0, 0);
}

@end