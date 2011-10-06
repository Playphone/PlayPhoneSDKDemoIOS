//
//  MNWSCurrentUserInfo.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSCurrentUserInfo : MNWSGenericItem {
}

-(NSNumber*) getUserId;
-(NSString*) getUserNickName;
-(NSNumber*) getUserAvatarExists;
-(NSString*) getUserAvatarUrl;
-(NSNumber*) getUserOnlineNow;
-(NSString*) getUserEmail;
-(NSNumber*) getUserStatus;
-(NSNumber*) getUserAvatarHasCustomImg;
-(NSNumber*) getUserAvatarHasExternalUrl;
-(NSNumber*) getUserGamePoints;

@end

