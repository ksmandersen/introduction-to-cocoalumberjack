//
//  CAAPI.m
//  CafeAnalog
//
//  Created by Kristian Andersen on 14/02/14.
//  Copyright (c) 2014 Kristian Andersen. All rights reserved.
//

#import "CAAPI.h"

#import <AFNetworking/AFNetworking.h>

@interface CAAPI ()

@property (nonatomic, strong) NSDate *lastUpdatedAt;

@end

@implementation CAAPI

+ (CAAPI *)sharedAPI {
    static CAAPI *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CAAPI alloc] init];
    });
    
    return _instance;
}

- (void)checkStatusWithCompletion:(void (^)(CACafeStatus status, NSError *error))completion {
    NSString *urlString = @"http://cafeanalog.dk/";
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [requestManager GET:urlString
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    DDLogVerbose(@"Got response: %@", htmlString);
                    
                    CACafeStatus status = [[self class] statusForPageContent:htmlString];
                    self.lastUpdatedAt = [NSDate date];
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(status, nil);
                        });
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DDLogError(@"Error when fetching status: %@, %@", error, error.userInfo);
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(CACafeStatusClosed, error);
                        });
                    }
                }];
}

+ (CACafeStatus)statusForPageContent:(NSString *)content {
    BOOL open = ([content rangeOfString:@"We're Åpen!"].location != NSNotFound);
    return open ? CACafeStatusOpen : CACafeStatusClosed;
}

@end
