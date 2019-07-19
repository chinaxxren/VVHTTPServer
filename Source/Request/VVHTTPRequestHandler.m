//
//  VVHTTPRequestHandler.m
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
//

#import "VVHTTPRequestHandler.h"

#import "VVHTTPRequestHead.h"
#import "VVHTTPRequestDelegate.h"

@interface VVHTTPRequestHandler ()

@property(nonatomic, strong) NSFileHandle *fileInput;
@property(nonatomic, weak) id <VVHTTPRequestDelegate> delegate;
@property(nonatomic, copy) NSString *rootDir;
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, copy) NSString *queryStr;

@end

@implementation VVHTTPRequestHandler

+ (instancetype)initWithHeadData:(NSData *)data
                        delegate:(id <VVHTTPRequestDelegate>)delegate
                         rootDir:(NSString *)dir {
    return [[self alloc] initWithHeadData:data delegate:delegate rootDir:dir];
}

- (instancetype)initWithHeadData:(NSData *)data
                        delegate:(id <VVHTTPRequestDelegate>)delegate
                         rootDir:(NSString *)dir {
    if (self = [self init]) {
        _delegate = delegate;
        _rootDir = dir;
        _requestHead = [VVHTTPRequestHead initWithData:data];
        _bodyDataOffset = 0;
        NSString *length = [_requestHead headDict][@"Content-Length"];
        if (length != nil) _bodyDataLength = strtoull([length UTF8String], NULL, 0);
        if ([_delegate respondsToSelector:@selector(requestHeadFinish:)]) {
            [_delegate requestHeadFinish:_requestHead];
        }
    }
    return self;
}

- (NSString *)filePath {
    if (!_filePath) {
        NSString *path = [_rootDir stringByAppendingPathComponent:_requestHead.path];
        if ([_delegate respondsToSelector:@selector(requestBodyDataWritePath:head:)]) {
            _filePath = [[_delegate requestBodyDataWritePath:path head:_requestHead] copy];
        } else {
            NSRange range = [path rangeOfString:@"?"];
            if (range.location == NSNotFound) _filePath = path;
            else _filePath = [path substringToIndex:range.location - 1];
        }
    }
    return _filePath;
}

- (NSString *)queryStr {
    return _queryStr;
}

- (NSError *)refuseError {
    NSError *error;
    if ([_delegate respondsToSelector:@selector(requestRefuse:)]) {
        if ([_delegate requestRefuse:_requestHead]) {
            error = [NSError errorWithDomain:@"服务器拒绝访问!" code:404 userInfo:nil];
            return error;
        }
    }
    if ([[NSHomeDirectory() stringByDeletingLastPathComponent] rangeOfString:[self filePath]].location != NSNotFound) {
        error = [NSError errorWithDomain:@"服务器系统目录无法访问!" code:404 userInfo:nil];
        return error;
    }
    return nil;
}

- (NSError *)invalidError {
    if (![_requestHead.pro isEqualToString:@"HTTP"])
        return [NSError errorWithDomain:[NSString stringWithFormat:@"服务器不支持%@协议!", _requestHead.pro]
                                   code:501
                               userInfo:nil];
    if (![_requestHead.version isEqualToString:@"1.1"])
        return [NSError errorWithDomain:[NSString stringWithFormat:@"服务器不支持%@协议版本!", _requestHead.version]
                                   code:501
                               userInfo:nil];
    NSError *error = [self refuseError];
    if (error) return error;
    if ([_requestHead.method isEqualToString:@"POST"]) {
        if (_bodyDataLength == 0)
            return [NSError errorWithDomain:[NSString stringWithFormat:@"请求参数出错，%@方法需要指定body长度!", _requestHead.method]
                                       code:411
                                   userInfo:nil];
    }

    return nil;
}

- (BOOL)isMethodSupport {
    if ([_requestHead.method isEqualToString:@"GET"])return YES;
    if ([_requestHead.method isEqualToString:@"POST"])return YES;
    if ([_requestHead.method isEqualToString:@"PUT"])return YES;
    if ([_requestHead.method isEqualToString:@"DELETE"])return YES;
    return NO;
}


- (BOOL)isRequestFinish {
    return _bodyDataLength <= _bodyDataOffset + 1;
}

- (void)writeBodyData:(NSData *)data {
    if ([self refuseError] != nil)return;
    if ([_delegate respondsToSelector:@selector(requestBodyData:atOffset:filePath:head:)]) {
        [_delegate requestBodyData:data atOffset:_bodyDataOffset filePath:[self filePath] head:_requestHead];
    } else {
        if (_fileInput == nil) self.fileInput = [NSFileHandle fileHandleForWritingAtPath:[self filePath]];
        [self.fileInput writeData:data];
    }
    _bodyDataOffset += data.length;
    if ([self isRequestFinish]) {
        if ([_delegate respondsToSelector:@selector(requestBodyFinish:)]) [_delegate requestBodyFinish:_requestHead];
        if (self.fileInput) [self.fileInput closeFile];
    }
}

- (void)writeBodyDataError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(requestBodyFinish:)]) [_delegate requestBodyFinish:_requestHead];
    if (self.fileInput) [self.fileInput closeFile];
}

@end


