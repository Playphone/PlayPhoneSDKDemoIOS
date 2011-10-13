//
//  MNWSUserGameCookie.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSUserGameCookie : MNWSGenericItem {
}

-(NSNumber*) getUserId;
-(NSNumber*) getCookieKey;
-(NSString*) getCookieValue;

@end

