//
//  DownloadManager.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/18/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "DownloaderObject.h"
#import "DownloadManager.h"
#import <UIKit/UIKit.h>

@interface DownloadManager ()  <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic) NSURLSession* backgroundSession;
@property (nonatomic) NSMutableDictionary* downloads;
@property (nonatomic) NSURLSession* session;
@property (nonatomic) NSString* fileIdentifier;
@end

@implementation DownloadManager

#pragma mark - sharedManager...

+ (instancetype)sharedManager {
    
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
    
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - init...

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        // Default session
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        
        // Background session
        NSURLSessionConfiguration* backgroundConfiguration = nil;
        backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
        _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self delegateQueue:nil];
        
        _downloads = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - downloadFileForURL...

- (void)downloadFileForURL:(NSString *)urlString withName:(NSString *)fileName inDirectoryNamed:(NSString *)directory progressBlock:(void(^)(CGFloat progress))progressBlock remainingTime:(void(^)(NSUInteger seconds))remainingTimeBlock completionBlock:(void(^)(BOOL completed))completionBlock enableBackgroundMode:(BOOL)backgroundMode {
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    if (![self fileDownloadCompletedForUrl:urlString]) {
        
        NSLog(@"File is downloading!");
    } else if (![self fileExistsWithName:fileName inDirectory:directory]) {
        
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        NSURLSessionDownloadTask* downloadTask;
        
        if (backgroundMode) {
            
            downloadTask = [_backgroundSession downloadTaskWithRequest:request];
        } else {
            
            downloadTask = [_session downloadTaskWithRequest:request];
        }
        
        DownloaderObject* downloadObject = [[DownloaderObject alloc] initWithDownloaderTask:downloadTask progressBlock:progressBlock remainingTime:remainingTimeBlock completionBlock:completionBlock];
        
        downloadObject.startDate = [NSDate date];
        downloadObject.fileName = fileName;
        downloadObject.directoryName = directory;
        
        _fileIdentifier = urlString;
        [_downloads addEntriesFromDictionary:@{urlString:downloadObject}];
        [downloadTask resume];
    } else {
        
        NSLog(@"File already exists!");
    }
}

#pragma mark - cancelDownloadForUrl...

- (void)cancelDownloadForUrl:(NSString *)fileIdentifier {
    
    DownloaderObject* downloaderObject = [_downloads objectForKey:fileIdentifier];
    
    if (downloaderObject) {
        
        [downloaderObject.downloadTask cancel];
        [_downloads removeObjectForKey:fileIdentifier];
        
        if (downloaderObject.completionBlock) {
       
            downloaderObject.completionBlock(NO);
        }
    }
    
    if (self.downloads.count == 0) {
    
        [self cleanTmpDirectory];
    }
}

#pragma mark - cancelAllDownloads...

- (void)cancelAllDownloads {
    
    [_downloads enumerateKeysAndObjectsUsingBlock:^(id key, DownloaderObject* downloaderObject, BOOL* stop) {
        
        if (downloaderObject.completionBlock) {
            
            downloaderObject.completionBlock(NO);
        }
        
        [downloaderObject.downloadTask cancel];
        [_downloads removeObjectForKey:key];
    }];
    
    [self cleanTmpDirectory];
}

#pragma mark - stopDownLoadForUrl...

- (void)stopDownLoadForUrl:(NSString *)fileIdentifier {
    
    _fileIdentifier = fileIdentifier;
    DownloaderObject* downloaderObject = [_downloads objectForKey:fileIdentifier];
    
    if (!downloaderObject) return;
    
    [downloaderObject.downloadTask cancelByProducingResumeData:^(NSData* resumeData) {
        
        if (!resumeData) return;
        
        [downloaderObject setResumeData:resumeData];
    }];
}

#pragma mark - resumeDownLoadForUrl...

- (void)resumeDownLoadForUrl:(NSString *)fileIdentifier {
    
    _fileIdentifier = fileIdentifier;
    DownloaderObject* downloaderObject = [_downloads objectForKey:fileIdentifier];
    
    if (!downloaderObject.resumeData) return;
    
    // Create Download Task
    downloaderObject.downloadTask = [_session downloadTaskWithResumeData:downloaderObject.resumeData];
    
    // Resume Download Task
    [downloaderObject.downloadTask resume];
    
    // Cleanup
    [downloaderObject setResumeData:nil];
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
//    NSString* fileIdentifier = downloadTask.originalRequest.URL.absoluteString;
    DownloaderObject* downloaderObject = [_downloads objectForKey:_fileIdentifier];
    
    if (downloaderObject.progressBlock) {
    
        CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
        
            if(downloaderObject.progressBlock) {
                
                downloaderObject.progressBlock(progress); //exception when progressblock is nil
            }
        });
    }
    
    CGFloat remainingTime = [self remainingTimeForDownload:downloaderObject bytesTransferred:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    
    if (downloaderObject.remainingTimeBlock) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (downloaderObject.remainingTimeBlock) {
                
                downloaderObject.remainingTimeBlock((NSUInteger)remainingTime);
            }
        });
    }
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  
    NSData* data = [NSData dataWithContentsOfURL:location];
    UIImage* im = [UIImage imageWithData:data];
    
    NSLog(@"Download finisehd!");
    
    NSURL* destinationLocation;
    NSError* error;
   
    DownloaderObject* downloaderObject = [_downloads objectForKey:_fileIdentifier];
    
    BOOL success = YES;
    
    if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSInteger statusCode = [(NSHTTPURLResponse*)downloadTask.response statusCode];

        if (statusCode >= 400) {
            
            NSLog(@"ERROR: HTTP status code %@", @(statusCode));
            success = NO;
        }
    }
    
    if (success) {
        
        if (downloaderObject.directoryName) {
           
            destinationLocation = [[[self cachesDirectoryUrlPath] URLByAppendingPathComponent:downloaderObject.directoryName] URLByAppendingPathComponent:downloaderObject.fileName];
            
        } else {
            
            destinationLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:downloaderObject.fileName];
        }
        
        // Move downloaded item from tmp directory to te caches directory
        // (not synced with user's iCloud documents)
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationLocation error:&error];
       
        if (error) {
        
            NSLog(@"ERROR: %@", error);
        }
    }
    
    if (downloaderObject.completionBlock) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            downloaderObject.completionBlock(success);
        });
    }
    
    // remove object from the download
    [_downloads removeObjectForKey:_fileIdentifier];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Show a local notification when download is over.
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertBody = [NSString stringWithFormat:@"%@ has been downloaded", download.friendlyName];
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    });
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        
        NSLog(@"ERROR: %@", error);
        
        NSString* fileIdentifier = task.originalRequest.URL.absoluteString;
        DownloaderObject* downloaderObject = [_downloads objectForKey:fileIdentifier];
        
        if (downloaderObject.completionBlock) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                downloaderObject.completionBlock(NO);
            });
        }
        
        // remove object from the download
//        [_downloads removeObjectForKey:fileIdentifier];
    }
}

#pragma mark - remainingTimeForDownload

- (CGFloat)remainingTimeForDownload:(DownloaderObject *)download bytesTransferred:(int64_t)bytesTransferred totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:download.startDate];
    CGFloat speed = (CGFloat)bytesTransferred / (CGFloat)timeInterval;
    CGFloat remainingBytes = totalBytesExpectedToWrite - bytesTransferred;
    CGFloat remainingTime =  remainingBytes / speed;
    
    return remainingTime;
}

#pragma mark - File Management

- (BOOL)createDirectoryNamed:(NSString *)directory {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    NSString* targetDirectory = [cachesDirectory stringByAppendingPathComponent:directory];
    
    NSError* error;
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:targetDirectory withIntermediateDirectories:YES attributes:nil error:&error];
}

#pragma mark - cachesDirectoryUrlPath

- (NSURL *)cachesDirectoryUrlPath {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    NSURL* cachesDirectoryUrl = [NSURL fileURLWithPath:cachesDirectory];
    
    return cachesDirectoryUrl;
}

#pragma mark - fileDownloadCompletedForUrl...

- (BOOL)fileDownloadCompletedForUrl:(NSString *)fileIdentifier {
    
    BOOL retValue = YES;
    
    DownloaderObject* downloaderObject = [_downloads objectForKey:fileIdentifier];
 
    if (downloaderObject) {
        
        // downloads are removed once they finish
        retValue = NO;
    }
    return retValue;
}

#pragma mark - isFileDownloadingForUrl

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier {
    
    return [self isFileDownloadingForUrl:fileIdentifier withProgressBlock:nil];
}

#pragma mark - isFileDownloadingForUrl

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier withProgressBlock:(void(^)(CGFloat progress))block {
    
    return [self isFileDownloadingForUrl:fileIdentifier withProgressBlock:block completionBlock:nil];
}

#pragma mark - isFileDownloadingForUrl

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier withProgressBlock:(void(^)(CGFloat progress))block completionBlock:(void(^)(BOOL completed))completionBlock {
    
    BOOL retValue = NO;
    
    DownloaderObject* downloaderObject = [_downloads objectForKey:fileIdentifier];
    
    if (downloaderObject) {
        
        if (block) {
            
            downloaderObject.progressBlock = block;
        }
        
        if (completionBlock) {
            
            downloaderObject.completionBlock = completionBlock;
        }
        
        retValue = YES;
    }
    return retValue;
}

#pragma mark File existance

- (NSString *)localPathForFile:(NSString *)fileIdentifier {
    
    return [self localPathForFile:fileIdentifier inDirectory:nil];
}

#pragma mark - localPathForFile

- (NSString *)localPathForFile:(NSString *)fileIdentifier inDirectory:(NSString *)directoryName {
    
    NSString* fileName = [fileIdentifier lastPathComponent];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    
    return [[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName];
}

#pragma mark - fileExistsForUrl

- (BOOL)fileExistsForUrl:(NSString *)urlString {
    
    return [self fileExistsForUrl:urlString inDirectory:nil];
}

#pragma mark - fileExistsForUrl

- (BOOL)fileExistsForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName {
    
    return [self fileExistsWithName:[urlString lastPathComponent] inDirectory:directoryName];
}

#pragma mark - fileExistsWithName...

- (BOOL)fileExistsWithName:(NSString *)fileName inDirectory:(NSString *)directoryName {
    
    BOOL exists = NO;
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    
    // if no directory was provided, we look by default in the base cached dir
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName]]) {
        
        exists = YES;
    }
    
    return exists;
}

#pragma mark - fileExistsWithName

- (BOOL)fileExistsWithName:(NSString *)fileName {
    
    return [self fileExistsWithName:fileName inDirectory:nil];
}

#pragma mark - deleteFileForUrl

- (BOOL)deleteFileForUrl:(NSString *)urlString {
    
    return [self deleteFileForUrl:urlString inDirectory:nil];
}

#pragma mark - deleteFileForUrl

- (BOOL)deleteFileForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName {
    
    return [self deleteFileWithName:[urlString lastPathComponent] inDirectory:directoryName];
}

#pragma mark - deleteFileWithName

- (BOOL)deleteFileWithName:(NSString *)fileName {
    
    return [self deleteFileWithName:fileName inDirectory:nil];
}

#pragma mark - deleteFileWithName

- (BOOL)deleteFileWithName:(NSString *)fileName inDirectory:(NSString *)directoryName {
    
    BOOL deleted = NO;
    NSError* error;
    NSURL* fileLocation;
    
    if (directoryName) {
        
        fileLocation = [[[self cachesDirectoryUrlPath] URLByAppendingPathComponent:directoryName] URLByAppendingPathComponent:fileName];
    } else {
        
        fileLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:fileName];
    }
    
    // Move downloaded item from tmp directory to te caches directory
    // (not synced with user's iCloud documents)
    [[NSFileManager defaultManager] removeItemAtURL:fileLocation error:&error];
    
    if (error) {
        
        deleted = NO;
        NSLog(@"Error deleting file: %@", error);
    } else {
        
        deleted = YES;
    }
    
    return deleted;
}

#pragma mark - Clean directory

- (void)cleanDirectoryNamed:(NSString *)directory {
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    
    for (NSString* file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
    
        [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
    }
}

#pragma mark - Clean directory

- (void)cleanTmpDirectory {
    
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    
    for (NSString* file in tmpDirectory) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

#pragma mark - Background download

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    // Check if all download tasks have been finished.
    [session getTasksWithCompletionHandler:^(NSArray* dataTasks, NSArray* uploadTasks, NSArray* downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            
            if (_backgroundTransferCompletionHandler != nil) {
                
                // Copy locally the completion handler.
                void(^completionHandler)() = _backgroundTransferCompletionHandler;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    // Show a local notification when all downloads are over.
//                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
//                    localNotification.alertBody = @"All files have been downloaded!";
//                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
                
                // Make nil the backgroundTransferCompletionHandler.
                _backgroundTransferCompletionHandler = nil;
            }
        }
    }];
}

#pragma mark - currentDownloads...

- (NSArray *)currentDownloads {
    
    NSMutableArray* currentDownloads = [NSMutableArray new];
    
    [_downloads enumerateKeysAndObjectsUsingBlock:^(id key, DownloaderObject* download, BOOL* stop) {
        
        [currentDownloads addObject:download.downloadTask.originalRequest.URL.absoluteString];
    }];
    
    return currentDownloads;
}

@end
