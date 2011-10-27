//
//  MNWSSystemGameNetStats.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSSystemGameNetStats.h"

@implementation MNWSSystemGameNetStats

-(NSNumber*) getServTotalUsers {
    return [self getLongLongValue :@"serv_total_users"];
}

-(NSNumber*) getServTotalGames {
    return [self getLongLongValue :@"serv_total_games"];
}

-(NSNumber*) getServOnlineUsers {
    return [self getLongLongValue :@"serv_online_users"];
}

-(NSNumber*) getServOnlineRooms {
    return [self getLongLongValue :@"serv_online_rooms"];
}

-(NSNumber*) getServOnlineGames {
    return [self getLongLongValue :@"serv_online_games"];
}

-(NSNumber*) getGameOnlineUsers {
    return [self getLongLongValue :@"game_online_users"];
}

-(NSNumber*) getGameOnlineRooms {
    return [self getLongLongValue :@"game_online_rooms"];
}


@end

