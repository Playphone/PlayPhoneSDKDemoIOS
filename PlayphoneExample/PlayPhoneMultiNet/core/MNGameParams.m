//
//  MNGameParams.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/27/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNGameParams.h"

#define MNGameParamsGameSetPlayParamsInitialCapacity (5)

@implementation MNGameParams

@synthesize gameSetId = _gameSetId;
@synthesize gameSetParams = _gameSetParams;
@synthesize scorePostLinkId = _scorePostLinkId;
@synthesize gameSeed = _gameSeed;
@synthesize playModel = _playModel;

-(id) initWithGameSetId:(NSInteger) gameSetId gameSetParams:(NSString*) gameSetParams
              scorePostLinkId:(NSString*) scorePostLinkId gameSeed:(NSInteger) gameSeed
              playModel:(NSUInteger) playModel {
    self = [super init];

    if (self != nil) {
        _gameSetId = gameSetId;
        self.gameSetParams = gameSetParams;
        self.scorePostLinkId = scorePostLinkId;
        _gameSeed = gameSeed;
        _gameSetPlayParams = [[NSMutableDictionary alloc] initWithCapacity: MNGameParamsGameSetPlayParamsInitialCapacity];
        _playModel = playModel;
    }

    return self;
}

-(void) dealloc {
    [_gameSetParams release];
    [_scorePostLinkId release];
    [_gameSetPlayParams release];

    [super dealloc];
}

-(void) addGameSetPlayParam:(NSString*) paramName value:(NSString*) paramValue {
    [_gameSetPlayParams setValue: paramValue forKey: paramName];
}

-(NSString*) getGameSetPlayParamByName:(NSString*) paramName {
    return (NSString*)[_gameSetPlayParams objectForKey: paramName];
}

@end
