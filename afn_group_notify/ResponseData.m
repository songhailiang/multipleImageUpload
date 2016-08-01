//
//  ResponseData.m
//  50+sh
//
//  Created by 宋海梁 on 15/12/7.
//  Copyright © 2015年 jicaas. All rights reserved.
//

#import "ResponseData.h"
#import <AFNetworking.h>

@implementation ResponseData

+ (instancetype)dataWithNSError:(NSError *)error {
    
    if (error.code == NSURLErrorCancelled) {
        //对于cancel的http请求，不做异常处理
        return nil;
    }
    
    ResponseData *data = [ResponseData new];
    data.success = NO;
    
    //判断网络是否连接
    if (![AFNetworkReachabilityManager sharedManager].reachable
        || error.code == NSURLErrorNotConnectedToInternet) {
        data.errorCode = ApiErrorCodeNetworkError;
        data.message = @"网络未连接，请检查网络设置";
    }
    else if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCannotFindHost
             || error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorNetworkConnectionLost){
        data.errorCode = ApiErrorCodeNetworkError;
        data.message = @"网络连接超时，请检查网络设置";
    }
    else{
        data.message = [NSString stringWithFormat:@"未知的服务端错误(%@)，请稍后重试",@(error.code)];
    }
    
    return data;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {

    return @{
             @"successMsg"  :   @"extData.successMsg"
             };
}

- (void)mj_keyValuesDidFinishConvertingToObject {
    
    self.success = (self.errorCode == ApiErrorCodeSuccess);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:{errorCode:%@,message:%@,successMsg:%@,data:%@}>"
            ,NSStringFromClass([self class])
            ,@(self.errorCode)
            ,self.message
            ,self.successMsg
            ,self.data
            ];
}

@end
