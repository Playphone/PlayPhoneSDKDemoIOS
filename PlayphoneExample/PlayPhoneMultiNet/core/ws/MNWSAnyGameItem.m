//
//  MNWSAnyGameItem.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSAnyGameItem.h"

@implementation MNWSAnyGameItem

-(NSNumber*) getGameId {
    return [self getIntegerValue :@"game_id"];
}

-(NSString*) getGameName {
    return [self getValueByName :@"game_name"];
}

-(NSString*) getGameDesc {
    return [self getValueByName :@"game_desc"];
}

-(NSNumber*) getGameGenreId {
    return [self getIntegerValue :@"gamegenre_id"];
}

-(NSNumber*) getGameFlags {
    return [self getUnsignedIntegerValue :@"game_flags"];
}

-(NSNumber*) getGameStatus {
    return [self getIntegerValue :@"game_status"];
}

-(NSNumber*) getGamePlayModel {
    return [self getIntegerValue :@"game_play_model"];
}

-(NSString*) getGameIconUrl {
    return [self getValueByName :@"game_icon_url"];
}

-(NSNumber*) getDeveloperId {
    return [self getLongLongValue :@"developer_id"];
}


@end

