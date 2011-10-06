//
//  MNJoinRoomInvitationParams.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/1/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNCommon.h"

#import "MNJoinRoomInvitationParams.h"

@implementation MNJoinRoomInvitationParams

@synthesize fromUserSFId =_fromUserSFId;
@synthesize fromUserName = _fromUserName;
@synthesize roomSFId = _roomSFId;
@synthesize roomName = _roomName;
@synthesize roomGameId = _roomGameId;
@synthesize roomGameSetId = _roomGameSetId;
@synthesize inviteText = _inviteText;

-(id) init {
    self = [super init];

    if (self != nil) {
        _fromUserSFId = MNSmartFoxUserIdUndefined;
        _roomSFId = 0;
        _roomGameId = 0;
        _roomGameSetId = 0;
    }

    return self;
}

-(void) dealloc {
    [_fromUserName release];
    [_roomName release];
    [_inviteText release];

    [super dealloc];
}

@end

