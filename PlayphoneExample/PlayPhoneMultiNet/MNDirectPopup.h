//
//  MNDirectPopup.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 27.09.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//
#import "MNSession.h"
#import "MNAchievementsProvider.h"
#import "MNMyHiScoresProvider.h"

typedef enum {
    MNDIRECTPOPUP_WELCOME              = 1 << 0,
    MNDIRECTPOPUP_ACHIEVEMENTS         = 1 << 1,
    MNDIRECTPOPUP_NEW_HI_SCORES        = 1 << 2,
    MNDIRECTPOPUP_WEB_EVENT            = 1 << 16
 } MNDIRECTPOPUP_ACTION; 

#define MNDIRECTPOPUP_ALL (MNDIRECTPOPUP_WELCOME | MNDIRECTPOPUP_ACHIEVEMENTS | MNDIRECTPOPUP_NEW_HI_SCORES | MNDIRECTPOPUP_WEB_EVENT)

@interface MNDirectPopup : NSObject <MNSessionDelegate,MNAchievementsProviderDelegate,MNMyHiScoresProviderDelegate> {
}

+(void) init:(MNDIRECTPOPUP_ACTION) actionsBitMask;

+(void) setActive:(BOOL) activeFlag;
+(BOOL) isActive; 

+(void) setFollowStatusBarOrientationEnabled:(BOOL) autorotationFlag;
+(BOOL) isFollowStatusBarOrientationEnabled;

+(void) adjustToOrientation:(UIInterfaceOrientation)autorotationFlag;

@end
