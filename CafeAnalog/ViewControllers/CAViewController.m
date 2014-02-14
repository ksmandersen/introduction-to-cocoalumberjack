//
//  CAViewController.m
//  CafeAnalog
//
//  Created by Kristian Andersen on 13/02/14.
//  Copyright (c) 2014 Kristian Andersen. All rights reserved.
//

#import "CAViewController.h"
#import "UIImage+CAAnimatedGif.h"

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, CACafeStatus) {
    CACafeStatusOpen,
    CACafeStatusClosed
};

@interface CAViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, assign) CACafeStatus currentStatus;

@end

@implementation CAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    NSString *urlString = @"http://cafeanalog.dk/";

    __weak CAViewController *weakSelf = self;
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [requestManager GET:urlString
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    CAViewController *strongSelf = weakSelf;
                    
                    NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    DDLogVerbose(@"Got response: %@", htmlString);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        strongSelf.currentStatus = [self statusForPageContent:htmlString];
                        [strongSelf updateWithCurrentStatus];
                    });
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DDLogError(@"Error when fetching status: %@, %@", error, error.userInfo);
                }];
}

- (UIImage *)randomImageForStatus:(CACafeStatus)status {
    NSString *imageName = (status == CACafeStatusOpen) ? @"open" : @"closed";
    srand(time(0));
    int randomNumber =  rand() % 3 + 1;
    
    NSString *randomImage = [NSString stringWithFormat:@"%@%i",imageName, randomNumber];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:randomImage withExtension:@"gif"];
    return [UIImage ca_imageWithAnimatedGIFURL:url];
}

- (CACafeStatus)statusForPageContent:(NSString *)content {
    BOOL open = ([content rangeOfString:@"We're Åpen!"].location != NSNotFound);
    return open ? CACafeStatusOpen : CACafeStatusClosed;
}

- (void)updateWithCurrentStatus {
    NSString *status = (self.currentStatus == CACafeStatusOpen) ? @"Open" : @"Closed";
    UIImage *randomImage = [self randomImageForStatus:self.currentStatus];

    DDLogVerbose(@"Updating view for status: %@", status);
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.imageView setAlpha:0];
        [self.statusLabel setAlpha:0];
    } completion:^(BOOL finished) {
        [self.imageView setImage:randomImage];
        [self.statusLabel setText:status];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                          target:self
                                                        selector:@selector(updateWithCurrentStatus)
                                                        userInfo:nil
                                                         repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        [UIView animateWithDuration:1.0f animations:^{
            [self.imageView setAlpha:1];
            [self.statusLabel setAlpha:1];
        }];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
