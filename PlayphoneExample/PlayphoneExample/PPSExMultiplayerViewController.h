//
//  PPSExMultiplayerViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "MNSession.h"
#import "MNScoreProgressSideBySideView.h"

#import "PPSExBasicViewController.h"

@interface PPSExMultiplayerViewController : PPSExBasicViewController <MNSessionDelegate>
{
    MNScoreProgressSideBySideView *_scoreProgressView;
    UILabel    *_currentScoreLabel;
    UILabel    *_countdownLabel;
    UITextView *_tipTextView;
    UIButton   *_addScoreButton;
    UIButton   *_subtractScoreButton;
    UIButton   *_postScoreButton;
    
    long long   _currentScore;
}

@property (retain, nonatomic) IBOutlet MNScoreProgressSideBySideView *scoreProgressView;
@property (retain, nonatomic) IBOutlet UILabel    *currentScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel    *countdownLabel;
@property (retain, nonatomic) IBOutlet UITextView *tipTextView;
@property (retain, nonatomic) IBOutlet UIButton   *addScoreButton;
@property (retain, nonatomic) IBOutlet UIButton   *subtractScoreButton;
@property (retain, nonatomic) IBOutlet UIButton   *postScoreButton;

- (IBAction)doAddScore     :(id)sender;
- (IBAction)doSubtractScore:(id)sender;
- (IBAction)doPostScore    :(id)sender;

@end
