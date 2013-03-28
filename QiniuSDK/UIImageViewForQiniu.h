//
//  UIImageView+Qiniu.h
//  iprint
//
//  Created by Xiao Huizhe on 12/26/12.
//  Copyright (c) 2012 Moregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QiniuSimpleDownloader.h"
@interface UIImageViewForQiniu :UIImageView<QiniuDownloadDelegate>
@property (nonatomic, retain) UIImage* errorImage;
@property (nonatomic, retain) QiniuSimpleDownloader* downloader;
-(void)setImageWithQiniu:(NSString*)token :(NSString*)buck :(NSString*)ID :(UIImage*)loadingImage :(UIImage*)errorImage;
+(void)setImageCache:(UIImage*)i :(NSString*)buck :(NSString*)ID;
@end
