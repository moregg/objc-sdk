//
//  QiniuAuthPolicy.h
//  iprint
//
//  Created by Xiao Huizhe on 12/28/12.
//  Copyright (c) 2012 Moregg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuAuthPolicy : NSObject

+(NSString*)downloadToken:(NSString*)key :(NSString*)secret :(NSString*)pattern :(NSDate*)validTo;
+(NSString*)accessToken:(NSString*)key :(NSString*)secret :(NSURL*)url :(NSString*)body;
@end
