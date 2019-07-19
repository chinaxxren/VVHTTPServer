//
//  VVHTTPResponseHandeler.m
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
//

#import "VVHTTPResponseHandeler.h"

#import "VVHTTPResource.h"
#import "VVHTTPResponseHead.h"
#import "VVHTTPResponseDelegate.h"
#import "VVHTTPRequestHead.h"
#import "VVHTTPHTMLDirectory.h"

NSUInteger const kVVHTTPDataReadMax = HUGE_VALL;

@interface VVHTTPResponseHandeler ()

@property(nonatomic, weak) id <VVHTTPResponseDelegate> delegate;
@property(nonatomic, copy) NSString *rootDir;
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, copy) NSString *queryStr;
@property(nonatomic, strong) NSData *htmlData;
@property(nonatomic, assign) BOOL delegateEnabled;
@property(nonatomic, strong) NSFileHandle *fileOutput;

@end

@implementation VVHTTPResponseHandeler

+ (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head {
    return [[self alloc] initWithError:error requestHead:head];
}

+ (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head
                           delegate:(id <VVHTTPResponseDelegate>)delegate
                            rootDir:(NSString *)dir {
    return [[self alloc] initWithRequestHead:head delegate:delegate rootDir:dir];
}

- (instancetype)initWithError:(NSError *)error requestHead:(VVHTTPRequestHead *)head {
    if (self = [self init]) {
        _requestHead = head;
        _error = error;
        _responseHead = [VVHTTPResponseHead initWithError:error requestHead:head];
    }
    return self;
}

- (instancetype)initWithRequestHead:(VVHTTPRequestHead *)head
                           delegate:(id <VVHTTPResponseDelegate>)delegate
                            rootDir:(NSString *)rootDir {
    if (self = [self init]) {
        _requestHead = head;
        _responseHead = [VVHTTPResponseHead initWithRequestHead:head];
        _rootDir = [rootDir copy];
        _delegate = delegate;
        if (_delegateEnabled && [_delegate respondsToSelector:@selector(startLoadResource:)]) [_delegate startLoadResource:_requestHead];
        if ([self delegateCheck]) {
            [self loadData];
            if (![self redirectUrl]) {
                [self loadBodyData];
            }
        } else {
            _responseHead.stateCode = 404;
            _responseHead.stateDesc = [@"服务器非法操作!" stringByRemovingPercentEncoding];
        }
    }
    return self;
}

- (void)loadData {
    NSRange range = [_requestHead.path rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        self.filePath = [_rootDir stringByAppendingString:_requestHead.path];
    } else {
        self.filePath = [_rootDir stringByAppendingString:[_requestHead.path substringToIndex:range.location]];
        self.queryStr = [_requestHead.path substringFromIndex:range.location + range.length];
    }
    NSString *redirectUrl = [self redirectUrl];
    if (redirectUrl) {
        [_responseHead setHeadValue:redirectUrl withField:@"Location"];
        _responseHead.stateCode = 303;
        return;
    }
}

- (void)loadBodyData {
    BOOL isResourceExist = YES;
    if (_delegateEnabled) {
        isResourceExist = [_delegate respondsToSelector:@selector(isResourceExist:)] && ![_delegate isResourceExist:_requestHead];
    } else {
        isResourceExist = [[NSFileManager defaultManager] fileExistsAtPath:_filePath];
    }

    if (!isResourceExist) {
        if ([self isFavicon]) {
            self.filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"favicon.ico"];
        } else {
            _responseHead.stateCode = 404;
            _responseHead.stateDesc = [@"访问资源不存在!" stringByRemovingPercentEncoding];
            return;
        }
    }

    if ([self isDir]) {
        [self loadDir];
    } else {
        [self loadFileData];
    }

    if ([self bodyEnd]) {
        return;
    }
}

- (void)loadFileData {
    if (_delegateEnabled && [_delegate respondsToSelector:@selector(resourceLength:)]) {
        NSRange range = [_requestHead range];
        u_int64_t length = [_delegate resourceLength:_requestHead];
        if (range.location < length && range.length < length && range.length > 0) {
            _bodyDataLength = length - range.location > range.length ? range.length : length - range.location;
            _bodyDataOffset = range.location;
        } else {
            _bodyDataLength = length;
        }
    } else {
        BOOL isDir;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&isDir];
        if (!isDir && isExist) {
            self.fileOutput = [NSFileHandle fileHandleForReadingAtPath:_filePath];

            NSRange range = [_requestHead range];
            u_int64_t length = [_fileOutput seekToEndOfFile];
            if (range.location < length && range.length < length && range.length > 0) {
                _bodyDataLength = length - range.location > range.length ? range.length : length - range.location;
                _bodyDataOffset = range.location;
                NSString *contentRange = [NSString stringWithFormat:@"bytes %llu-%llu/%llu", _bodyDataOffset, _bodyDataOffset + _bodyDataLength - 1, length];
                [_responseHead setHeadValue:contentRange withField:@"Content-Range"];
            } else {
                _bodyDataLength = length;
            }
        }
    }
}

- (void)loadDir {
    NSMutableArray *resourceInfos = [NSMutableArray new];
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY.MM.dd - HH:mm:ss"]; // YYYY.MM.dd
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path in [fileManager contentsOfDirectoryAtPath:_filePath error:nil]) {
        VVHTTPResource *resourceInfo = [VVHTTPResource new];

        NSError *error;
        NSDictionary<NSFileAttributeKey, id> *fileAttributes = [fileManager attributesOfItemAtPath:[_filePath stringByAppendingPathComponent:path] error:&error];
        resourceInfo.isDirectory = [fileAttributes.fileType isEqualToString:NSFileTypeDirectory];
        resourceInfo.size = resourceInfo.isDirectory ? 0 : fileAttributes.fileSize;
        NSDate *date = fileAttributes[NSFileModificationDate];
        NSString *modifyTime = [dateFormatter stringFromDate:date];
        resourceInfo.name = [path lastPathComponent];
        resourceInfo.modifyTime = modifyTime;
        resourceInfo.relativeUrl = [path stringByReplacingOccurrencesOfString:_rootDir withString:@""];
        [resourceInfos addObject:resourceInfo];
    }

    VVHTTPHTMLDirectory *htmlDir = [VVHTTPHTMLDirectory initWithResources:resourceInfos dirName:_requestHead.path];
    _htmlData = htmlDir.htmlData;
    NSRange range = [_requestHead range];
    u_int64_t length = _htmlData.length;
    if (range.location < length && range.length < length && range.length > 0) {
        _bodyDataLength = length - range.location > range.length ? range.length : length - range.location;
        _bodyDataOffset = range.location;
        NSString *contentRange = [NSString stringWithFormat:@"bytes %llu-%llu/%llu", _bodyDataOffset, _bodyDataOffset + _bodyDataLength - 1, length];
        [_responseHead setHeadValue:contentRange withField:@"Content-Range"];
    } else {
        _bodyDataLength = _htmlData.length;
        _bodyDataOffset = 0;
    }
    [_responseHead setHeadValue:@"close" withField:@"Connection"];
    [_responseHead setHeadValue:@"text/html; charset=utf-8" withField:@"Content-Type"];
}

- (BOOL)delegateCheck {
    if ([_delegate respondsToSelector:@selector(shouldUsedDelegate:)]) self.delegateEnabled = [_delegate shouldUsedDelegate:_requestHead];
    BOOL resourcePathD = [_delegate respondsToSelector:@selector(resourceRelativePath:)];
    BOOL isDirD = [_delegate respondsToSelector:@selector(isDirectory:)];
    BOOL isExistD = [_delegate respondsToSelector:@selector(isResourceExist:)];
    BOOL dirItemInfoD = [_delegate respondsToSelector:@selector(dirItemInfoList:)];
    BOOL resourceLengthD = [_delegate respondsToSelector:@selector(resourceLength:)];
    BOOL readResourceD = [_delegate respondsToSelector:@selector(readResource:atOffset:length:head:)];

    BOOL delegateLegal = (resourcePathD || isDirD || isExistD || dirItemInfoD || resourceLengthD || readResourceD)
            == (resourcePathD && isDirD && isExistD && dirItemInfoD && resourceLengthD && readResourceD);

    if (!_delegateEnabled) return YES;

    return delegateLegal != nil;
}

- (BOOL)isDir {
    if (_delegateEnabled && [_delegate respondsToSelector:@selector(isDirectory:)]) return [_delegate isDirectory:_requestHead];
    return [[_filePath substringFromIndex:_filePath.length - 1] isEqualToString:@"/"];
}

- (BOOL)isFavicon {
    return [_requestHead.path isEqualToString:@"/favicon.ico"];
}

- (NSString *)redirectUrl {
    if (_delegateEnabled && [_delegate respondsToSelector:@selector(redirect:)]) return [_delegate redirect:_requestHead];
    if (![self isDir] && ![_delegate respondsToSelector:@selector(isDirectory:)]) {
        BOOL isDir;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&isDir];
        NSString *path = [_requestHead.host stringByAppendingPathComponent:_requestHead.path];
        if (isDir && isExist) return [NSString stringWithFormat:@"http://%@/", path];
    }
    return nil;
}

- (BOOL)shouldConnectKeepLive {
    if (_error) return NO;
    if ([self bodyEnd]) return NO;
    return [_requestHead.headDict[@"Connection"] isEqualToString:@"keep-alive"];
}

- (BOOL)bodyEnd {
    if (_error) return YES;
    return _bodyDataLength < _bodyDataOffset + 1;
}

- (NSData *)readAllHeadData {
    [_responseHead setHeadValue:@(_bodyDataLength).stringValue withField:@"Content-Length"];
    return [_responseHead dataOfHead];
}

- (NSData *)readBodyData {
    NSData *htmlData;
    if ([self isDir]) {
        _bodyDataOffset = _htmlData.length;
        htmlData = _htmlData;
    } else {
        NSUInteger length = kVVHTTPDataReadMax;
        if (_bodyDataOffset >= _bodyDataLength) return nil;
        if (_bodyDataOffset + kVVHTTPDataReadMax >= _bodyDataLength) length = _bodyDataLength - _bodyDataOffset;

        if (_delegateEnabled && [_delegate respondsToSelector:@selector(readResource:atOffset:length:head:)]) {
            htmlData = [_delegate readResource:_filePath atOffset:_bodyDataOffset length:length head:_requestHead];
            _bodyDataOffset += length;
            if ([self bodyEnd]) {
                if ([_delegate respondsToSelector:@selector(finishLoadResource:)]) [_delegate finishLoadResource:_requestHead];
            }
        } else {
            [_fileOutput seekToFileOffset:_bodyDataOffset];
            htmlData = [_fileOutput readDataOfLength:length];
            _bodyDataOffset += length;
            if ([self bodyEnd]) [_fileOutput closeFile];
        }
    }

    return htmlData;
}

@end

