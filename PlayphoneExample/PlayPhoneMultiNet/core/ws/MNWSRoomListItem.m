//
//  MNWSRoomListItem.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSRoomListItem.h"

@implementation MNWSRoomListItem

-(NSNumber*) getRoomSFId {
    return [self getIntegerValue :@"room_sfid"];
}

-(NSString*) getRoomName {
    return [self getValueByName :@"room_name"];
}

-(NSNumber*) getRoomUserCount {
    return [self getIntegerValue :@"room_user_count"];
}

-(NSNumber*) getRoomIsLobby {
    return [self getBooleanValue :@"room_is_lobby"];
}

-(NSNumber*) getGameId {
    return [self getIntegerValue :@"game_id"];
}

-(NSNumber*) getGameSetId {
    return [self getIntegerValue :@"gameset_id"];
}


@end

