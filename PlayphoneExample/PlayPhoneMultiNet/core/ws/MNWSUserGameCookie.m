//
//  MNWSUserGameCookie.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSUserGameCookie.h"

@implementation MNWSUserGameCookie

-(NSNumber*) getUserId {
    return [self getLongLongValue :@"user_id"];
}

-(NSNumber*) getCookieKey {
    return [self getIntegerValue :@"cookie_key"];
}

-(NSString*) getCookieValue {
    return [self getValueByName :@"cookie_value"];
}


@end

