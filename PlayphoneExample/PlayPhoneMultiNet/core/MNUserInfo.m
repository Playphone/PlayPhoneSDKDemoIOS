//
//  MNUserInfo.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/23/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNUserInfo.h"

#define MN_AVATAR_URL_SUFFIX_FORMAT @"user_image_data.php?sn_id=0&user_id=%llu"

@implementation MNUserInfo

@synthesize userId = _userId;
@synthesize userSFId = _userSFId;
@synthesize userName = _userName;

-(id) initWithUserId:(MNUserId) userId userSFId:(NSInteger) userSFId userName:(NSString*) userName webBaseUrl:(NSString*) webBaseUrl{
    self = [super init];

    if (self != nil) {
        self.userId = userId;
        self.userSFId = userSFId;
        self.userName = userName;

        _webBaseUrl = [webBaseUrl retain];
    }

    return self;
}

-(void) dealloc {
    [_webBaseUrl release];
    [_userName release];

    [super dealloc];
}

-(NSString*) getAvatarUrl {
    if (_webBaseUrl == nil) {
        return nil;
    }

    return [NSString stringWithFormat: @"%@/" MN_AVATAR_URL_SUFFIX_FORMAT,_webBaseUrl,self.userId];
}

@end
