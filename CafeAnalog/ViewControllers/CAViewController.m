//
//  CAViewController.m
//  CafeAnalog
//
//  Created by Kristian Andersen on 13/02/14.
//  Copyright (c) 2014 Kristian Andersen. All rights reserved.
//

#import "CAViewController.h"
#import "UIImage+CAAnimatedGif.h"
#import "CAAPI.h"

#import <AFNetworking/AFNetworking.h>

@interface CAViewController () {
    NSTimer *_rotatingTimer;
}

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) CACafeStatus currentStatus;

@end

@implementation CAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    [self updateData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willEnterForeground:(NSNotification *)notification {
    DDLogDebug(@"Entered foreground!");
    
    [self updateData];
}

- (void)updateData {
    CAAPI *api = [CAAPI sharedAPI];
    if (!api.lastUpdatedAt || [[NSDate date] timeIntervalSince1970] - [api.lastUpdatedAt timeIntervalSince1970] > 120) {
        DDLogDebug(@"Updating data");
        [self.activityIndicator startAnimating];
        [api checkStatusWithCompletion:^(CACafeStatus status, NSError *error) {
            self.currentStatus = status;
            
            [self.activityIndicator stopAnimating];
            if (_rotatingTimer) {
                [_rotatingTimer invalidate];
            }
            
            [self updateWithCurrentStatus];
        }];
    }
}

- (UIImage *)randomImageForStatus:(CACafeStatus)status {
    NSString *imageName = (status == CACafeStatusOpen) ? @"open" : @"closed";
    srand(time(0));
    int randomNumber =  rand() % 3 + 1;
    
    NSString *randomImage = [NSString stringWithFormat:@"%@%i",imageName, randomNumber];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:randomImage withExtension:@"gif"];
    return [UIImage ca_imageWithAnimatedGIFURL:url];
}

- (void)updateWithCurrentStatus {
    NSString *status = (self.currentStatus == CACafeStatusOpen) ? @"Open" : @"Closed";
    UIImage *randomImage = [self randomImageForStatus:self.currentStatus];
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.imageView setAlpha:0];
        [self.statusLabel setAlpha:0];
    } completion:^(BOOL finished) {
        [self.imageView setImage:randomImage];
        [self.statusLabel setText:status];
        
        _rotatingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                          target:self
                                                        selector:@selector(updateWithCurrentStatus)
                                                        userInfo:nil
                                                         repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_rotatingTimer forMode:NSDefaultRunLoopMode];
        
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
