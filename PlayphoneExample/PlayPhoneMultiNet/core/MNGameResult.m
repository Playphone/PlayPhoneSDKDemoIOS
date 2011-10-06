//
//  MNGameResult.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/30/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNGameResult.h"


@implementation MNGameResult

@synthesize score = _score;
@synthesize scorePostLinkId = _scorePostLinkId;
@synthesize gameSetId = _gameSetId;

-(id) initWithGameParams:(MNGameParams*) gameParams {
    self = [super init];

    if (self != nil) {
        if (gameParams != nil) {
            self.scorePostLinkId = gameParams.scorePostLinkId;
            _gameSetId = gameParams.gameSetId;
        }
        else {
            _gameSetId = MN_GAMESET_ID_DEFAULT;
        }

        _score = 0;
    }

    return self;
}

-(void) dealloc {
    [_scorePostLinkId release];
    [super dealloc];
}

@end
