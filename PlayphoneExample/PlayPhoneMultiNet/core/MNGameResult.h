//
//  MNGameResult.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/30/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNGameParams.h"

/**
 * @brief Game result object
 */
@interface MNGameResult : NSObject {
    long long _score;
    NSString* _scorePostLinkId;
    NSInteger _gameSetId;
}

/**
 * Score value
 */
@property (nonatomic,assign) long long score;
/**
 * Score accounting service link (issued by server)
 */
@property (nonatomic,retain) NSString* scorePostLinkId;
/**
 * Gameset id
 */
@property (nonatomic,assign) NSInteger gameSetId;

/**
 * Initializes and returns newly allocated object with specified parameters.
 * @param gameParams specifies parameters of game for which results will be stored
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) initWithGameParams:(MNGameParams*) gameParams;

/**
 * Release all acquired resources
 */
-(void) dealloc;

@end
