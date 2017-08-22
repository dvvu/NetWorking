//
//  FileDownloadInfo.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/21/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "FileDownloadInfo.h"

@implementation FileDownloadInfo

-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source{
 
    if (self == [super init]) {
        
        self.fileTitle = title;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    
    return self;
}

@end
