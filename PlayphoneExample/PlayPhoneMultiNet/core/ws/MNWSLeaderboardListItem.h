//
//  MNWSLeaderboardListItem.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSLeaderboardListItem : MNWSGenericItem {
}

-(NSNumber*) getUserId;
-(NSString*) getUserNickName;
-(NSString*) getUserAvatarUrl;
-(NSNumber*) getUserIsFriend;
-(NSNumber*) getUserOnlineNow;
-(NSNumber*) getUserSfid;
-(NSNumber*) getUserIsIgnored;
-(NSString*) getUserLocale;
-(NSNumber*) getOutHiScore;
-(NSString*) getOutHiScoreText;
-(NSNumber*) getOutHiDateTime;
-(NSNumber*) getOutHiDateTimeDiff;
-(NSNumber*) getOutUserPlace;
-(NSNumber*) getGameId;
-(NSNumber*) getGamesetId;
-(NSString*) getUserAchievementsList;

@end

