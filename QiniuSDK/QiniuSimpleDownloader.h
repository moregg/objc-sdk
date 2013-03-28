//
//  QiniuSimpleDownloader.h
//  iprint
//
//  Created by Xiao Huizhe on 12/25/12.
//  Copyright (c) 2012 Moregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest/ASIFormDataRequest.h"
@protocol QiniuDownloadDelegate
-(void)downloadDone:(BOOL)succeed :(NSData*)data;
@end
@interface QiniuSimpleDownloader : NSObject<ASIHTTPRequestDelegate>
@property (nonatomic, assign) id<QiniuDownloadDelegate> delegate;
@property (nonatomic, retain) NSString* token;
-(id) initWithToken:(NSString*)t;
-(void)download:(NSString*)buck :(NSString*)ID :(NSString*)extension;
-(void)cancel;
+ (NSData*) getCache:(NSString*)buck :(NSString*)ID :(NSString*)extension;

+ (void)cache:(NSData*)data :(NSString*)buck :(NSString*)ID :(NSString*)extension;
+ (void)clearCacheIfRequired;
@end
