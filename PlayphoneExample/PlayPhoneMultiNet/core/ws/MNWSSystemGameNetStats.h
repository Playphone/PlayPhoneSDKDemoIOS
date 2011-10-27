//
//  MNWSSystemGameNetStats.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSSystemGameNetStats : MNWSGenericItem {
}

-(NSNumber*) getServTotalUsers;
-(NSNumber*) getServTotalGames;
-(NSNumber*) getServOnlineUsers;
-(NSNumber*) getServOnlineRooms;
-(NSNumber*) getServOnlineGames;
-(NSNumber*) getGameOnlineUsers;
-(NSNumber*) getGameOnlineRooms;

@end

