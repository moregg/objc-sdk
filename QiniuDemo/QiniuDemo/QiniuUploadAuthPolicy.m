//
//  QiniuUploadAuthPolicy.m
//  QiniuSDK
//
//  Created by Qiniu Developers on 12-11-2.
//  Copyright (c) 2012 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import "QiniuUploadAuthPolicy.h"
#import <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"
#import "JSONKit.h"
#import "QiniuConfig.h"
#import "QiniuUtils.h"

@implementation QiniuUploadAuthPolicy

@synthesize scope;
@synthesize callbackUrl;
@synthesize callbackBodyType;
@synthesize customer;
@synthesize expires;
@synthesize escape;

// Make a token string conform to the UpToken spec.

- (NSString *)makeToken:(NSString *)accessKey secretKey:(NSString *)secretKey
{
	NSString *policy = [self marshal];
    NSString *encodedPolicy = urlsafeBase64String(policy);
    
    NSString* encodedDigest = hmacSha1_urlSafeBase64String(secretKey, encodedPolicy);
    
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@",  accessKey, encodedDigest, encodedPolicy];
    
	return token;
}

// Marshal as JSON format string.

- (NSString *)marshal
{
    time_t deadline;
    time(&deadline);
    
    deadline += (self.expires > 0) ? self.expires : 3600; // 1 hour by default.
    NSNumber *deadlineNumber = [NSNumber numberWithLongLong:deadline];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (self.scope) {
        [dic setObject:self.scope forKey:@"scope"];
    }
    if (self.callbackUrl) {
        [dic setObject:self.callbackUrl forKey:@"callbackUrl"];
    }
    if (self.callbackBodyType) {
        [dic setObject:self.callbackBodyType forKey:@"callbackBodyType"];
    }
    if (self.customer) {
        [dic setObject:self.customer forKey:@"customer"];
    }
    
    [dic setObject:deadlineNumber forKey:@"deadline"];
    
    if (self.escape) {
        NSNumber *escapeNumber = [NSNumber numberWithLongLong:escape];
        [dic setObject:escapeNumber forKey:@"escape"];
    }
    
    NSString *json = [dic JSONString];
    
    return json;
}

@end
