//
//  UIImageView+Qiniu.m
//  iprint
//
//  Created by Xiao Huizhe on 12/26/12.
//  Copyright (c) 2012 Moregg. All rights reserved.
//

#import "UIImageViewForQiniu.h"

#define IMAGE_EXTENSION @"small.jpg"
@implementation UIImageViewForQiniu
@synthesize errorImage, downloader;
-(void)dealloc{
    self.errorImage = nil;
    self.downloader.delegate = nil;
    self.downloader = nil;
    [super dealloc];
}
-(void)downloadDone:(BOOL)succeed :(NSData*)data{
    UIImage* i = nil;
    if (succeed && data) {
        i = [UIImage imageWithData:data];
        
    }
    if(!i){
        i = self.errorImage;
    }
    [super setImage:i];
    self.downloader = nil;
}
-(void)setImage:(UIImage *)image{
    self.downloader.delegate =  nil;
    [self.downloader cancel];
    self.downloader = nil;
    [super setImage:image];
}
-(void)setImageWithQiniu:(NSString*)token :(NSString*)buck :(NSString*)ID :(UIImage*)loadingImage :(UIImage*)_errorImage{
    
    NSData* cache = [QiniuSimpleDownloader getCache:buck :ID :IMAGE_EXTENSION];
    UIImage* cachedImage = [UIImage imageWithData:cache];
    if (cachedImage) {
        [super setImage:cachedImage];
    }else{
        self.errorImage = _errorImage;
        
        [super setImage:loadingImage];
        
        self.downloader = [[[QiniuSimpleDownloader alloc] initWithToken:token] autorelease];
        self.downloader.delegate = self;
        [self.downloader download:buck :ID :IMAGE_EXTENSION];
    }
}

+(void)setImageCache:(UIImage*)i :(NSString*)buck :(NSString*)ID{
    [QiniuSimpleDownloader cache:UIImageJPEGRepresentation(i, 0.8) :buck :ID :IMAGE_EXTENSION];
}
@end
