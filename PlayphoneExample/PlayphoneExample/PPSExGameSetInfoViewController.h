//
//  PPSExGameSetInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 21.10.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "MNGameSettingsProvider.h"

#import "PPSExBasicViewController.h"

@interface PPSExGameSetInfoViewController : PPSExBasicViewController
{
    MNGameSettingInfo *_gameSetting;
}

@property (retain, nonatomic) MNGameSettingInfo   *gameSetting;

@property (retain, nonatomic) IBOutlet UILabel    *gameSetIdLabel;
@property (retain, nonatomic) IBOutlet UILabel    *gameSetNameLabel;
@property (retain, nonatomic) IBOutlet UISwitch   *multiplayerSwitch;
@property (retain, nonatomic) IBOutlet UISwitch   *leaderboardSwitch;
@property (retain, nonatomic) IBOutlet UITextView *paramsTextView;
@property (retain, nonatomic) IBOutlet UITextView *systemParamsTextView;

@end
