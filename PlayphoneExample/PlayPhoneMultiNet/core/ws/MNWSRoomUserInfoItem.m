//
//  MNWSRoomUserInfoItem.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSRoomUserInfoItem.h"

@implementation MNWSRoomUserInfoItem

-(NSNumber*) getRoomSFId {
    return [self getIntegerValue :@"room_sfid"];
}

-(NSNumber*) getUserId {
    return [self getLongLongValue :@"user_id"];
}

-(NSString*) getUserNickName {
    return [self getValueByName :@"user_nick_name"];
}

-(NSNumber*) getUserAvatarExists {
    return [self getBooleanValue :@"user_avatar_exists"];
}

-(NSString*) getUserAvatarUrl {
    return [self getValueByName :@"user_avatar_url"];
}

-(NSNumber*) getUserOnlineNow {
    return [self getBooleanValue :@"user_online_now"];
}


@end

