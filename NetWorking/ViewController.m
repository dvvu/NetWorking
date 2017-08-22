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

#define FILE_URL @"http://ovh.net/files/10Mio.dat"
#define FILE_URL1 @"http://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, TabbleCellDelegate>

@property (nonatomic) ProgressTableViewCell* cell;
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
      
        make.edges.equalTo(self.view);
    }];
    
//    _links = [NSArray arrayWithObjects:FILE_URL,FILE_URL1, nil];
    
    _links = @[@"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg",
                            @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg",
                            @"http://spaceflight.nasa.gov/gallery/images/apollo-soyuz/apollo-soyuz/hires/s75-33375.jpg",
                            @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-134-20380.jpg",
                            @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-140-21497.jpg",
                            @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-148-22727.jpg"];
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
    cell.delegate = self;
    
    
    if ([[DownloadManager sharedManager] fileExistsForUrl:_links[indexPath.row]]) {
        [cell startDownload];
    }
    
    return cell;
}

#pragma mark - startDownload

- (void)startDownload {
    
}

#pragma mark - pauseDownload

- (void)pauseDownload {
    
}

#pragma mark - resumeDownload

- (void)resumeDownload {
    
}

#pragma mark - cancelDownload

- (void)cancelDownload {
    
}

@end
