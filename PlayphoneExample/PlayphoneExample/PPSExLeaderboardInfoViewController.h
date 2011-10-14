//
//  PPSExLeaderboardInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 13.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNWSRequest.h"
#import "MNGameSettingsProvider.h"
#import "PPSExBasicViewController.h"

@interface PPSExLeaderboardInfoViewController : PPSExBasicViewController <MNWSRequestDelegate> {
    MNGameSettingInfo *_gameSetting;
    NSString *_requestBlockName;
    NSArray *_leaderboardData;

    UITextField *_scoreTextField;
    UITextView *_leaderboardTextView;
}

@property (nonatomic,retain) MNGameSettingInfo *gameSetting;

@property (nonatomic, retain) IBOutlet UITextField *scoreTextField;
@property (nonatomic, retain) IBOutlet UITextView *leaderboardTextView;
@property (retain, nonatomic) IBOutlet UIButton *postScoreButton;

- (IBAction)doPostScore:(id)sender;

@end
