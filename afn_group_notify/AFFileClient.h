//
//  AFFileClient.h
//  50+sh
//
//  Created by 宋海梁 on 15/12/16.
//  Copyright © 2015年 jicaas. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ResponseData.h"

@interface AFFileClient : AFURLSessionManager

+ (instancetype)sharedClient;
/**
 *  图片上传
 *
 *  @param urlString  上传地址
 *  @param parameters 参数
 *  @param files      文件
 */
- (NSURLSessionUploadTask *)upload:(NSString *)urlString
                        parameters:(id)parameters
                             files:(NSDictionary *)files
                          complete:(void (^)(ResponseData *response))complete;


@end
