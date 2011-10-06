//
//  MNWSRoomUserInfoItem.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSRoomUserInfoItem : MNWSGenericItem {
}

-(NSNumber*) getRoomSFId;
-(NSNumber*) getUserId;
-(NSString*) getUserNickName;
-(NSNumber*) getUserAvatarExists;
-(NSString*) getUserAvatarUrl;
-(NSNumber*) getUserOnlineNow;

@end

