//
//  MNGameRoomCookiesProvider.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"

/**
 * @brief "Game room cookies" delegate protocol.
 *
 * By implementing methods of MNGameRoomCookiesProviderDelegate protocol, the delegate can handle
 * game room cookies notifications.
 */
@protocol MNGameRoomCookiesProviderDelegate<NSObject>
@optional

/**
 * This message is sent when game room cookie has been successfully retrieved.
 * @param roomSFId game room SmartFox identifier
 * @param key cookie's key
 * @param cookie cookie's data
 */
-(void) gameRoomCookieForRoom:(NSInteger) roomSFId withKey:(NSInteger) key downloadSucceeded:(NSString*) cookie;

/**
 * This message is sent when game room cookie retrieval failed.
 * @param roomSFId game room SmartFox identifier
 * @param key cookie's key
 * @param error error message
 */
-(void) gameRoomCookieForRoom:(NSInteger) roomSFId withKey:(NSInteger) key downloadFailedWithError:(NSString*) error;
@end

/**
 * @brief "Game room cookies" MultiNet provider.
 *
 * "Game room cookies" provider provides ability to store and retrieve custom game information.
 */
@interface MNGameRoomCookiesProvider : NSObject<MNSessionDelegate> {
@private

	MNSession*                      _session;
	MNDelegateArray*                _delegates;
}

/**
 * Initializes and return newly allocated MNGameRoomCookiesProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession:(MNSession*) session;

/**
 * Starts game room cookie retrieval operation.
 * @param roomSFId game room SmartFox identifier
 * @param key key of cookie to retrieve
 */
-(void) downloadGameRoomCookieForRoom:(NSInteger) roomSFId withKey:(NSInteger) key;

/**
 * Store game room cookie for current room.
 * @param key key of cookie to be stored
 * @param cookie data to be stored
 */
-(void) setCurrentGameRoomCookieWithKey:(NSInteger) key andCookie:(NSString*) cookie;

/**
 * Returns game room cookie for current room.
 * @param key cookie's key
 * @return cookie's data or nil if such cookie does not exist
 */
-(NSString*) currentGameRoomCookieWithKey:(NSInteger) key;

/**
 * Adds delegate
 * @param delegate an object conforming to MNGameRoomCookiesProviderDelegate protocol
 */
-(void) addDelegate:(id<MNGameRoomCookiesProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNGameRoomCookiesProviderDelegate>) delegate;
@end
