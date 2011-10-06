//
//  MNWSBuddyListItem.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSBuddyListItem : MNWSGenericItem {
}

-(NSNumber*) getFriendUserId;
-(NSString*) getFriendUserNickName;
-(NSString*) getFriendSnIdList;
-(NSString*) getFriendSnUserAsnIdList;
-(NSNumber*) getFriendInGameId;
-(NSString*) getFriendInGameName;
-(NSString*) getFriendInGameIconUrl;
-(NSNumber*) getFriendHasCurrentGame;
-(NSString*) getFriendUserLocale;
-(NSString*) getFriendUserAvatarUrl;
-(NSNumber*) getFriendUserOnlineNow;
-(NSNumber*) getFriendUserSfid;
-(NSNumber*) getFriendSnId;
-(NSNumber*) getFriendSnUserAsnId;
-(NSNumber*) getFriendFlags;
-(NSNumber*) getFriendIsIgnored;
-(NSNumber*) getFriendInRoomSfid;
-(NSNumber*) getFriendInRoomIsLobby;
-(NSString*) getFriendCurrGameAchievementsList;

@end

