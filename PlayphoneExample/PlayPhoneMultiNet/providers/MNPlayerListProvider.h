//
//  MNPlayerListProvider.h
//  MultiNet client
//
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"

/**
 * @brief "PlayerList" delegate protocol.
 *
 * By implementing methods of MNPlayerListProviderDelegate protocol, the delegate can respond to
 * the changes of player states.
 */
@protocol MNPlayerListProviderDelegate<NSObject>

/**
 * This message is sent when new player joined the game.
 * @param player player information
 */
-(void) onPlayerJoin:(MNUserInfo*) player;

/**
 * This message is sent when player left the game.
 * @param player player information
 */
-(void) onPlayerLeft:(MNUserInfo*) player;
@end

/**
 * @brief "PlayerList" MultiNet provider.
 *
 * "PlayerList" provider provides information on players state in game room and notifies delegate on states changes.
 */
@interface MNPlayerListProvider : NSObject<MNSessionDelegate> {
    @private

    MNSession*           _session;
    MNDelegateArray*     _delegates;
    NSMutableDictionary* _playerStatuses;
}

/**
 * Initializes and return newly allocated MNPlayerListProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session;

/**
 * Returns list of players in current game room
 * @return array of players. Elements of array are MNUserInfo objects.
 */
-(NSArray*) getPlayerList;

/**
 * Adds delegate
 * @param delegate an object conforming to MNPlayerListProviderDelegate protocol
 */
-(void) addDelegate:(id<MNPlayerListProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNPlayerListProviderDelegate>) delegate;
@end
