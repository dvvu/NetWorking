//
//  ViewController.m
//  NetWorking
//
//  Created by Doan Van Vu on 8/17/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ProgressTableViewCell.h"
#import "ViewController.h"
#import "Masonry.h"

@interface ViewController () <NSURLSessionDelegate, NSURLSessionDownloadDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) ProgressTableViewCell* cell;
@property (nonatomic) UITableView* tableView;

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
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.edges.equalTo(self.view);
    }];
    
    // Create Session Configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Configure Session Configuration
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
    
    // Create Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    // Send Request
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/search?term=apple&media=software"];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        
    }] resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
//    NSData* data = [NSData dataWithContentsOfURL:location];
    dispatch_async(dispatch_get_main_queue(), ^{
        
         _cell.infoLabel.text = @"done";
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSLog(@"%lld",totalBytesWritten);
    
    NSString* info = [NSString stringWithFormat:@"%lld byte/ %lld byte",totalBytesWritten,totalBytesExpectedToWrite];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // progress update ìno
        _cell.infoLabel.text = [@"downloading..." stringByAppendingString:info];
    });
}

#pragma - tableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma - tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

#pragma - tableview Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProgressTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        
        cell = [[ProgressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    return cell;
}

#pragma - tableview Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/1/11/Im_the_biggest_of_all%21_%282910772407%29.jpg"]];
    [downloadTask resume];
}

@end
