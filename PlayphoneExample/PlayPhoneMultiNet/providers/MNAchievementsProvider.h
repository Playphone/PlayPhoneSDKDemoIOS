//
//  MNAchievementsProvider.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 4/7/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNGameVocabulary.h"

/**
 * @brief "Achievements" delegate protocol.
 *
 * By implementing methods of MNAchievementsProviderDelegate protocol, the delegate can respond to
 * events related to achievements.
 */
@protocol MNAchievementsProviderDelegate<NSObject>

@optional

/**
 * This message is sent when the list of game achievements has been updated as a result of MNAchievementProvider's
 * doGameAchievementListUpdate call.
 */
-(void) onGameAchievementListUpdated;

/**
 * This message is sent when server unlocks achievement for player.
 */
-(void) onPlayerAchievementUnlocked:(int) achievementId;

@end

/**
 * @brief Game achievement information object
 */
@interface MNGameAchievementInfo : NSObject {
@private

    int        _id;
    NSString*  _name;
    NSUInteger _flags;
    NSString*  _description;
    NSString*  _params;
    int        _points;
}

/**
 * Achievement identifier - unique identifier of game achievement.
 */
@property (nonatomic,assign) int        achievementId;

/**
 * Name of achievement.
 */
@property (nonatomic,retain) NSString*  name;

/**
 * Achievement flags.
 */
@property (nonatomic,assign) NSUInteger flags;

/**
 * Achievement description.
 */
@property (nonatomic,retain) NSString*  description;

/**
 * Achievement parameters.
 */
@property (nonatomic,retain) NSString*  params;

/**
 * Achievement points.
 */
@property (nonatomic,assign) int        points;

/**
 * Initializes and return newly allocated object with game achievement data.
 * @param achievementId achievement identifier
 * @param name achievement name
 * @param flags achievement flags
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) achievementId name:(NSString*) name andFlags:(NSUInteger) flags;

@end


/**
 * @brief Player achievement information object
 */
@interface MNPlayerAchievementInfo : NSObject {
@private

    int        _id;
}

/**
 * Achievement identifier - unique identifier of game achievement.
 */
@property (nonatomic,assign) int        achievementId;

/**
 * Initializes and return newly allocated object with player achievement data.
 * @param achievementId achievement identifier
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) achievementId;

@end


/**
 * @brief "Achievements" MultiNet provider.
 *
 * "Achievements" provider provides game achievement support. It allows to get available game achievements
 * information, get information on achievements unlocked by player as well as unlock player achievements.
 */
@interface MNAchievementsProvider : NSObject<MNSessionDelegate,MNGameVocabularyDelegate> {
@private

    MNSession*                       _session;
    MNDelegateArray*                 _delegates;

    NSMutableArray*                  _unlockedAchievements;
}

/**
 * Initializes and return newly allocated MNAchievementsProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session;

/**
 * Returns list of all available game achivements.
 * @return array of game achievements. Elements of array are MNGameAchievementInfo objects.
 */
-(NSArray*) getGameAchievementList;

/**
 * Returns game achievement information by achievement id.
 * @return game achievement information or nil if there is no such achievement.
 */
-(MNGameAchievementInfo*) findGameAchievementById:(int) achievementId;

/**
 * Returns state of game achievements list.
 * @return YES if newer achievement list is available on server, NO - otherwise.
 */
-(BOOL) isGameAchievementListNeedUpdate;

/**
 * Starts game achievements info update. On successfull completion delegate's onGameAchievementListUpdated method
 * will be called.
 */
-(void) doGameAchievementListUpdate;

/**
 * Unlocks player achievement.
 * @param achievementId achievement identifier to unlock
 */
-(void) unlockPlayerAchievement:(int) achievementId;

/**
 * Returns list of unlocked achievements.
 * @return array of unlocked achievements. Elements of array are MNPlayerAchievementInfo objects.
 */
-(NSArray*) getPlayerAchievementList;

/**
 * Check if achievement had been unlocked by player.
 * @return YES if player unlocked achievement, NO - otherwise.
 */
-(BOOL) isPlayerAchievementUnlocked:(int) achievementId;

/**
 * Returns URL of achievement image
 * @return image URL
 */
-(NSURL*) getAchievementImageURL:(int) achievementId;

/**
 * Adds delegate
 * @param delegate an object conforming to MNAchievementsProviderDelegate protocol
 */
-(void) addDelegate:(id<MNAchievementsProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNAchievementsProviderDelegate>) delegate;
@end
