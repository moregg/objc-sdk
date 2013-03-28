//
//  QiniuAPIs.h
//  iprint
//
//  Created by Xiao Huizhe on 3/21/13.
//  Copyright (c) 2013 Moregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

#define kAPIHost @"http://rs.qbox.me"
typedef void (^ConfigRequest)(ASIFormDataRequest* something);
typedef void (^QiniuGeneralAPICallback)(NSDictionary* result, ASIHTTPRequest* something);
@interface QiniuAPIs : NSObject
+(void)setToken:(NSString*)token;
+(void)stat:(NSString*)bucket :(NSString*)key :(QiniuGeneralAPICallback)callback;
+(void)delete:(NSString*)bucket :(NSString*)key :(QiniuGeneralAPICallback)callback;
+(void)buckStat:(NSString*)bucket :(NSArray*)keys :(QiniuGeneralAPICallback)callback;
@end
