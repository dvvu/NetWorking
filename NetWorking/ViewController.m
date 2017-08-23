//
//  ViewController.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/17/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ProgressTableViewCell.h"
#import "TabbleCellDelegate.h"
#import "DownloadManager.h"
#import "ViewController.h"
#import "Masonry.h"

#define FILE_URL  @"http://ovh.net/files/10Mio.dat"
#define FILE_URL1 @"http://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"
#define FILE_URL2 @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg"
#define FILE_URL3 @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg"
#define FILE_URL4 @"http://spaceflight.nasa.gov/gallery/images/apollo-soyuz/apollo-soyuz/hires/s75-33375.jpg"
#define FILE_URL5 @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-134-20380.jpg"
#define FILE_URL6 @"http://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView* tableView;
@property (nonatomic) NSArray* links;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _tableView = [[UITableView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
    [_tableView setBackgroundColor:[UIColor grayColor]];
    [_tableView registerClass:[ProgressTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
      
        make.top.equalTo(self.view).offset(65);
        make.left.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(-40);
        make.right.equalTo(self.view).offset(0);
    }];
    
    _links = @[FILE_URL,FILE_URL1,FILE_URL2,FILE_URL3,FILE_URL4,FILE_URL5,FILE_URL6];
}

#pragma - tableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma - tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _links.count;
}

#pragma - tableview Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProgressTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[ProgressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.taskLabel.text = [_links[indexPath.row] lastPathComponent];
    cell.link = _links[indexPath.row];
    
    return cell;
}

#pragma - startAll

- (IBAction)resumeAll:(id)sender {
    
    NSArray* currentDownload = [[DownloadManager sharedManager] currentDownloads];
    
    for (int i = 0; i< currentDownload.count; i++) {
        
        [[DownloadManager sharedManager] resumeDownLoadForUrl:[currentDownload objectAtIndex:i]];
    }
}

#pragma - pasueAll

- (IBAction)pasueAll:(id)sender {
   
    NSArray* currentDownload = [[DownloadManager sharedManager] currentDownloads];
    
    for (int i = 0; i< currentDownload.count; i++) {
        
        [[DownloadManager sharedManager] pauseDownLoadForUrl:[currentDownload objectAtIndex:i]];
    }
}

#pragma - clearCaches

- (IBAction)clearCaches:(id)sender {
    
    for (int i = 0; i < _links.count; i++) {
        
        [[DownloadManager sharedManager] deleteFileForUrl:_links[i]];
    }
    
    [_tableView reloadData];
}

@end
