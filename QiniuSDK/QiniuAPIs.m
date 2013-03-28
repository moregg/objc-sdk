//
//  QiniuAPIs.m
//  iprint
//
//  Created by Xiao Huizhe on 3/21/13.
//  Copyright (c) 2013 Moregg. All rights reserved.
//

#import "QiniuAPIs.h"
#import "QiniuConfig.h"
#import "QiniuAuthPolicy.h"
#import "JSONKit.h"
#import "QiniuUtils.h"

@implementation QiniuAPIs
static NSString* token = nil;
+(void)setToken:(NSString*)t{
    [token release];
    token = [t retain];
}
+(void)api:(NSString*)url :(ConfigRequest)config :(QiniuGeneralAPICallback)callback{
    
    __block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeOutSeconds = 15;
    
    if (config) {
        config(request);
    }
    NSString* body = @"";
    [request buildPostBody];
    if (request.postBody) {
        body = [[[NSString alloc] initWithData:request.postBody  encoding:NSASCIIStringEncoding] autorelease];
    }
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"QBox %@", token]];
    [request setCompletionBlock:^{
        @autoreleasepool {
            
            NSString *responseString = [request responseString];
            
            NSDictionary* dic = [responseString objectFromJSONString];
            if(callback)
                callback(dic, request);
        }
    }];
    [request setFailedBlock:^{
        @autoreleasepool {
            
            if(callback)
                callback(nil, request);
        }
    }];
    static NSOperationQueue* qiniuAPIQueue = nil;
    if (!qiniuAPIQueue) {
        qiniuAPIQueue = [[NSOperationQueue alloc] init];
        [qiniuAPIQueue setMaxConcurrentOperationCount:4];
    }
    [qiniuAPIQueue addOperation:request];
}

+(void)delete:(NSString*)bucket :(NSString*)key :(QiniuGeneralAPICallback)callback{
    
    NSString *encodedEntry = urlsafeBase64String([NSString stringWithFormat:@"%@:%@", bucket, key]);
    NSString *url = [NSString stringWithFormat:@"%@/delete/%@", kAPIHost, encodedEntry];
    
    [self api:url :^(ASIFormDataRequest *something) {
        something.requestMethod = @"POST";
    } :callback];
}
+(void)stat:(NSString*)bucket :(NSString*)key :(QiniuGeneralAPICallback)callback{
    
    NSString *encodedEntry = urlsafeBase64String([NSString stringWithFormat:@"%@:%@", bucket, key]);
    NSString *url = [NSString stringWithFormat:@"%@/stat/%@", kAPIHost, encodedEntry];
    
    [self api:url :nil :callback];
}
+(void)buckStat:(NSString*)bucket :(NSArray*)keys :(QiniuGeneralAPICallback)callback{
    NSMutableString* body = [NSMutableString string];
    for (NSString* key in keys) {
        
        NSString *encodedEntry = urlsafeBase64String([NSString stringWithFormat:@"%@:%@", bucket, key]);
        if (body.length) {
            [body appendString:@"&"];
        }
        [body appendFormat:@"op=/stat/%@", encodedEntry];
    }
    [self api:[NSString stringWithFormat:@"%@/batch",kAPIHost] :^(ASIFormDataRequest *something) {
        something.requestMethod = @"POST";
        something.postBody = [NSMutableData dataWithData:[body dataUsingEncoding:NSASCIIStringEncoding]];
    } :callback];
}
@end
