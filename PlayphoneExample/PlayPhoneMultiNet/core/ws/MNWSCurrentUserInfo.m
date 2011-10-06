//
//  MNWSCurrentUserInfo.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSCurrentUserInfo.h"

@implementation MNWSCurrentUserInfo

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

-(NSString*) getUserEmail {
    return [self getValueByName :@"user_email"];
}

-(NSNumber*) getUserStatus {
    return [self getIntegerValue :@"user_status"];
}

-(NSNumber*) getUserAvatarHasCustomImg {
    return [self getBooleanValue :@"user_avatar_has_custom_img"];
}

-(NSNumber*) getUserAvatarHasExternalUrl {
    return [self getBooleanValue :@"user_avatar_has_external_url"];
}

-(NSNumber*) getUserGamePoints {
    return [self getIntegerValue :@"user_gamepoints"];
}


@end

