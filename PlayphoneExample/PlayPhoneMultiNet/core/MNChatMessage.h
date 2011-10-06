//
//  MNChatMessage.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/25/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNUserInfo.h"

/**
 * @brief Chat message object.
 */
@interface MNChatMessage : NSObject {
    @private

    MNUserInfo* _sender;
    NSString* _message;
    BOOL _privateMessage;
}

/**
 * Message sender
 */
@property (nonatomic,retain) MNUserInfo* sender;

/**
 * Message text
 */
@property (nonatomic,retain) NSString* message;

/**
 * A boolean value that determines whether message is private
 */
@property (nonatomic,assign) BOOL privateMessage;

/**
 * Returns initialized MNChatMessage object with specified text, sender and privacy setting.
 * @param message message text
 * @param sender sender information
 * @param privateMessage boolean value that determines whether message is private
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) initWithParams:(NSString*) message sender:(MNUserInfo*) sender privateMessage:(BOOL) privateMessage;

/**
 * Returns initialized MNChatMessage object with specified text and sender describing private message.
 * @param message message text
 * @param sender sender information
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) initWithPrivateMessage:(NSString*) message sender:(MNUserInfo*) sender;

/**
 * Returns initialized MNChatMessage object with specified text and sender describing public message.
 * @param message message text
 * @param sender sender information
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) initWithPublicMessage:(NSString*) message sender:(MNUserInfo*) sender;

/**
 * Release all acquired resources
 */
-(void) dealloc;

@end
