//
//  MNNetworkStatus.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/3/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <arpa/inet.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#import "MNNetworkStatus.h"

#define FLAG_IS_SET(value,flag) (((value) & (flag)) != 0)
#define FLAG_NOT_SET(value,flag) (((value) & (flag)) == 0)

static SCNetworkReachabilityRef createNetworkReachabilityRef (void) {
    struct sockaddr_in defaultRouteAddr;

    memset(&defaultRouteAddr,0,sizeof(defaultRouteAddr));

    defaultRouteAddr.sin_len = sizeof(defaultRouteAddr);
    defaultRouteAddr.sin_family = AF_INET;

    return SCNetworkReachabilityCreateWithAddress(NULL,(struct sockaddr*)&defaultRouteAddr);
}

static BOOL MNNetworkHaveInternetConnectionByFlags (SCNetworkReachabilityFlags flags) {
    return FLAG_IS_SET(flags,kSCNetworkReachabilityFlagsReachable) &&
           (FLAG_NOT_SET(flags,kSCNetworkReachabilityFlagsConnectionRequired) ||
            FLAG_IS_SET(flags,kSCNetworkReachabilityFlagsIsWWAN)) &&
           FLAG_NOT_SET(flags,kSCNetworkReachabilityFlagsIsDirect);
}

static void MNNetworkStatusCallback (SCNetworkReachabilityRef target,
                                     SCNetworkReachabilityFlags flags,
                                     void* info) {
    MNNetworkStatus* networkStatus = (MNNetworkStatus*)info;

    if (networkStatus.delegate != nil) {
        if (MNNetworkHaveInternetConnectionByFlags(flags)) {
            if ([networkStatus.delegate respondsToSelector:@selector(networkDidBecomeAvailable)]) {
                [networkStatus.delegate networkDidBecomeAvailable];
            }
        }
        else {
            if ([networkStatus.delegate respondsToSelector:@selector(networkDidBecomeUnavailable)]) {
                [networkStatus.delegate networkDidBecomeUnavailable];
            }
        }
    }
}

@implementation MNNetworkStatus

@synthesize delegate;

/* ask for reachability of "0.0.0.0" address (default route) */
+(BOOL) haveInternetConnection {
    BOOL result = NO;

    SCNetworkReachabilityRef networkReachability = createNetworkReachabilityRef();

    if (networkReachability != NULL) {
        SCNetworkReachabilityFlags reachabilityFlags;

        if (SCNetworkReachabilityGetFlags(networkReachability,&reachabilityFlags)) {
            result = MNNetworkHaveInternetConnectionByFlags(reachabilityFlags);
        }

        CFRelease(networkReachability);
    }
    else {
        NSLog(@"error: Network reachability query failed: %s",SCErrorString(SCError()));
    }

    return result;
}

-(id) init {
    self = [super init];

    if (self != nil) {
        monitoringEnabled = NO;
    }

    return self;
}

-(void) dealloc {
    if (monitoringEnabled) {
        [self stopMonitoring];
    }

    CFRelease(reachability);

    [super dealloc];
}

-(void) startMonitoring {
    if (monitoringEnabled) {
        return;
    }

    SCNetworkReachabilityContext context = { 0, self, NULL, NULL, NULL };

    if (reachability != nil) {
        CFRelease(reachability);
    }

    reachability = createNetworkReachabilityRef();

    if (reachability != nil) {
        runLoop = CFRunLoopGetCurrent();

        SCNetworkReachabilitySetCallback(reachability,MNNetworkStatusCallback,&context);
        SCNetworkReachabilityScheduleWithRunLoop(reachability,runLoop,kCFRunLoopDefaultMode);

        monitoringEnabled = YES;
    }
}

-(void) stopMonitoring {
    if (monitoringEnabled) {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachability,runLoop,kCFRunLoopDefaultMode);

        CFRelease(reachability);
        reachability = nil;

        monitoringEnabled = NO;
    }
}

@end
