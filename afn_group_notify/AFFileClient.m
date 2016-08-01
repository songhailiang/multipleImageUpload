//
//  AFFileClient.m
//  50+sh
//
//  Created by 宋海梁 on 15/12/16.
//  Copyright © 2015年 jicaas. All rights reserved.
//

#import "AFFileClient.h"
#import <MJExtension.h>

#define kHttpRequestTimeoutInterval 60
#define BASE_URL_API    @"http://debug.50sh.com/"

@implementation AFFileClient

+ (AFFileClient *)sharedClient {
    static AFFileClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sharedClient = [[AFFileClient alloc] initWithSessionConfiguration:configuration];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        _sharedClient.securityPolicy = securityPolicy;
    });
    
    return _sharedClient;
}

- (NSURLSessionUploadTask *)upload:(NSString *)urlString
                        parameters:(id)parameters
                             files:(NSDictionary *)files
                          complete:(void (^)(ResponseData *response))complete {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@",BASE_URL_API,urlString] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *name = @"upload[]";
        for (NSString *key in files.allKeys) {
            [formData appendPartWithFileData:[files objectForKey:key] name:name fileName:[NSString stringWithFormat:@"%@.jpg",key] mimeType:@"image/jpeg"];
        }
        
    } error:nil];
    
    request.timeoutInterval = kHttpRequestTimeoutInterval;

    NSURLSessionUploadTask *uploadTask = [self uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
//        DDLogDebug(@"upload progress:%@",uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"url:%@,param:%@,resp:%@",request.URL.absoluteString,params,responseObject);
        if (error) {
            [self handleError:error complete:complete];
        }
        else {
            [self handleSuccess:responseObject complete:complete];
        }
    }];
    
    [uploadTask resume];
    
    return uploadTask;
}

- (void)handleError:(NSError *)error complete:(void (^)(ResponseData *response))complete {
    NSLog(@"error:%@",error);
    ResponseData *data = [ResponseData dataWithNSError:error];
    
    if (data && complete) {
        complete(data);
    }
}

- (void)handleSuccess:(id)responseObject complete:(void (^)(ResponseData *response))complete {
    ResponseData *data = [ResponseData mj_objectWithKeyValues:responseObject];
    
    if(complete) {
        complete(data);
    }
}

@end
