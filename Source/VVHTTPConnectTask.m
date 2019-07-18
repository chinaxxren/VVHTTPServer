//
//  VVHTTPConnectTask.m
//  Demo
//
//  Created by Tank on 08/06/2017.
//  Copyright © 2017 Tank. All rights reserved.
//

#import "VVHTTPConnectTask.h"
#import "VVHTTPResponseHandeler.h"


NSTimeInterval kVVHTTPConnectTimeout = 20;

long kVVHTTPResquestHeadTag = 100;
long kVVHTTPResquestBodyTag = 101;
long kVVHTTPResponseHeadTag = 102;
long kVVHTTPResponseBodyTag = 103;
long kVVHTTPResquestErrorTag = 108;

@interface VVHTTPConnectTask () <GCDAsyncSocketDelegate>

@property(nonatomic, readonly) VVHTTPConfig *config;
@property(nonatomic, readonly) GCDAsyncSocket *socket;
@property(nonatomic, copy) VVHTTPTaskCompleteBlock completeBlock;
@property(nonatomic, strong) VVHTTPRequestHandler *requestHandler;
@property(nonatomic, strong) VVHTTPResponseHandeler *responseHandeler;

@end

@implementation VVHTTPConnectTask

+ (instancetype)initWithConfig:(VVHTTPConfig *)config
                        socket:(GCDAsyncSocket *)socket
                      complete:(VVHTTPTaskCompleteBlock)completeBlock {
    return [[self alloc] initWithConfig:config socket:socket complete:completeBlock];
}

- (instancetype)initWithConfig:(VVHTTPConfig *)config
                        socket:(GCDAsyncSocket *)socket
                      complete:(VVHTTPTaskCompleteBlock)completeBlock {
    if (self = [self init]) {
        _config = config;
        _socket = socket;
        self.completeBlock = completeBlock;
        [_socket setDelegate:self delegateQueue:_config.taskQueue];
    }
    return self;
}

- (void)execute {
    [_socket readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:kVVHTTPConnectTimeout tag:kVVHTTPResquestHeadTag];
}

- (void)checkRequseFinish {
    if (![_requestHandler isRequestFinish]) {
        [_socket readDataWithTimeout:kVVHTTPConnectTimeout tag:kVVHTTPResquestBodyTag];
    } else {
        self.responseHandeler = [VVHTTPResponseHandeler initWithRequestHead:_requestHandler.requestHead
                                                                   delegate:_config.responseDelegate
                                                                    rootDir:_config.rootDirectory];

        [_socket writeData:[_responseHandeler readAllHeadData] withTimeout:kVVHTTPConnectTimeout tag:kVVHTTPResponseHeadTag];
    }
}

- (void)checkResponseFinish {
    if ([_responseHandeler bodyEnd]) {
        if (![_responseHandeler shouldConnectKeepLive])
            [_socket disconnect];
    } else {
        NSData *data = [_responseHandeler readBodyData];
        [_socket writeData:data withTimeout:kVVHTTPConnectTimeout tag:kVVHTTPResponseBodyTag];
        if ([_responseHandeler bodyEnd])
            [_socket disconnectAfterWriting];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == kVVHTTPResquestHeadTag) {
        self.requestHandler = [VVHTTPRequestHandler initWithHeadData:data
                                                            delegate:_config.requestDelegate
                                                             rootDir:_config.rootDirectory];
        NSError *error = [_requestHandler invalidError];
        if (error) {
            self.responseHandeler = [VVHTTPResponseHandeler initWithError:error
                                                              requestHead:_requestHandler.requestHead];
            [_socket writeData:[_responseHandeler readAllHeadData] withTimeout:kVVHTTPConnectTimeout tag:kVVHTTPResquestErrorTag];
        } else {
            [self checkRequseFinish];
        }
    } else if (tag == kVVHTTPResquestBodyTag) {
        [_requestHandler writeBodyData:data];
        [self checkRequseFinish];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == kVVHTTPResquestErrorTag) {
        [_socket disconnectAfterWriting];
    } else if (tag == kVVHTTPResponseHeadTag) {
        [self checkResponseFinish];
    } else if (tag == kVVHTTPResponseBodyTag) {
        [self checkResponseFinish];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    _responseHandeler = nil;
    _requestHandler = nil;
    if (_completeBlock) _completeBlock(self);
}

@end
