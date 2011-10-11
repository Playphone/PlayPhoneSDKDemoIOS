//
//  PPSExAchInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNUIUrlImageView.h"
#import "MNAchievementsProvider.h"

#import "PPSExBasicViewController.h"

@interface PPSExAchInfoViewController : PPSExBasicViewController {
    MNGameAchievementInfo *_achievementInfo;
    UILabel *_achievementIdLabel;
    UILabel *_achievementNameLabel;
    UILabel *_descLabel;
    UISwitch *_isSecretSwitch;
    UITextView *_paramsTextView;
    MNUIUrlImageView *_achievementIcon;
    UILabel *_gamerPointsLabel;
}

@property (nonatomic,retain) MNGameAchievementInfo *achievementInfo;

@property (nonatomic, retain) IBOutlet UILabel *achievementIdLabel;
@property (nonatomic, retain) IBOutlet UILabel *achievementNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *gamerPointsLabel;
@property (nonatomic, retain) IBOutlet UILabel *descLabel;
@property (nonatomic, retain) IBOutlet UISwitch *isSecretSwitch;
@property (nonatomic, retain) IBOutlet UITextView *paramsTextView;
@property (nonatomic, retain) IBOutlet MNUIUrlImageView *achievementIcon;

@end
