//
//  MNUserInfo.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/23/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNCommon.h"

/**
 * @brief User info object
 */
@interface MNUserInfo : NSObject {
    MNUserId _userId;
    NSInteger _userSFId;
    NSString* _userName;
    NSString* _webBaseUrl;
}

/**
 * MultiNet user id. Set to MNUserIdUndefined if unknown or undefined.
 */
@property (nonatomic,assign) MNUserId userId;

/**
 * SmartFox user id. Set to MNSmartFoxUserIdUndefined if unknown or undefined.
 */
@property (nonatomic,assign) NSInteger userSFId;

/**
 * User name.
 */
@property (nonatomic,retain) NSString* userName;

/**
 * Initializes and return newly allocated object with MultiNet user id, SmartFox user id and user name.
 * @param userId MultiNet user id
 * @param userSFId smartFox user id
 * @param userName user name
 * @param webBaseUrl MultiNet web server url
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithUserId:(MNUserId) userId userSFId:(NSInteger) userSFId userName:(NSString*) userName webBaseUrl:(NSString*) webBaseUrl;

/**
 * Release all acquired resources.
 */
-(void) dealloc;

/**
 * Returns user's avatar URL
 * @return user's avatar URL
 */
-(NSString*) getAvatarUrl;

@end

