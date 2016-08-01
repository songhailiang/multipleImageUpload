//
//  ResponseData.h
//  50+sh
//
//  Created by 宋海梁 on 15/12/7.
//  Copyright © 2015年 jicaas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ApiErrorCode) {
    ApiErrorCodeSuccess = 0,
    ApiErrorCodeTokenExpired = -414,     //token失效，需重新登录
    ApiErrorCodeNetworkError = -999,      //网络异常
};

@interface ResponseData : NSObject

@property (nonatomic, assign) BOOL success;

@property (nonatomic, assign) NSInteger errorCode;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *successMsg;

@property (nonatomic, strong) NSObject *data;


+ (instancetype)dataWithNSError:(NSError *)error;

@end
