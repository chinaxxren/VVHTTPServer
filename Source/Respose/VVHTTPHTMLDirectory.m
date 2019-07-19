//
// Created by Tank on 2019-07-18.
// Copyright (c) 2019 zenggen. All rights reserved.
//

#import "VVHTTPHTMLDirectory.h"

#import "VVHTTPResource.h"

static NSString *const VVHTTPHTMLSortKey = @"sortType";
static NSString *const VVHTTPHTMLNameAscending = @"name-ascending";
static NSString *const VVHTTPHTMLNameDescending = @"name-descending";
static NSString *const VVHTTPHTMLDateAscending = @"date-ascending";
static NSString *const VVHTTPHTMLDateDescending = @"date-descending";
static NSString *const VVHTTPHTMLSizeAscending = @"size-ascending";
static NSString *const VVHTTPHTMLSizeDescending = @"size-descending";

@implementation VVHTTPHTMLDirectory

+ (instancetype)initWithResources:(NSArray<VVHTTPResource *> *)resources
                          dirName:(NSString *)name {
    return [[self alloc] initWithResources:resources dirName:name];
}

- (instancetype)initWithResources:(NSArray<VVHTTPResource *> *)resources
                          dirName:(NSString *)dirPath {
    if (self = [self init]) {
        _resources = [self sortData:resources withPath:dirPath];
        NSArray *array = [dirPath componentsSeparatedByString:@"?"];
        NSString *name = array.firstObject;
        NSString *sortValue = [self getSortTypeWithPath:dirPath];
        NSString *sort = sortValue ? [NSString stringWithFormat:@"?%@=%@", VVHTTPHTMLSortKey, sortValue] : @"";

        NSMutableString *htmlStr = @"<html>".mutableCopy;
        NSString *stylePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"headstyle"];
        NSString *style = [NSString stringWithContentsOfFile:stylePath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
        NSString *title = [name lastPathComponent];
        if (title.length == 0 || [title isEqualToString:@"/"]) {
            title = @"Home";
        }
        [htmlStr appendFormat:@"<head>"
                              "<title>%@</title>"
                              "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"
                              "<meta name=\"viewport\" content=\"initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width\">"
                              "<link rel=\"shortcut icon\" href=\"/favicon.ico\"/>"
                              "%@"
                              "</head>", title, style];

        [htmlStr appendFormat:@"<body>"
                              "<h1>当前路径：%@</h1>", [self getDirWithPath:name sortStr:sort]];
        NSString *nameSort = [sortValue isEqualToString:VVHTTPHTMLNameDescending] ? VVHTTPHTMLNameAscending : VVHTTPHTMLNameDescending;
        NSString *dateSort = [sortValue isEqualToString:VVHTTPHTMLDateDescending] ? VVHTTPHTMLDateAscending : VVHTTPHTMLDateDescending;
        NSString *sizeSort = [sortValue isEqualToString:VVHTTPHTMLSizeDescending] ? VVHTTPHTMLSizeAscending : VVHTTPHTMLSizeDescending;

        [htmlStr appendString:@"<table>"
                              "<tr>"];
        [htmlStr appendFormat:@"<th><a href=\"./.?%@=%@\">文件名</a></th>", VVHTTPHTMLSortKey, nameSort];
        [htmlStr appendFormat:@"<th><a href=\"./.?%@=%@\">修改日期</a></th>", VVHTTPHTMLSortKey, dateSort];
        [htmlStr appendFormat:@"<th><a href=\"./.?%@=%@\">文件大小</a></th>", VVHTTPHTMLSortKey, sizeSort];
        [htmlStr appendString:@"</tr>"];

        [htmlStr appendFormat:@"<tr>"
                              "<td><a href=\"./..%@\">上一级</a></td>"
                              "<td>&nbsp;-</td>"
                              "<td>&nbsp;&nbsp;-</td>"
                              "</tr>", sort];
        [_resources enumerateObjectsUsingBlock:^(VVHTTPResource *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *url = obj.relativeUrl, *size = [self formmatSize:obj.size];
            NSString *symble = @"📄";
            if (obj.isDirectory) {
                url = [obj.relativeUrl stringByAppendingString:@"/"];
                if (sortValue) {
                    url = [url stringByAppendingString:sort];
                }
                size = @"[DIR]";
                symble = @"📔";
            }
            [htmlStr appendFormat:@"<tr>"
                                  "<td>%@<a href=\"%@\"> %@</a></td>"
                                  "<td>&nbsp;%@</td>"
                                  "<td>&nbsp;&nbsp;%@</td>"
                                  "</tr>", symble, url, obj.name, obj.modifyTime, size];

        }];


        [htmlStr appendString:@"</table>"
                              "</pre>"
                              "</body>"
                              "</html>"];

        _htmlData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (NSString *)formmatSize:(u_int64_t)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%llu", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%lluK", size / 1024];
    } else if (size < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%lluM", size / (1024 * 1024)];
    } else {
        return [NSString stringWithFormat:@"%lluG", size / (1024 * 1024 / 1024)];
    }
}

- (NSString *)getSortTypeWithPath:(NSString *)path {
    __block NSString *sortType;
    NSArray<NSURLQueryItem *> *items = [self getQueryItemsWithPath:path];
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj.name isEqualToString:VVHTTPHTMLSortKey]) {
            sortType = obj.value;
            *stop = YES;
        }
    }];
    return sortType;
}

- (NSArray *)sortData:(NSArray<VVHTTPResource *> *)array withPath:(NSString *)path {
    NSString *sortType = [self getSortTypeWithPath:path];
    NSArray<VVHTTPResource *> *resArray = [array sortedArrayUsingComparator:^NSComparisonResult(VVHTTPResource *obj1, VVHTTPResource *obj2) {
        NSComparisonResult res;
        if ([sortType isEqualToString:VVHTTPHTMLNameAscending]) {
            res = [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
        } else if ([sortType isEqualToString:VVHTTPHTMLNameDescending]) {
            res = [obj2.name compare:obj1.name options:NSCaseInsensitiveSearch];
        } else if ([sortType isEqualToString:VVHTTPHTMLDateAscending]) {
            res = [obj1.modifyTime compare:obj2.modifyTime options:NSCaseInsensitiveSearch];
        } else if ([sortType isEqualToString:VVHTTPHTMLDateDescending]) {
            res = [obj2.modifyTime compare:obj1.modifyTime options:NSCaseInsensitiveSearch];
        } else if ([sortType isEqualToString:VVHTTPHTMLSizeAscending]) {
            if (obj1.size < obj2.size) {
                res = NSOrderedAscending;
            } else if (obj1.size == obj2.size) {
                res = NSOrderedSame;
            } else {
                res = NSOrderedDescending;
            }
        } else if ([sortType isEqualToString:VVHTTPHTMLSizeDescending]) {
            if (obj1.size > obj2.size) {
                res = NSOrderedAscending;
            } else if (obj1.size == obj2.size) {
                res = NSOrderedSame;
            } else {
                res = NSOrderedDescending;
            }
        } else {
            res = NSOrderedSame;
        }
        return res;
    }];

    return resArray;
}

- (NSArray<NSURLQueryItem *> *)getQueryItemsWithPath:(NSString *)path {
    NSURLComponents *comp = [NSURLComponents componentsWithString:path];
    return [comp queryItems];
}

- (NSString *)getDirWithPath:(NSString *)absPath sortStr:(NSString *)sort {
    NSMutableString *htmlStr = @"".mutableCopy;
    NSString *path = [absPath hasPrefix:@"/"] ? absPath : [@"/" stringByAppendingString:absPath];
    while (![path isEqualToString:@"/"] && path.length > 0) {
        path = [path hasSuffix:@"/"] ? path : [path stringByAppendingString:@"/"];
        NSString *str = [NSString stringWithFormat:@"‣<a href=\"%@%@\">%@</a>", path, sort, [path lastPathComponent]];
        [htmlStr insertString:str atIndex:0];
        path = [path stringByDeletingLastPathComponent];
    }
    [htmlStr insertString:[NSString stringWithFormat:@"‣<a href=\"/%@\">Home</a>", sort] atIndex:0];
    return htmlStr.copy;
}

@end