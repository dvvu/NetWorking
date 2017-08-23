//
//  testViewController.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/21/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "testViewController.h"
#import "DownloadManager.h"

@interface testViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *v1;
@property (weak, nonatomic) IBOutlet UIProgressView *v2;
@property (weak, nonatomic) IBOutlet UIProgressView *v3;
@property (weak, nonatomic) IBOutlet UIProgressView *v4;
@property (weak, nonatomic) IBOutlet UIProgressView *v5;
@property (nonatomic) NSArray* links;

@end

@implementation testViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _links = @[@"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg",
               @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg",
               @"http://spaceflight.nasa.gov/gallery/images/apollo-soyuz/apollo-soyuz/hires/s75-33375.jpg",
               @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-134-20380.jpg",
               @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-140-21497.jpg",
               @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-148-22727.jpg"];
}

- (IBAction)start1:(id)sender {
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:_links[0]]) {
        
        
    } else {
        
        [self startDownload:_links[0] with:_v1];
    }
}
- (IBAction)start2:(id)sender {
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:_links[1]]) {
        
        
    } else {
        
        [self startDownload:_links[1] with:_v2];
    }
}
- (IBAction)start3:(id)sender {
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:_links[2]]) {
        
        
    } else {
        
        [self startDownload:_links[2] with:_v3];
    }
}
- (IBAction)start4:(id)sender {
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:_links[3]]) {
       
        
    } else {
        [self startDownload:_links[3] with:_v4];
    }
}

- (IBAction)start5:(id)sender {
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:_links[4]]) {
        
        
    } else {
        [self startDownload:_links[4] with:_v5];
    }
}
- (IBAction)stop1:(id)sender {
    
    [[DownloadManager sharedManager] pauseDownLoadForUrl:_links[0]];
}
- (IBAction)stop2:(id)sender {
    
    [[DownloadManager sharedManager] pauseDownLoadForUrl:_links[1]];
}
- (IBAction)stop3:(id)sender {
    
    [[DownloadManager sharedManager] pauseDownLoadForUrl:_links[2]];
}
- (IBAction)stop4:(id)sender {
    
    [[DownloadManager sharedManager] pauseDownLoadForUrl:_links[3]];
}
- (IBAction)stop5:(id)sender {
    
    [[DownloadManager sharedManager] pauseDownLoadForUrl:_links[4]];
}

- (IBAction)cancel1:(id)sender {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:_links[0]];
}

- (IBAction)cancel2:(id)sender {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:_links[1]];
}

- (IBAction)cancel3:(id)sender {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:_links[2]];
}

- (IBAction)cancel4:(id)sender {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:_links[3]];
}

- (IBAction)cancel5:(id)sender {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:_links[4]];
}

- (IBAction)startAll:(id)sender {
    
}

- (IBAction)stopAll:(id)sender {
    
    
}

#pragma mark - startDownload

- (void)startDownload:(NSString *)link with:(UIProgressView *)v {
    
    [[DownloadManager sharedManager] downloadFileForURL:link withName:[link lastPathComponent] inDirectoryNamed:@"" progressBlock:^(CGFloat progress) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSLog(@"%.2f", progress);
            v.progress = progress;
        }];
        
    } remainingTime:^(NSUInteger seconds) {
        
//        NSLog(@"ETA: %lu sec.", (unsigned long)seconds);
        
    } completionBlock:^(BOOL completed) {
        
        NSLog(@"Download completed!");
    }];
}

#pragma mark - stopDownload

- (void)stopDownload:(NSString *)link {
    
    [[DownloadManager sharedManager] pauseDownLoadForUrl:link];
}

@end
