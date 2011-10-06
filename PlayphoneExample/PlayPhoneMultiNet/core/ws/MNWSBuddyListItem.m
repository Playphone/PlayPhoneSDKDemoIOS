//
//  MNWSBuddyListItem.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSBuddyListItem.h"

@implementation MNWSBuddyListItem

-(NSNumber*) getFriendUserId {
    return [self getLongLongValue :@"friend_user_id"];
}

-(NSString*) getFriendUserNickName {
    return [self getValueByName :@"friend_user_nick_name"];
}

-(NSString*) getFriendSnIdList {
    return [self getValueByName :@"friend_sn_id_list"];
}

-(NSString*) getFriendSnUserAsnIdList {
    return [self getValueByName :@"friend_sn_user_asnid_list"];
}

-(NSNumber*) getFriendInGameId {
    return [self getIntegerValue :@"friend_in_game_id"];
}

-(NSString*) getFriendInGameName {
    return [self getValueByName :@"friend_in_game_name"];
}

-(NSString*) getFriendInGameIconUrl {
    return [self getValueByName :@"friend_in_game_icon_url"];
}

-(NSNumber*) getFriendHasCurrentGame {
    return [self getBooleanValue :@"friend_has_current_game"];
}

-(NSString*) getFriendUserLocale {
    return [self getValueByName :@"friend_user_locale"];
}

-(NSString*) getFriendUserAvatarUrl {
    return [self getValueByName :@"friend_user_avatar_url"];
}

-(NSNumber*) getFriendUserOnlineNow {
    return [self getBooleanValue :@"friend_user_online_now"];
}

-(NSNumber*) getFriendUserSfid {
    return [self getIntegerValue :@"friend_user_sfid"];
}

-(NSNumber*) getFriendSnId {
    return [self getIntegerValue :@"friend_sn_id"];
}

-(NSNumber*) getFriendSnUserAsnId {
    return [self getLongLongValue :@"friend_sn_user_asnid"];
}

-(NSNumber*) getFriendFlags {
    return [self getUnsignedIntegerValue :@"friend_flags"];
}

-(NSNumber*) getFriendIsIgnored {
    return [self getBooleanValue :@"friend_is_ignored"];
}

-(NSNumber*) getFriendInRoomSfid {
    return [self getIntegerValue :@"friend_in_room_sfid"];
}

-(NSNumber*) getFriendInRoomIsLobby {
    return [self getBooleanValue :@"friend_in_room_is_lobby"];
}

-(NSString*) getFriendCurrGameAchievementsList {
    return [self getValueByName :@"friend_curr_game_achievemenets_list"];
}


@end

