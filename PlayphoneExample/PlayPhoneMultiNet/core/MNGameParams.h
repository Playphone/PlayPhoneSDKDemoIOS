//
//  MNGameParams.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/27/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MN_GAMESET_ID_DEFAULT (0)

#define MN_PLAYMODEL_SINGLEPLAY     (0x0000)
#define MN_PLAYMODEL_SINGLEPLAY_NET (0x0100)
#define MN_PLAYMODEL_MULTIPLAY      (0x1000)

/**
 * @brief Game parameters object
 */
@interface MNGameParams : NSObject {
    @private

    NSInteger _gameSetId;
    NSString* _gameSetParams;
    NSString* _scorePostLinkId;
    NSInteger _gameSeed;
    NSMutableDictionary* _gameSetPlayParams;
    NSUInteger _playModel;
}

/**
 * Gameset id
 */
@property (nonatomic,assign) NSInteger gameSetId;
/**
 * Gameset parameters
 */
@property (nonatomic,retain) NSString* gameSetParams;
/**
 * Score accounting service link (issued by server)
 */
@property (nonatomic,retain) NSString* scorePostLinkId;
/**
 * Game seed
 */
@property (nonatomic,assign) NSInteger gameSeed;
/**
 * Play model, one of the MN_PLAYMODEL_SINGLEPLAY, MN_PLAYMODEL_SINGLEPLAY_NET or MN_PLAYMODEL_MULTIPLAY.
 */
@property (nonatomic,assign) NSUInteger playModel;

/**
 * Initializes and returns newly allocated object with specified parameters.
 * @param gameSetId gameset id
 * @param gameSetParams gameset parameters
 * @param scorePostLinkId score accounting service link (issued by server)
 * @param gameSeed game seed
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) initWithGameSetId:(NSInteger) gameSetId gameSetParams:(NSString*) gameSetParams
        scorePostLinkId:(NSString*) scorePostLinkId gameSeed:(NSInteger) gameSeed
        playModel:(NSUInteger) playModel;

/**
 * Destroys object and releases all acquired resources.
 */
-(void) dealloc;

/**
 * Adds gameset parameter
 * @param paramName parameter name
 * @param paramValue parameter value
 */
-(void) addGameSetPlayParam:(NSString*) paramName value:(NSString*) paramValue;

/**
 * Returns the value associated with a given gameset parameter
 * @param paramName parameter name
 * @return parameter value, or nil if parameter with a given name does not exist
 */
-(NSString*) getGameSetPlayParamByName:(NSString*) paramName;

@end
