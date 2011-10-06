//
//  MNWSAnyGameItem.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSAnyGameItem : MNWSGenericItem {
}

-(NSNumber*) getGameId;
-(NSString*) getGameName;
-(NSString*) getGameDesc;
-(NSNumber*) getGameGenreId;
-(NSNumber*) getGameFlags;
-(NSNumber*) getGameStatus;
-(NSNumber*) getGamePlayModel;
-(NSString*) getGameIconUrl;
-(NSNumber*) getDeveloperId;

@end

