//
//  QiniuSimpleDownloader.m
//  iprint
//
//  Created by Xiao Huizhe on 12/25/12.
//  Copyright (c) 2012 Moregg. All rights reserved.
//

#import "QiniuSimpleDownloader.h"
#import "QiniuConfig.h"
#import "JSONKit.h"
#import "QiniuUtils.h"
#define MAX_CACHE_COUNT 50
@interface QiniuSimpleDownloader(){
    BOOL canceled;
}
@property (nonatomic, retain) ASIFormDataRequest* request;
@end
@implementation QiniuSimpleDownloader
@synthesize delegate, request, token;
-(void)dealloc{
    [self cancel];
    self.delegate = nil;
    [super dealloc];
}

-(id) initWithToken:(NSString*)t{
    self=  [super init];
    if(self){
        self.token = t;
    }
    return self;
}
-(void)download:(NSString*)buck :(NSString*)ID :(NSString*)extension{
    [self cancel];
    canceled = NO;
    // http://docs.qiniutek.com/v3/api/io/#get
    NSString* url = [NSString stringWithFormat:@"http://%@.qiniudn.com/%@%@?token=%@", buck, urlEncode(ID), urlEncode(extension ? [NSString stringWithFormat:@"-%@", extension] : @""), urlEncode(token)];
    self.request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    self.request.delegate = self;
    self.request.userInfo = [NSMutableDictionary dictionary];
    if(buck) [(NSMutableDictionary*)self.request.userInfo setObject:buck forKey:@"bucket"];
    if(ID) [(NSMutableDictionary*)self.request.userInfo setObject:ID forKey:@"ID"];
    if(extension) [(NSMutableDictionary*)self.request.userInfo setObject:extension forKey:@"extension"];
    static NSOperationQueue* downloaderOperationQueue = nil;
    if(!downloaderOperationQueue){
        downloaderOperationQueue = [[NSOperationQueue alloc] init];
        [downloaderOperationQueue setMaxConcurrentOperationCount:4];
    }
    [downloaderOperationQueue addOperation:request];
}
-(void)cancel{
    canceled = YES;
    self.request.delegate = nil;
    self.request = nil;
}
-(void)requestFinished:(ASIHTTPRequest *)r{
    NSString* responseString = [r responseString];
    NSDictionary* responseJSON = [responseString objectFromJSONString];
    if (responseJSON && [responseJSON isKindOfClass:[NSDictionary class]]) {
        NSString* error = [responseJSON objectForKey:@"error"];
        if ([error length]) {
            [delegate downloadDone:NO :r.responseData];
            return;
        }
    }
    [delegate downloadDone:YES :r.responseData];
    [QiniuSimpleDownloader cache:r.responseData :[r.userInfo objectForKey:@"bucket"] :[r.userInfo objectForKey:@"ID"] :[r.userInfo objectForKey:@"extension"]];
}
-(void)requestFailed:(ASIHTTPRequest *)r{
    [delegate downloadDone:NO :nil];
}

+ (NSString*)cacheFolder{
    static NSString * diskCachePath = nil;
    if (!diskCachePath) {
        
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        diskCachePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"QiniuCache"] retain];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
    }
    return diskCachePath;
}
+ (NSString*) cacheFileName:(NSString*)buck :(NSString*)ID :(NSString*)extension{
    if (!buck) buck =@"";
    if (!ID) ID =@"";
    if (!extension) extension =@"";
    
    return [NSString stringWithFormat:@"%@~%@~%@", buck, ID, extension];
}
+ (NSData*) getCache:(NSString*)buck :(NSString*)ID :(NSString*)extension{
    NSString* file = [[self cacheFolder] stringByAppendingPathComponent:[self cacheFileName:buck :ID :extension]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return [NSData dataWithContentsOfFile:file];
    }
    return nil;
}
+ (void)cache:(NSData*)data :(NSString*)buck :(NSString*)ID :(NSString*)extension{
    
    NSString* file = [[self cacheFolder] stringByAppendingPathComponent:[self cacheFileName:buck :ID :extension]];
    [data writeToFile:file atomically:YES];
}
+ (void)clearCacheIfRequired{
    
    NSString* folder = [self cacheFolder];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (int _i=0; _i<10; _i++) {
        
        NSArray* files = [manager contentsOfDirectoryAtPath:folder error:NULL];
        BOOL cleanRequired = files.count > MAX_CACHE_COUNT;
        if (files.count && cleanRequired) {
            double avg = 0;
            for (NSString * file in files) {
                NSString* fullPath = [folder stringByAppendingPathComponent:file];
                avg += [[manager attributesOfItemAtPath:fullPath error:NULL].fileModificationDate timeIntervalSince1970];
            }
            avg /= files.count;
            
            for (NSString * file in files) {
                NSString* fullPath = [folder stringByAppendingPathComponent:file];
                if ([[manager attributesOfItemAtPath:fullPath error:NULL].fileModificationDate timeIntervalSince1970] <= avg) {
                    [manager removeItemAtPath:fullPath error:NULL];
                }
            }
        }else{
            break;
        }
    }
}
@end
