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

@property (nonatomic) DownloadButtonStype downloadButtonStype;
@property (nonatomic) CancelButtonStype cancelButtonStyle;
@property (nonatomic) DownloaderObject* downloaderObject;
@property (nonatomic) UIProgressView* progressView;

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
    
    _downloadButtonStype = DownloadStype;
    _cancelButtonStyle = CancelStype;
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
    [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
    [self addSubview:_downloadButton];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];
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
    
    _progressView = [[UIProgressView alloc] init];
    _progressView.progress = 0;
    [self addSubview:_progressView];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.left.equalTo(self).offset(8);
        make.right.equalTo(_downloadButton.mas_left).offset(-8);
        make.bottom.equalTo(self).offset(-2);
    }];
}

- (void)setLink:(NSString *)link {
    
    _link = link;
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:link]) {
        
        _infoLabel.text = @"is Downloaded";
        _downloadButton.enabled = NO;
        _cancelButton.enabled = NO;
        [_progressView setHidden:YES];
    } else {
        
        _infoLabel.text = @"Ready";
        _downloadButton.enabled = YES;
        _cancelButton.enabled = YES;
        [_progressView setHidden:NO];
    }
}

#pragma mark - downloadAction

- (void)downloadAction:(UIButton *)sender {
    
    if (_downloadButtonStype == DownloadStype) {
        
        _downloadButtonStype = PauseStype;
        [_delegate startDownload];
        [_downloadButton setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
        [self startDownload];
    } else if (_downloadButtonStype == PauseStype) {
        
        _downloadButtonStype = ResumeStype;
        [_delegate pauseDownload];
        [_downloadButton setImage:[UIImage imageNamed:@"ic_start"] forState:UIControlStateNormal];
        [self pauseDownload];
    } else {
        
        _downloadButtonStype = PauseStype;
        [_delegate resumeDownload];
        [_downloadButton setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
        [self resumeDownload];
    }
}

#pragma mark - cancelAction

- (void)stopAction:(UIButton *)sender {

    [self cancelDownload];
}

#pragma mark - startDownload

- (void)startDownload {
    
    [[DownloadManager sharedManager] downloadFileForURL:_link withName:[_link lastPathComponent] inDirectoryNamed:@"" progressBlock:^(CGFloat progress) {
        
        _progressView.progress = progress;
    } remainingTime:^(NSUInteger seconds) {
        
        NSLog(@"ETA: %lu sec.", (unsigned long)seconds);

        _infoLabel.text = [NSString stringWithFormat:@"%.0f%% - ETA: %lu s.", _progressView.progress * 100, (unsigned long)seconds];
    } completionBlock:^(BOOL completed) {
        
        if (completed) {
            
            UIImage* image =[UIImage imageWithContentsOfFile:[[DownloadManager sharedManager] localPathForFile:_link]];
            
            if (image) {
                
              [_downloadButton setImage:image forState:UIControlStateNormal];
            }
            
            _infoLabel.text = @"is Downloaded";
            _downloadButton.enabled = NO;
            _cancelButton.enabled = NO;
            _progressView.progress = 0.0;
            [_progressView setHidden:YES];
        }
    }];
}

#pragma mark - stopDownload

- (void)pauseDownload {
    
    [[DownloadManager sharedManager] pauseDownLoadForUrl:_link];
}

#pragma mark - resumeDownload

- (void)resumeDownload {
    
    [[DownloadManager sharedManager] resumeDownLoadForUrl:_link];
}

#pragma mark - cancelDownload

- (void)cancelDownload {
    
    [[DownloadManager sharedManager] cancelDownloadForUrl:_link];
    _infoLabel.text = @"Ready";
    _downloadButtonStype = DownloadStype;
    _progressView.progress = 0.0;
    [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
}

#pragma mark - stopDownload

- (void)stopDownload {

}

@end
