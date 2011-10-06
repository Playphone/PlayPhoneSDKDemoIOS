//
//  MNScoreProgressProvider.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 12/16/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"

@class MNScoreProgressProviderStateSlice;
@class MNScoreProgressProviderSyncState;

/**
 * @brief "ScoreProgress" delegate protocol.
 *
 * By implementing methods of MNScoreProgressProviderDelegate protocol, the delegate can respond to
 * score updates.
 */
@protocol MNScoreProgressProviderDelegate<NSObject>

/**
 * This message is sent when new score information arrived.
 * @param scoreProgressItems array of MNScoreProgressProviderItem objects representing
 * current scores, sorted using comparison function passed to setScoreCompareFunc:withContext:
 * method of MNScoreProgressProvider.
 */
-(void) scoresUpdated: (NSArray*) scoreProgressItems;
@end

/**
 * @brief Player score information object
 */
@interface MNScoreProgressProviderItem : NSObject {
@private

MNUserInfo* _userInfo;
long long   _score;
int         _place;
}

/**
 * Player information.
 */
@property (nonatomic,retain) MNUserInfo* userInfo;

/**
 * Achieved score.
 */
@property (nonatomic,assign) long long   score;

/**
 * Taken place.
 */
@property (nonatomic,assign) int         place;

/**
 * Initializes and return newly allocated object with player information, achieved score and taken place.
 * @param userInfo player information
 * @param score achieved score
 * @param place taken place
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithUserInfo:(MNUserInfo*) userInfo score:(long long) score andPlace:(int) place;

@end

typedef NSInteger (*MNScoreProgressProviderScoreCompareFunc)
                    (MNScoreProgressProviderItem* score1,
                     MNScoreProgressProviderItem* score2,
                     void* context);

extern NSInteger MNScoreProgressProviderScoreCompareFuncMoreIsBetter
                    (MNScoreProgressProviderItem* score1,
                     MNScoreProgressProviderItem* score2,
                     void* context);

extern NSInteger MNScoreProgressProviderScoreCompareFuncLessIsBetter
                    (MNScoreProgressProviderItem* score1,
                     MNScoreProgressProviderItem* score2,
                     void* context);

typedef union {
    MNScoreProgressProviderStateSlice*  asyncScoreSlice;
    MNScoreProgressProviderSyncState*   syncState;
} MNScoreProgressProviderState;

/**
 * @brief "ScoreProgress" MultiNet provider.
 *
 * "ScoreProgress" provider provides functionality which allows to exchange
 * information on scores achieved by players during gameplay.
 */
@interface MNScoreProgressProvider : NSObject<MNSessionDelegate> {
    @private

    MNSession* _session;
    int _refreshInterval;
    double _updateDelay;
    BOOL _asyncMode;
    MNDelegateArray* _delegates;

    MNScoreProgressProviderScoreCompareFunc _scoreCompareFunc;
    void*                                 _scoreCompareFuncContext;

    BOOL _running;
    NSDate* _startTime;

    NSTimer*  _postScoreTimer;
    long long _currentScore;

    MNScoreProgressProviderState _scoreState;
}

/**
 * Initializes and return newly allocated MNScoreProgressProvider object.
 * @param session MultiNet session instance
 * @param refreshInterval time in milliseconds between successive score
 * information updates. If refreshInterval is less or equal to zero, information
 * on player score will be sended immediately after postScore: call.
 * @param updateDelay time in milliseconds to wait for other player's score
 * information. If refreshInterval is less or equal to zero, this parameter is
 * not used. If this parameter is less or equal to zero and refreshInterval
 * is greater than zero, refreshInterval / 3 will be used as update delay.
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session
      refreshInterval: (int) refreshInterval
      andUpdateDelay: (int) updateDelay;

/**
 * Initializes and return newly allocated MNScoreProgressProvider object with
 * zero refreshInterval and updateDelay values.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session;

/**
 * Sets new refresh interval and update delay parameters. Should not be called during gameplay.
 * @param refreshInterval time in milliseconds between successive score
 * information updates. If refreshInterval is less or equal to zero, information
 * on player score will be sended immediately after postScore: call.
 * @param updateDelay time in milliseconds to wait for other player's score
 * information. If refreshInterval is less or equal to zero, this parameter is
 * not used. If this parameter is less or equal to zero and refreshInterval
 * is greater than zero, refreshInterval / 3 will be used as update delay.
 */
-(void) setRefreshInterval:(int) refreshInterval andUpdateDelay:(int) updateDelay;

/**
 * Start score information exchange.
 */
-(void) start;

/**
 * Finish score information exchange.
 */
-(void) stop;

/**
 * Set score comparison function.
 *
 * @param compareFunc function to be used during scores sorting
 * @param context parameter to be passed as a third parameter to compareFunc
 */
-(void) setScoreCompareFunc: (MNScoreProgressProviderScoreCompareFunc) compareFunc
                withContext: (void*) context;

/**
 * Schedule player score update.
 *
 * @param score new player score
 */
-(void) postScore: (long long) score;

/**
 * Adds delegate
 * @param delegate an object conforming to MNScoreProgressProviderDelegate protocol
 */
-(void) addDelegate:(id<MNScoreProgressProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNScoreProgressProviderDelegate>) delegate;
@end
