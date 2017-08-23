//
//  TabbleCellDelegate.h
//  NetWorking
//
//  Created by Doan Van Vu on 8/21/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TabbleCellDelegate <NSObject>

#pragma mark - startDownload
- (void)startDownload;

#pragma mark - pauseDownload
- (void)pauseDownload;

#pragma mark - resumeDownload
- (void)resumeDownload;

#pragma mark - cancelDownload
- (void)cancelDownload;

#pragma mark - stopDownload
- (void)stopDownload;

@end
