//
//  DownloadManager.h
//  NetWorking
//
//  Created by Doan Van Vu on 8/18/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

@interface DownloadManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic) void(^backgroundTransferCompletionHandler)();

#pragma mark - Download with estimated time
- (void)downloadFileForURL:(NSString *)url
                  withName:(NSString *)fileName
          inDirectoryNamed:(NSString *)directory
             progressBlock:(void(^)(CGFloat progress))progressBlock
             remainingTime:(void(^)(NSUInteger seconds))remainingTimeBlock
           completionBlock:(void(^)(BOOL completed))completionBlock
      enableBackgroundMode:(BOOL)backgroundMode;

#pragma mark - cancelAllDownloads
- (void)cancelAllDownloads;

#pragma mark - cancelDownloadForUrl
- (void)cancelDownloadForUrl:(NSString *)fileIdentifier;

#pragma mark - fileExistsForUrl
- (BOOL)fileExistsForUrl:(NSString *)urlString;

#pragma mark - fileExistsWithName
- (BOOL)fileExistsWithName:(NSString *)fileName;

#pragma mark - fileExistsWithName
- (BOOL)deleteFileForUrl:(NSString *)urlString;

#pragma mark - fileExistsWithName
- (BOOL)deleteFileWithName:(NSString *)fileName;

#pragma mark - currentDownloads
- (NSArray *)currentDownloads;

#pragma mark - stopDownLoadForUrl...
- (void)stopDownLoadForUrl:(NSString *)fileIdentifier;

#pragma mark - resumeDownLoadForUrl...
- (void)resumeDownLoadForUrl:(NSString *)fileIdentifier;

@end
