//
//  MNWSAnyUserItem.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSAnyUserItem : MNWSGenericItem {
}

-(NSNumber*) getUserId;
-(NSString*) getUserNickName;
-(NSNumber*) getUserAvatarExists;
-(NSString*) getUserAvatarUrl;
-(NSNumber*) getUserOnlineNow;
-(NSNumber*) getUserGamePoints;
-(NSNumber*) getMyFriendLinkStatus;

@end

