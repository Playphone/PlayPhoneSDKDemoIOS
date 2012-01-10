//
//  MNSessionInternal.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 2/9/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <sys/time.h>
#import <time.h>

#import "MNTrackingSystem.h"
#import "MNSmartFoxFacade.h"
#import "MNDelegateArray.h"
#import "MNSession.h"
#import "MNSessionInternal.h"

@implementation MNSession(internal)

-(time_t) getLaunchTime {
    return _launchTime;
}

-(NSString*) getLaunchId {
    return _launchId;
}

-(MNTrackingSystem*) getTrackingSystem {
    if (_trackingSystem == nil) {
        _trackingSystem = [[MNTrackingSystem alloc] initWithSession: self];
    }

    return _trackingSystem;
}

-(NSDictionary*)     getTrackingVars {
    MNTrackingSystem* trackingSystem = [self getTrackingSystem];

    return [trackingSystem getTrackingVars];
}

-(NSDictionary*)     getAppConfigVars {
    return nil; //there is no app config vars yet
}

-(NSDictionary*) getAppExtParams {
    return _appExtParams;
}

-(unsigned int) getForegroundSwitchCount {
    return _foregroundSwitchCount;
}

-(time_t) getForegroundTime {
    time_t result = _foregroundAccumulatedTime;

    if (_inForeground) {
        result += time(NULL) - _foregroundLastStartTime;
    }

    return result;
}

-(MNConfigData*)     getConfigData {
    return smartFoxFacade->configData;
}

-(void) setWebShopReady:(BOOL) isReady {
    _webShopIsReady = isReady;

    MN_DELEGATE_ARRAY_CALL_ARG1(MNSessionDelegate,_delegates,mnSessionVShopReadyStatusChanged,isReady);
}

-(BOOL) isWebShopReady {
    return _webShopIsReady;
}

@end
