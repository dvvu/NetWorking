//
//  DownloaderObject.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/18/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "DownloaderObject.h"

@implementation DownloaderObject

#pragma mark - initWithDownloaderTask

- (instancetype)initWithDownloaderTask:(NSURLSessionDownloadTask *)downloadTask progressBlock:(DownloaderProgressBlock)progressBlock remainingTime:(DownloaderRemainingTimeBlock)remainingTimeBlock completionBlock:(DownloaderCompletionBlock)completionBlock {
    
    self = [super init];
    
    if (self) {
        
        _remainingTimeBlock = remainingTimeBlock;
        _completionBlock = completionBlock;
        _progressBlock = progressBlock;
        _downloadTask = downloadTask;
    }
    
    return self;
}

@end
