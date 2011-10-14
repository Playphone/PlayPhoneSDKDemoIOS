//
//  MNVGameSettingsProvider.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNGameVocabulary.h"

/**
 * @brief "MNGameSettings" delegate protocol.
 *
 * By implementing methods of MNGameSettingsProviderDelegate protocol, the delegate can respond to
 * events related to game settings information.
 */
@protocol MNGameSettingsProviderDelegate<NSObject>

@optional

/**
 * This message is sent when the game settings information has been updated as a result of MNGamesettingsProvider's
 * doGameSettingListUpdate call.
 */
-(void) onGameSettingListUpdated;

@end


/**
 * @brief Game settings information object
 */
@interface MNGameSettingInfo : NSObject {
@private

    int        _id;
    NSString*  _name;
    NSString*  _params;
    NSString*  _sysParams;
    BOOL       _multiplayerEnabled;
    BOOL       _leaderboardVisible;
}

/**
 * Game setting identifier - unique identifier of game setting.
 */
@property (nonatomic,assign) int        gameSetId;

/**
 * Name of game setting.
 */
@property (nonatomic,retain) NSString*  name;

/**
 * Game setting parameters.
 */
@property (nonatomic,retain) NSString*  params;

/**
 * Game setting system parameters.
 */
@property (nonatomic,retain) NSString*  sysParams;

/**
 * Flag which shows if multiplayer is enabled.
 */
@property (nonatomic,assign) BOOL       isMultiplayerEnabled;

/**
 * Flag which shows if leaderboard is visible.
 */
@property (nonatomic,assign) BOOL       isLeaderboardVisible;

/**
 * Initializes and return newly allocated object with game setting data.
 * @param gameSetId game setting identifier
 * @param name game setting name
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) gameSetId andName:(NSString*) name;

@end


/**
 * @brief "Game settings" MultiNet provider.
 *
 * "Game settings" provider provides information on available game settings.
 */
@interface MNGameSettingsProvider : NSObject<MNGameVocabularyDelegate> {
@private
    
    MNSession*                       _session;
    MNDelegateArray*                 _delegates;
}

/**
 * Initializes and return newly allocated MNGameSettingsProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session;

/**
 * Returns list of all available game settings.
 * @return array of game settings. Elements of array are MNGameSettingInfo objects.
 */
-(NSArray*) getGameSettingList;

/**
 * Returns game setting information by game setting id.
 * @return game setting information or nil if there is no such game setting.
 */
-(MNGameSettingInfo*) findGameSettingById:(int) gameSetId;

/**
 * Returns state of game settings list.
 * @return YES if newer game settings list is available on server, NO - otherwise.
 */
-(BOOL) isGameSettingListNeedUpdate;

/**
 * Starts game settings information update. On successfull completion delegate's onGameSettingListUpdated method
 * will be called.
 */
-(void) doGameSettingListUpdate;

/**
 * Adds delegate
 * @param delegate an object conforming to MNAchievementsProviderDelegate protocol
 */
-(void) addDelegate:(id<MNGameSettingsProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNGameSettingsProviderDelegate>) delegate;

@end
