//
//  CAAppDelegate.m
//  CafeAnalog
//
//  Created by Kristian Andersen on 13/02/14.
//  Copyright (c) 2014 Kristian Andersen. All rights reserved.
//

#import "CAAppDelegate.h"

#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>

@implementation CAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupLogging];
    return YES;
}

- (void)setupLogging {
    // Setup logging into XCode's console
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // Setup logging AFNetworking requests
    AFNetworkActivityLogger *networkLogger = [AFNetworkActivityLogger sharedLogger];
    [networkLogger setLevel:AFLoggerLevelInfo];
    [networkLogger startLogging];

    // Setup logging to rolling log files
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setRollingFrequency:60 * 60 * 24]; // Roll logs every day
    [fileLogger setMaximumFileSize:1024 * 1024 * 2]; // max 2 mb
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:7]; // Keep 7 days only
    [DDLog addLogger:fileLogger];
}

@end
