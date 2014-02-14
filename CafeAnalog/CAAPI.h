//
//  CAAPI.h
//  CafeAnalog
//
//  Created by Kristian Andersen on 14/02/14.
//  Copyright (c) 2014 Kristian Andersen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CACafeStatus) {
    CACafeStatusOpen,
    CACafeStatusClosed
};

@interface CAAPI : NSObject

@property (nonatomic, readonly) NSDate *lastUpdatedAt;

+ (CAAPI *)sharedAPI;
- (void)checkStatusWithCompletion:(void (^)(CACafeStatus status, NSError *error))completion;

@end
