//
//  MNNetworkStatus.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/3/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@protocol MNNetworkStatusDelegate<NSObject>
@optional

-(void) networkDidBecomeAvailable;
-(void) networkDidBecomeUnavailable;

@end

@interface MNNetworkStatus : NSObject {
    @private

    id<MNNetworkStatusDelegate> delegate;

    BOOL monitoringEnabled;
    SCNetworkReachabilityRef reachability;
    CFRunLoopRef runLoop;
}

@property (nonatomic,assign) id<MNNetworkStatusDelegate> delegate;

+(BOOL) haveInternetConnection;

-(id) init;
-(void) dealloc;

-(void) startMonitoring;
-(void) stopMonitoring;

@end
