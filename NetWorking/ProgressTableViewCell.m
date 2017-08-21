//
//  ProgressTableViewCell.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/17/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ProgressTableViewCell.h"
#import "Masonry.h"

@interface ProgressTableViewCell ()

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
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    _taskLabel = [[UILabel alloc] init];
    _taskLabel.text = @"task";
    [_taskLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:_taskLabel];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.text = @"info";
    [_infoLabel setTextColor:[UIColor whiteColor]];
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
    
    NSLog(@"Button  clicked.");
}

#pragma mark - cancelAction

- (void)cancelAction:(UIButton *)sender {
    
    NSLog(@"Button  clicked.");
}

@end
