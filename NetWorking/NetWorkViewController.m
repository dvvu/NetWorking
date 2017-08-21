//
//  NetWorkViewController.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/18/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "NetWorkViewController.h"
#import "DownloadManager.h"

#define FILE_URL @"http://ovh.net/files/10Mio.dat"

@interface NetWorkViewController ()

@property (weak, nonatomic) IBOutlet UILabel* mainLabel;
@property (weak, nonatomic) IBOutlet UIProgressView* progressView;
@property (weak, nonatomic) IBOutlet UIButton* startButton;
@property (weak, nonatomic) IBOutlet UIButton* cancelButton;
@property (weak, nonatomic) IBOutlet UIButton* deleteButton;
@property (weak, nonatomic) IBOutlet UIButton* stopButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (assign, nonatomic) CGFloat progress;

- (IBAction)startDownload:(id)sender;
- (IBAction)cancelDownload:(id)sender;
- (IBAction)deleteFiles:(id)sender;
- (IBAction)stopDownload:(id)sender;
- (IBAction)resumeDownload:(id)sender;

@end

@implementation NetWorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _progressView.progress = 0.0f;
    _mainLabel.text = @"NETWORK DEMO";
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:FILE_URL]) {
        
        _deleteButton.enabled = YES;
        _cancelButton.enabled = NO;
        _startButton.enabled = NO;
    } else {
        
        _deleteButton.enabled = NO;
        _cancelButton.enabled = NO;
        _startButton.enabled = YES;
    }
}

- (IBAction)startDownload:(id)sender {
    
    // Just a demo example file...
    [[DownloadManager sharedManager] downloadFileForURL:FILE_URL withName:[FILE_URL lastPathComponent] inDirectoryNamed:@"" progressBlock:^(CGFloat progress) {
        
        NSLog(@"%.2f", progress);
        _progress = progress;
        _progressView.progress = progress;
        
    } remainingTime:^(NSUInteger seconds) {
        
        NSLog(@"ETA: %lu sec.", (unsigned long)seconds);
        _mainLabel.text = [NSString stringWithFormat:@"Progress: %.0f%% - ETA: %lu sec.", _progress * 100, (unsigned long)seconds];
        
    } completionBlock:^(BOOL completed) {
        
        NSLog(@"Download completed!");
        _deleteButton.enabled = YES;
        _cancelButton.enabled = NO;
        _startButton.enabled = NO;
    } enableBackgroundMode:YES];
    
    _cancelButton.enabled = YES;
    _startButton.enabled = NO;
}

- (IBAction)cancelDownload:(id)sender {
    
    [[DownloadManager sharedManager] cancelAllDownloads];
    [self nilProgress];
    
    _startButton.enabled = YES;
    _cancelButton.enabled = NO;
    _deleteButton.enabled = NO;
}

- (IBAction)deleteFiles:(id)sender {
    
    [[DownloadManager sharedManager] deleteFileForUrl:FILE_URL];
    [self nilProgress];
    
    _deleteButton.enabled = NO;
    _startButton.enabled = YES;
    _cancelButton.enabled = NO;
}

- (IBAction)stopDownload:(id)sender {
    
    [[DownloadManager sharedManager] stopDownLoadForUrl:FILE_URL];
}

- (IBAction)resumeDownload:(id)sender {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:FILE_URL];
}

- (void)nilProgress {
    
    _progressView.progress = 0.0f;
    _progress = 0.0f;
    _mainLabel.text = @"NETWORK DEMO";
}

@end
