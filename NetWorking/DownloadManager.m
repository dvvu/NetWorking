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
        
        // Background session
        _backgroundSession = [self sharedBackgroundSession];
        _downloads = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - sharedBackgroundSession...

- (NSURLSession *)sharedBackgroundSession {
    
    static NSURLSession* session = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"abs.com.DownloadApp"];
        configuration.HTTPMaximumConnectionsPerHost = 5;

        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    
    return session;
}

#pragma mark - downloadFileForURL...

- (void)downloadFileForURL:(NSString *)urlString withName:(NSString *)fileName inDirectoryNamed:(NSString *)directory progressBlock:(void(^)(CGFloat progress))progressBlock remainingTime:(void(^)(NSUInteger seconds))remainingTimeBlock completionBlock:(void(^)(BOOL completed))completionBlock {
    
    NSLog(@"%@", fileName);
    NSURL* url = [NSURL URLWithString:urlString];
    
    // check links download yet?
    if (![self fileDownloadCompletedForUrl:urlString]) {
        
        NSLog(@"File is downloading!");
        
        // check file exits in directory yet?
    } else if (![self fileExistsWithName:fileName inDirectory:directory]) {
        
        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]; //[NSURLRequest requestWithURL:url];
      
        NSURLSessionDownloadTask* downloadTask;
        downloadTask = [_backgroundSession downloadTaskWithRequest:request];
        
//        downloadTask = [_backgroundSession downloadTaskWithRequest:request completionHandler:^(NSURL* _Nullable location, NSURLResponse* _Nullable response, NSError * _Nullable error) {
//            
//            if (!error && response) {
//                
//            } else {
//                
//                
//            }
//        }];
        
        DownloaderObject* downloadObject = [[DownloaderObject alloc] initWithDownloaderTask:downloadTask progressBlock:progressBlock remainingTime:remainingTimeBlock completionBlock:completionBlock];
        
        downloadObject.startDate = [NSDate date];
        downloadObject.fileName = fileName;
        downloadObject.directoryName = directory;
        downloadObject.url = urlString;
        [_downloads setObject:downloadObject forKey:@(downloadTask.taskIdentifier)];
        [downloadTask resume];
    } else {
        
        NSLog(@"File already exists!");
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
}

#pragma mark - cancelDownloadForUrl...

- (void)cancelDownloadForUrl:(NSString *)fileIdentifier {
    
    NSInteger aDownloadID = [self downloadIDForActiveDownloadURL:fileIdentifier];
    DownloaderObject* downloaderObject = [_downloads objectForKey:@(aDownloadID)];
    
    if (downloaderObject) {
        
        [downloaderObject.downloadTask cancel];
        [_downloads removeObjectForKey:@(aDownloadID)];
        
        if (downloaderObject.completionBlock) {
       
            downloaderObject.completionBlock(NO);
        }
    }
}

#pragma mark - pauseDownLoadForUrl...

- (void)pauseDownLoadForUrl:(NSString *)fileIdentifier {
    
    NSInteger aDownloadID = [self downloadIDForActiveDownloadURL:fileIdentifier];
    DownloaderObject* downloaderObject = [_downloads objectForKey:@(aDownloadID)];
    
    if (!downloaderObject) return;
    
    [downloaderObject.downloadTask cancelByProducingResumeData:^(NSData* resumeData) {
        
        if (!resumeData) return;
        
        [downloaderObject setResumeData:resumeData];
    }];
}

#pragma mark - resumeDownLoadForUrl...

- (void)resumeDownLoadForUrl:(NSString *)fileIdentifier {
    
    NSInteger aDownloadID = [self downloadIDForActiveDownloadURL:fileIdentifier];
    DownloaderObject* downloaderObject = [_downloads objectForKey:@(aDownloadID)];
    
    if (!downloaderObject.resumeData) return;
    
    // Create Download Task
    downloaderObject.downloadTask = [_backgroundSession downloadTaskWithResumeData:downloaderObject.resumeData];
    
    downloaderObject.url = fileIdentifier;
    [_downloads setObject:downloaderObject forKey:@(downloaderObject.downloadTask.taskIdentifier)];
    
    // Resume Download Task
    [downloaderObject.downloadTask resume];
    
    // Cleanup
    downloaderObject.resumeData = nil;
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    DownloaderObject* downloaderObject = [_downloads objectForKey:@(downloadTask.taskIdentifier)];
    
    if (downloaderObject) {
        
        if (downloaderObject.progressBlock) {
            
            CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                if(downloaderObject.progressBlock) {
                    
                    downloaderObject.progressBlock(progress);
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
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"Download finisehd!");
    DownloaderObject* downloaderObject = [_downloads objectForKey:@(downloadTask.taskIdentifier)];
    
    if (downloaderObject) {
        
        NSURL* destinationLocation;
        NSError* error;
        BOOL success = YES;
        
        // if download failed -> success = NO
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
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationLocation error:&error];
            
            if (error) {
                
                NSLog(@"Move item at URL ERROR: %@", error);
            }
            
            [_downloads removeObjectForKey:@(downloadTask.taskIdentifier)];
        }
        
        if (downloaderObject.completionBlock) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                downloaderObject.completionBlock(success);
            });
        }
    }
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        
        NSLog(@"-ERROR-: %@", error);
        DownloaderObject* downloaderObject = [_downloads objectForKey:@(task.taskIdentifier)];

        if (downloaderObject.completionBlock) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                downloaderObject.completionBlock(NO);
            });
        }
        
        downloaderObject.downloadTask = nil;
    }
}

#pragma mark - remainingTimeForDownload

- (CGFloat)remainingTimeForDownload:(DownloaderObject *)downloaderObject bytesTransferred:(int64_t)bytesTransferred totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:downloaderObject.startDate];
    CGFloat speed = (CGFloat)bytesTransferred / (CGFloat)timeInterval;
    CGFloat remainingBytes = totalBytesExpectedToWrite - bytesTransferred;
    CGFloat remainingTime = remainingBytes / speed;
    
    return remainingTime;
}

#pragma mark - cachesDirectoryUrlPath

- (NSURL *)cachesDirectoryUrlPath {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    NSURL* cachesDirectoryUrl = [NSURL fileURLWithPath:cachesDirectory];
    
    return cachesDirectoryUrl;
}

#pragma mark - fileDownloadCompletedForUrl...

- (NSString *)localPathForFile:(NSString *)fileIdentifier {
    
    return [self localPathForFile:fileIdentifier inDirectory:nil];
}

#pragma mark - fileDownloadCompletedForUrl...

- (NSString *)localPathForFile:(NSString *)fileIdentifier inDirectory:(NSString *)directoryName {
    
    NSString* fileName = [fileIdentifier lastPathComponent];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    
    return [[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName];
}

#pragma mark - fileDownloadCompletedForUrl...

- (BOOL)fileDownloadCompletedForUrl:(NSString *)fileIdentifier {
    
    BOOL retValue = YES;
    
    NSInteger aDownloadID = [self downloadIDForActiveDownloadURL:fileIdentifier];
    DownloaderObject* downloaderObject = [_downloads objectForKey:@(aDownloadID)];
 
    if (downloaderObject) {
        
        // maybe downloads are removed once they finish
        retValue = NO;
    }
    return retValue;
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
    
    if ([self fileExistsWithName:fileName inDirectory:directoryName]) {
        
        // Move downloaded item from tmp directory to te caches directory
        [[NSFileManager defaultManager] removeItemAtURL:fileLocation error:&error];
        
        if (error) {
            
            deleted = NO;
            NSLog(@"Error deleting file: %@", error);
        } else {
            
            deleted = YES;
        }
    }
    
     return deleted;
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
                }];
                
                // Make nil the backgroundTransferCompletionHandler.
                _backgroundTransferCompletionHandler = nil;
            }
        }
    }];
}

#pragma mark - downloadIDForActiveDownloadURL...

- (NSInteger)downloadIDForActiveDownloadURL:(nonnull NSString *)url {
    
    NSInteger aFoundDownloadID = -1;
    NSArray* aDownloadKeysArray = [_downloads allKeys];
 
    for (NSNumber* aDownloadID in aDownloadKeysArray) {
        
        DownloaderObject* aDownloadItem = [_downloads objectForKey:aDownloadID];
        
        if ([aDownloadItem.url isEqualToString:url]) {
            
            aFoundDownloadID = [aDownloadID unsignedIntegerValue];
            break;
        }
    }
    return aFoundDownloadID;
}

#pragma mark - currentDownloads...

- (NSArray *)currentDownloads {
    
    NSMutableArray* currentDownloads = [NSMutableArray new];
    
    [_downloads enumerateKeysAndObjectsUsingBlock:^(id key, DownloaderObject* download, BOOL* stop) {
        
        [currentDownloads addObject:download.url];
    }];
    
    return currentDownloads;
}

@end
