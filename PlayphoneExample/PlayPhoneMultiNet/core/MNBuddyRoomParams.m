//
//  MNBuddyRoomParams.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/1/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNGameParams.h"
#import "MNBuddyRoomParams.h"

@implementation MNBuddyRoomParams

@synthesize roomName = _roomName;
@synthesize gameSetId = _gameSetId;
@synthesize toUserIdList = _toUserIdList;
@synthesize toUserSFIdList = _toUserSFIdList;
@synthesize inviteText = _inviteText;

-(id) init {
    self = [super init];

    if (self != nil) {
        _gameSetId = MN_GAMESET_ID_DEFAULT;
    }

    return self;
}

-(void) dealloc {
    [_roomName release];
    [_toUserIdList release];
    [_toUserSFIdList release];
    [_inviteText release];

    [super dealloc];
}

@end

