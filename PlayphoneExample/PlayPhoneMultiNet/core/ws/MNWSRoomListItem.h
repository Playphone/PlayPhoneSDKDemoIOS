//
//  MNWSRoomListItem.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSRoomListItem : MNWSGenericItem {
}

-(NSNumber*) getRoomSFId;
-(NSString*) getRoomName;
-(NSNumber*) getRoomUserCount;
-(NSNumber*) getRoomIsLobby;
-(NSNumber*) getGameId;
-(NSNumber*) getGameSetId;

@end

