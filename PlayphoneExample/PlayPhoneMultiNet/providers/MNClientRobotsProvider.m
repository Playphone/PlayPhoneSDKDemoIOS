//
//  MNClientRobotsProvider.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 3/23/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNTools.h"

#import "MNClientRobotsProvider.h"

static NSString* MNClientRobotsProviderPluginName = @"com.playphone.mn.robotscore";

/* NOTE: message prefix length constant must be consistent with prefix value */
static NSString* MNClientRobotsProviderIRobotMessagePrefix = @"irobot:";
#define MNClientRobotsProviderIRobotMessagePrefixLength (7)

static BOOL isPlayerInGameRoomByStatus (NSUInteger status) {
    return status == MN_IN_GAME_WAIT || status == MN_IN_GAME_START ||
           status == MN_IN_GAME_PLAY || status == MN_IN_GAME_END;
}

@interface MNClientRobotsProvider()
/* MNSessionDelegate protocol */
-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus;
-(void) mnSessionRoomUserLeave:(MNUserInfo*) userInfo;
-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender;
@end

@implementation MNClientRobotsProvider

-(id) initWithSession: (MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session = session;
        _robots  = [[NSMutableSet alloc] init];

        [_session addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [_session removeDelegate: self];

    [_robots release];

    [super dealloc];
}

-(BOOL) isRobot:(MNUserInfo*) userInfo {
    return [_robots member: [NSNumber numberWithInteger: userInfo.userSFId]] != nil;
}

-(void) postRobot:(MNUserInfo*) userInfo score:(long long) score {
    [_session sendPlugin: MNClientRobotsProviderPluginName
              message: [NSString stringWithFormat: @"robotScore:%d:%lld", userInfo.userSFId, score]];
}

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (![pluginName isEqualToString: MNClientRobotsProviderPluginName]) {
        return;
    }

    if (![message hasPrefix: MNClientRobotsProviderIRobotMessagePrefix]) {
        return;
    }

    NSInteger userSFId;

    NSString* dataStr    = [message substringFromIndex: MNClientRobotsProviderIRobotMessagePrefixLength];
    NSRange   colonRange = [dataStr rangeOfString: @":"];

    if (colonRange.location != NSNotFound) {
        dataStr = [dataStr substringToIndex: colonRange.location];
    }

    if (!MNStringScanInteger(&userSFId,dataStr)) {
        return;
    }

    [_robots addObject: [NSNumber numberWithInteger: userSFId]];
}

-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus {
    if (!isPlayerInGameRoomByStatus(newStatus)) {
        [_robots removeAllObjects];
    }
}

-(void) mnSessionRoomUserLeave:(MNUserInfo*) userInfo {
    [_robots removeObject: [NSNumber numberWithInteger: userInfo.userSFId]];
}

@end
