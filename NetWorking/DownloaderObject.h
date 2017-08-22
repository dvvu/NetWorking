//
//  DownloaderObject.h
//  NetWorking
//
//  Created by Doan Van Vu on 8/18/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

typedef void(^DownloaderRemainingTimeBlock)(NSUInteger seconds);
typedef void(^DownloaderProgressBlock)(CGFloat progress);
typedef void(^DownloaderCompletionBlock)(BOOL completed);

@interface DownloaderObject : NSObject

@property (copy, nonatomic) DownloaderProgressBlock progressBlock;
@property (copy, nonatomic) DownloaderCompletionBlock completionBlock;
@property (copy, nonatomic) DownloaderRemainingTimeBlock remainingTimeBlock;

@property (nonatomic) NSURLSessionDownloadTask* downloadTask;
@property (copy, nonatomic) NSString* directoryName;
@property (copy, nonatomic) NSString* fileName;
@property (copy, nonatomic) NSDate* startDate;
@property (copy, nonatomic) NSString* url;
@property (nonatomic) NSData* resumeData;

#pragma mark - initWithDownloaderTask
- (instancetype)initWithDownloaderTask:(NSURLSessionDownloadTask *)downloadTask progressBlock:(DownloaderProgressBlock)progressBlock remainingTime:(DownloaderRemainingTimeBlock)remainingTimeBlock completionBlock:(DownloaderCompletionBlock)completionBlock;

@end
