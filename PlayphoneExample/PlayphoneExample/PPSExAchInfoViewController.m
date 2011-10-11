//
//  PPSExAchInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNAchievementsProvider.h"
#import "PPSExAchInfoViewController.h"

@implementation PPSExAchInfoViewController

@synthesize achievementInfo = _achievementInfo;
@synthesize achievementIdLabel = _achievementIdLabel;
@synthesize achievementNameLabel = _achievementNameLabel;
@synthesize descLabel = _descLabel;
@synthesize isSecretSwitch = _isSecretSwitch;
@synthesize paramsTextView = _paramsTextView;
@synthesize achievementIcon = _achievementIcon;
@synthesize gamerPointsLabel = _gamerPointsLabel;

- (void)viewDidUnload
{
    [self setAchievementIdLabel:nil];
    [self setAchievementNameLabel:nil];
    [self setDescLabel:nil];
    [self setIsSecretSwitch:nil];
    [self setParamsTextView:nil];
    [self setAchievementIcon:nil];

    [self setGamerPointsLabel:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [_achievementIdLabel release];
    [_achievementNameLabel release];
    [_descLabel release];
    [_isSecretSwitch release];
    [_paramsTextView release];
    [_achievementIcon release];
    
    [_gamerPointsLabel release];
    [super dealloc];
}

- (void)setAchievementInfo:(MNGameAchievementInfo *)achievementInfo {
    if (_achievementInfo != nil) {
        [_achievementInfo release];
    }
    
    _achievementInfo = achievementInfo;
    
    [self updateState];
}

- (void)updateState {
    if (self.achievementInfo == nil) {
        return;
    }
    
    self.achievementIdLabel  .text = [NSString stringWithFormat:@"Id: %d",self.achievementInfo.achievementId];
    self.achievementNameLabel.text = self.achievementInfo.name;
    self.gamerPointsLabel    .text = [NSString stringWithFormat:@"Gamer points: %d",self.achievementInfo.points];
    self.descLabel           .text = self.achievementInfo.description;
    self.paramsTextView      .text = self.achievementInfo.params;
    
    self.isSecretSwitch.on = self.achievementInfo.flags & MNAchievementIsSecretMask;
    
    [self.achievementIcon loadImageWithUrl:[[MNDirect achievementsProvider]getAchievementImageURL:self.achievementInfo.achievementId]];
}

@end
