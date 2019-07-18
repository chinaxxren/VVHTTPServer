//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import "VVHTTPResponseHead.h"
#import "VVHTTPRequestHead.h"

@implementation VVHTTPResponseHead

@end

@implementation VVHTTPResponseHead (PrivateAPI)

+ (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head {
    return [[self alloc] initWithRequestHead:head];
}

+ (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head {
    return [[self alloc] initWithError:error requestHead:head];
}

- (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head {
    if (self = [self initWithRequestHead:head]) {
        self.stateCode = error.code;
        self.stateDesc = [error.domain stringByRemovingPercentEncoding];
        if (error) [self setHeadValue:@"close" withField:@"Connection"];
    }
    return self;
}

- (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head {
    if (self = [self init]) {
        NSDate *date = [NSDate date];
        NSString *dataStr = [NSDateFormatter localizedStringFromDate:date
                                                           dateStyle:NSDateFormatterFullStyle
                                                           timeStyle:NSDateFormatterFullStyle];
        NSDictionary *headDict = @{
                @"Date": dataStr,
                @"Server": @"HTTPServer",
                @"Accept-Ranges": @"bytes"
        };
        self.headDict = headDict;
        self.pro = head.pro;
        self.version = head.version;

        self.stateCode = [head hasRangeHead] ? 206 : 200;
        self.stateDesc = @"OK";
    }
    return self;
}

- (void)setHeadValue:(NSString *)value withField:(NSString *)field {
    if (value == nil || field == nil)return;
    NSMutableDictionary *headDict = self.headDict.mutableCopy;
    headDict[field] = value;
    self.headDict = headDict;
}

- (NSData *)dataOfHead {
    NSMutableString *headStr = [NSMutableString new];
    [headStr appendFormat:@"%@/%@ %zd %@\r\n", self.pro, self.version, self.stateCode, self.stateDesc];
    [self.headDict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        [headStr appendFormat:@"%@:%@\r\n", key, obj];
    }];
    [headStr appendString:@"\r\n"];
    return [headStr dataUsingEncoding:NSUTF8StringEncoding];
}

@end
