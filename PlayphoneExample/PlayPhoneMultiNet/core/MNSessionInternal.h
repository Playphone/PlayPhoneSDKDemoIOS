//
//  MNSessionInternal.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 2/9/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <time.h>

#import <Foundation/Foundation.h>

#import "MNSession.h"

@interface MNSession(internal)
-(time_t)            getLaunchTime;
-(NSString*)         getLaunchId;
-(MNTrackingSystem*) getTrackingSystem;
-(NSDictionary*)     getTrackingVars;
-(NSDictionary*)     getAppConfigVars;

-(unsigned int)      getForegroundSwitchCount;
-(time_t)            getForegroundTime;

-(MNConfigData*)     getConfigData;
@end
