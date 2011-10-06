//
//  MNClientRobotsProvider.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 3/23/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"

/**
 * @brief "Client-side robots" MultiNet provider.
 *
 * "Client-side robots" provider provides information on client-side robots
 * and allows to post robot scores.
 */
@interface MNClientRobotsProvider : NSObject<MNSessionDelegate> {
    @private

    MNSession*    _session;
    NSMutableSet* _robots;
}

/**
 * Initializes and return newly allocated MNClientRobotsProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session;

/**
 * Check if passed user information belongs to client-side robot
 * @param userInfo user information
 * @return YES if player identified by userInfo parameter is client-side robot and NO - otherwise.
 */
-(BOOL) isRobot:(MNUserInfo*) userInfo;

/**
 * Send client-side robot's score to MultiNet server
 * @param userInfo robot information
 * @param score game score
 */
-(void) postRobot:(MNUserInfo*) userInfo score:(long long) score;

@end
