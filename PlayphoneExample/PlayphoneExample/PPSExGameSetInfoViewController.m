//
//  PPSExGameSetInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 21.10.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExGameSetInfoViewController.h"


#define PPSExGameSetInfoViewMinHeight (700)


@implementation PPSExGameSetInfoViewController

@synthesize gameSetting          = _gameSetting;
@synthesize gameSetIdLabel       = _gameSetIdLabel;
@synthesize gameSetNameLabel     = _gameSetNameLabel;
@synthesize multiplayerSwitch    = _multiplayerSwitch;
@synthesize leaderboardSwitch    = _leaderboardSwitch;
@synthesize paramsTextView       = _paramsTextView;
@synthesize systemParamsTextView = _systemParamsTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentMinHeght = PPSExGameSetInfoViewMinHeight;

    _gameSetting = nil;
}

- (void)viewDidUnload {
    [self setGameSetIdLabel      :nil];
    [self setGameSetNameLabel    :nil];
    [self setMultiplayerSwitch   :nil];
    [self setLeaderboardSwitch   :nil];
    [self setParamsTextView      :nil];
    [self setSystemParamsTextView:nil];
    
    self.gameSetting = nil;

    [super viewDidUnload];
}

- (void)dealloc {
    [_gameSetIdLabel       release];
    [_gameSetNameLabel     release];
    [_multiplayerSwitch    release];
    [_leaderboardSwitch    release];
    [_paramsTextView       release];
    [_systemParamsTextView release];
    
    [_gameSetting          release];

    [super dealloc];
}

- (void)setGameSetting:(MNGameSettingInfo *)gameSetting {
    if (_gameSetting != nil) {
        [_gameSetting release];
    }
    
    _gameSetting = [gameSetting retain];
    
    [self updateState];
}

- (void)updateState {
    self.gameSetIdLabel      .text = [NSString stringWithFormat:@"Setting Id: %d",self.gameSetting.gameSetId];
    self.gameSetNameLabel    .text = [NSString stringWithFormat:@"Name: %@",self.gameSetting.name];
    self.paramsTextView      .text = self.gameSetting.params;
    self.systemParamsTextView.text = self.gameSetting.sysParams;

    self.multiplayerSwitch.on = self.gameSetting.isMultiplayerEnabled;
    self.leaderboardSwitch.on = self.gameSetting.isLeaderboardVisible;
}

@end
