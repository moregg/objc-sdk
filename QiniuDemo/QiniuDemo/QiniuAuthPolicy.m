//
//  QiniuAuthPolicy.m
//  iprint
//
//  Created by Xiao Huizhe on 12/28/12.
//  Copyright (c) 2012 Moregg. All rights reserved.
//

#import "QiniuAuthPolicy.h"
#import "JSONKit.h"
#import "QiniuUtils.h"
#import "GTMBase64.h"
@implementation QiniuAuthPolicy

+(NSString*)downloadToken:(NSString*)key :(NSString*)secret :(NSString*)pattern :(NSDate*)validTo{
    NSString* json_scope = [[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:[validTo timeIntervalSince1970]], @"E", pattern, @"S", nil] JSONString];
    NSString* scope = urlsafeBase64String(json_scope);
    
    
    NSString * checksum = hmacSha1_urlSafeBase64String(secret, scope);
    
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", key, checksum, scope];
    return token;
}

+(NSString*)accessToken:(NSString*)key :(NSString*)secret :(NSURL*)url :(NSString*)body{
    NSMutableString* baseString = [NSMutableString string];
    [baseString appendString:url.path];
    if (url.query.length) {
        [baseString appendString:@"?"];
        [baseString appendString:url.query];
    }
    [baseString appendString:@"\n"];
    
    [baseString appendString:body];
    NSString * checksum = hmacSha1_urlSafeBase64String(secret, baseString);
    return [NSString stringWithFormat:@"%@:%@", key, checksum];
}
@end
