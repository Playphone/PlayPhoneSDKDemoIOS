//
//  MNMyHiScoresProvider.h
//  MultiNet client
//
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"

#define MN_HS_PERIOD_MASK_ALLTIME (0x00000001)
#define MN_HS_PERIOD_MASK_MONTH   (0x00000002)
#define MN_HS_PERIOD_MASK_WEEK    (0x00000004)

/**
 * @brief "MyHiScores" delegate protocol.
 *
 * By implementing methods of MNMyHiScoresProviderDelegate protocol, the delegate can respond to high
 * score updates.
 */
@protocol MNMyHiScoresProviderDelegate<NSObject>
@optional

/**
 * This message is sent when player's high score information has been updated.
 * @param newScore updated score
 * @param gameSetId game settings id
 * @param periodMask bit mask which describes what kind of high scores has been updated, it is a
 *  combination of MN_HS_PERIOD_MASK_ALLTIME, MN_HS_PERIOD_MASK_MONTH and MN_HS_PERIOD_MASK_WEEK
 *  constants
 */
-(void) hiScoreUpdated:(long long) newScore gameSetId:(NSInteger) gameSetId periodMask:(unsigned int) periodMask;
@end


/**
 * @brief "MyHiScores" MultiNet provider.
 *
 * "MyHiScores" provider provides access to player's high scores information and allows application
 * to be notified when high scores updates occur.
 */
@interface MNMyHiScoresProvider : NSObject<MNSessionDelegate> {
    @private

    MNSession*                     _session;
    MNDelegateArray*               _delegates;
    NSMutableDictionary*           _scores;
}

/**
 * Initializes and return newly allocated MNMyHiScoresProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession:(MNSession*) session;

/**
 * Returns player's high score for given game settings id
 * @param gameSetId game settings id for which high score must be returned
 * @return player's high score or nil if high score for given gameSetId does not exists
 */
-(NSNumber*) getMyHiScore:(NSInteger) gameSetId;

/**
 * Returns player's high scores for all game settings id
 * @return dictionary with NSNumber keys (game settings id) and NSNumber values (high scores),
 */
-(NSDictionary*) getMyHiScores;

/**
 * Adds delegate
 * @param delegate an object conforming to MNMyHiScoresProviderDelegate protocol
 */
-(void) addDelegate:(id<MNMyHiScoresProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNMyHiScoresProviderDelegate>) delegate;
@end
