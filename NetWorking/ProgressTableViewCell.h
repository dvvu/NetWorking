//
//  ProgressTableViewCell.h
//  NetWorking
//
//  Created by Doan Van Vu on 8/17/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressTableViewCell : UITableViewCell

@property (nonatomic) UILabel* taskLabel;
@property (nonatomic) UILabel* infoLabel;
@property (nonatomic) UIButton* downloadButton;
@property (nonatomic) UIButton* cancelButton;

@end
