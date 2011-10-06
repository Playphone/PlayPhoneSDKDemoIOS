//
//  MNCurrGameResults.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/3/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNCurrGameResults.h"

@implementation MNCurrGameResults

@synthesize gameId = _gameId;
@synthesize gameSetId = _gameSetId;
@synthesize userInfoList = _userInfoList;
@synthesize userPlaceList = _userPlaceList;
@synthesize userScoreList = _userScoreList;
@synthesize finalResult = _finalResult;
@synthesize playRoundNumber = _playRoundNumber;

-(id) initWithGameId:(NSInteger) gameId gameSetId:(NSInteger) gameSetId
      finalResult:(BOOL) finalResult playRoundNumber:(long long) playRoundNumber {
    self = [super init];

    if (self != nil) {
        _gameId = gameId;
        _gameSetId = gameSetId;
        _finalResult = finalResult;
        _playRoundNumber = playRoundNumber;
    }

    return self;
}

-(void) dealloc {
    [_userInfoList release];
    [_userPlaceList release];
    [_userScoreList release];

    [super dealloc];
}

@end

