//
//  MNCurrGameResults.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/3/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Current game results storage
 */
@interface MNCurrGameResults : NSObject {
    NSInteger _gameId;
    NSInteger _gameSetId;

    NSArray* _userInfoList;
    NSArray* _userPlaceList;
    NSArray* _userScoreList;

    BOOL _finalResult;
    long long _playRoundNumber;
}

/**
 * Game id
 */
@property (nonatomic,assign) NSInteger gameId;
/**
 * Gameset id
 */
@property (nonatomic,assign) NSInteger gameSetId;
/**
 * Array of MNUserInfo instances containing information about players
 */
@property (nonatomic,retain) NSArray* userInfoList;
/**
 * Array of NSNumber instances containing places (integers) users scored
 */
@property (nonatomic,retain) NSArray* userPlaceList;
/**
 * Array of NSNumber instances containing scores (long long values) users achieved
 */
@property (nonatomic,retain) NSArray* userScoreList;
/**
 * Boolean value that determines whether results are final
 */
@property (nonatomic,assign) BOOL finalResult;
/**
 * Round number
 */
@property (nonatomic,assign) long long playRoundNumber;

/**
 * Initializes and returns newly allocated object with specified parameters.
 * @param gameId game id
 * @param gameSetId gameset id
 * @param finalResult boolean value that determines whether results are final
 * @param playRoundNumber round number
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) initWithGameId:(NSInteger) gameId gameSetId:(NSInteger) gameSetId
      finalResult:(BOOL) finalResult playRoundNumber:(long long) playRoundNumber;

/**
 * Release all acquired resources
 */
-(void) dealloc;

@end
