//
//  ProgressTableViewCell.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/17/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ProgressTableViewCell.h"
#import "DownloaderObject.h"
#import "DownloadManager.h"
#import "Masonry.h"

@interface ProgressTableViewCell ()

@property (nonatomic) DownloaderObject* downloaderObject;
@property (nonatomic) DownloadButtonType type;
@property (nonatomic) CGFloat progress;

@end

@implementation ProgressTableViewCell

#pragma mark - initWithStyle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self setupLayout];
    }
    
    return self;
}

#pragma mark - setupLayout

- (void)setupLayout {
    
    _type = StartStype;
    [self setBackgroundColor:[UIColor clearColor]];
    
    _taskLabel = [[UILabel alloc] init];
    _taskLabel.text = @"Task download name";
    [_taskLabel setTextColor:[UIColor redColor]];
    [_taskLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:_taskLabel];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.text = @"Download infomation";
    [_infoLabel setFont:[UIFont systemFontOfSize:12]];
    [_infoLabel setTextColor:[UIColor greenColor]];
    [self addSubview:_infoLabel];
    
    _downloadButton = [[UIButton alloc] init];
    [_downloadButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [_downloadButton setImage:[UIImage imageNamed:@"ic_start"] forState:UIControlStateNormal];
    [self addSubview:_downloadButton];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setImage:[UIImage imageNamed:@"ic_stop"] forState:UIControlStateNormal];
    [self addSubview:_cancelButton];
    
    [_taskLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.left.equalTo(self).offset(8);
        make.centerY.equalTo(self);
        make.right.equalTo(_downloadButton.mas_left).offset(-8);
    }];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.right.equalTo(self).offset(-8);
        make.centerY.equalTo(self);
        make.width.and.height.mas_equalTo(30);
    }];
    
    [_downloadButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.right.equalTo(_cancelButton.mas_left).offset(-8);
        make.centerY.equalTo(self);
        make.width.and.height.mas_equalTo(30);
    }];
    
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.right.equalTo(_downloadButton.mas_left).offset(-8);
        make.centerY.equalTo(self);
    }];
}

#pragma mark - downloadAction

- (void)downloadAction:(UIButton *)sender {
    
    if (_type == StartStype) {
        
        _type = PauseStype;
        [_delegate startDownload];
        [_downloadButton setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
        [self startDownload];
    } else if (_type == PauseStype) {
        
        _type = ResumeStype;
        [_delegate pauseDownload];
        [_downloadButton setImage:[UIImage imageNamed:@"ic_start"] forState:UIControlStateNormal];
        [self stopDownload];
    } else {
        
        _type = PauseStype;
        [_delegate resumeDownload];
        [_downloadButton setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
        [self resumeDownload];
    }
}

#pragma mark - cancelAction

- (void)cancelAction:(UIButton *)sender {
    
    [_delegate cancelDownload];
    [self cancelDownload];
}

#pragma mark - startDownload

- (void)startDownload {
    
    [[DownloadManager sharedManager] downloadFileForURL:_link withName:[_link lastPathComponent] inDirectoryNamed:@"" progressBlock:^(CGFloat progress) {
        
        _progress = progress;
        NSLog(@"%.2f", progress);
    } remainingTime:^(NSUInteger seconds) {
        
        NSLog(@"ETA: %lu sec.", (unsigned long)seconds);

        _infoLabel.text = [NSString stringWithFormat:@"Progress: %.0f%% - ETA: %lu sec.", _progress * 100, (unsigned long)seconds];
    } completionBlock:^(BOOL completed) {
        
        NSLog(@"Download completed!");
    } enableBackgroundMode:YES];
}

#pragma mark - stopDownload

- (void)stopDownload {
    
    [[DownloadManager sharedManager] stopDownLoadForUrl:_link];
}

#pragma mark - resumeDownload

- (void)resumeDownload {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:_link];
}

#pragma mark - cancelDownload

- (void)cancelDownload {
    
    [[DownloadManager sharedManager] cancelDownloadForUrl:_link];
    _progress = 0.0f;
    _infoLabel.text = @"0%";
    _type = StartStype;
}

@end
