//
//  MNWSLeaderboardListItem.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSLeaderboardListItem.h"

@implementation MNWSLeaderboardListItem

-(NSNumber*) getUserId {
    return [self getLongLongValue :@"user_id"];
}

-(NSString*) getUserNickName {
    return [self getValueByName :@"user_nick_name"];
}

-(NSString*) getUserAvatarUrl {
    return [self getValueByName :@"user_avatar_url"];
}

-(NSNumber*) getUserIsFriend {
    return [self getBooleanValue :@"user_is_friend"];
}

-(NSNumber*) getUserOnlineNow {
    return [self getBooleanValue :@"user_online_now"];
}

-(NSNumber*) getUserSfid {
    return [self getIntegerValue :@"user_sfid"];
}

-(NSNumber*) getUserIsIgnored {
    return [self getBooleanValue :@"user_is_ignored"];
}

-(NSString*) getUserLocale {
    return [self getValueByName :@"user_locale"];
}

-(NSNumber*) getOutHiScore {
    return [self getLongLongValue :@"out_hi_score"];
}

-(NSString*) getOutHiScoreText {
    return [self getValueByName :@"out_hi_score_text"];
}

-(NSNumber*) getOutHiDateTime {
    return [self getLongLongValue :@"out_hi_datetime"];
}

-(NSNumber*) getOutHiDateTimeDiff {
    return [self getLongLongValue :@"out_hi_datetime_diff"];
}

-(NSNumber*) getOutUserPlace {
    return [self getLongLongValue :@"out_user_place"];
}

-(NSNumber*) getGameId {
    return [self getIntegerValue :@"game_id"];
}

-(NSNumber*) getGamesetId {
    return [self getIntegerValue :@"gameset_id"];
}

-(NSString*) getUserAchievementsList {
    return [self getValueByName :@"user_achievemenets_list"];
}


@end

