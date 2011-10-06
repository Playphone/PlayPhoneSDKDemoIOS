//
//  MNJoinRoomInvitationParams.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/1/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Room invitation parameters object
 */
@interface MNJoinRoomInvitationParams : NSObject {
    NSInteger _fromUserSFId;
    NSString* _fromUserName;
    NSInteger _roomSFId;
    NSString* _roomName;
    NSInteger _roomGameId;
    NSInteger _roomGameSetId;
    NSString* _inviteText;
}

/**
 * Invitation sender SmartFox user id
 */
@property (nonatomic,assign) NSInteger fromUserSFId;
/**
 * Invitation sender name
 */
@property (nonatomic,retain) NSString* fromUserName;
/**
 * SmartFox room id
 */
@property (nonatomic,assign) NSInteger roomSFId;
/**
 * Room name
 */
@property (nonatomic,retain) NSString* roomName;
/**
 * Game id
 */
@property (nonatomic,assign) NSInteger roomGameId;
/**
 * Gameset id
 */
@property (nonatomic,assign) NSInteger roomGameSetId;
/**
 * Invitation text
 */
@property (nonatomic,retain) NSString* inviteText;

/**
 * Initializes and returns newly allocated object.
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) init;

/**
 * Release all acquired resources
 */
-(void) dealloc;

@end
