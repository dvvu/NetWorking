//
//  ProgressTableViewCell.h
//  NetWorking
//
//  Created by Doan Van Vu on 8/17/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "TabbleCellDelegate.h"
#import <UIKit/UIKit.h>

#pragma mark - DownloadButtonType
typedef enum {
    
    StartStype = 0,
    PauseStype = 1,
    ResumeStype = 2,
} DownloadButtonType;

@interface ProgressTableViewCell : UITableViewCell

@property (nonatomic) id<TabbleCellDelegate> delegate;
@property (nonatomic) UILabel* taskLabel;
@property (nonatomic) UILabel* infoLabel;
@property (nonatomic) UIButton* downloadButton;
@property (nonatomic) UIButton* cancelButton;
@property (nonatomic) NSString* link;

- (void)startDownload;

@end
