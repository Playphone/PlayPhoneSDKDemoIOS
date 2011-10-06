//
//  MNWSAnyUserItem.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSAnyUserItem.h"

@implementation MNWSAnyUserItem

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

-(NSNumber*) getUserGamePoints {
    return [self getLongLongValue :@"user_gamepoints"];
}

-(NSNumber*) getMyFriendLinkStatus {
    return [self getIntegerValue :@"my_friend_link_status"];
}


@end

