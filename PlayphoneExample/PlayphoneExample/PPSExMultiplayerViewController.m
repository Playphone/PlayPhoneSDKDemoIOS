//
//  PPSExMultiplayerViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"

#import "PlayphoneExampleAppDelegate.h"
#import "PPSExCommon.h"
#import "PPSExMultiplayerViewController.h"


#define PPSExMultoplayerScoreDelta (10)

static NSString *PPSExMultiplayerPlayNextRoundButtonName = @"Play next round";


@interface PPSExMultiplayerViewController()
@property (assign, nonatomic) long long currentScore;

@end

@implementation PPSExMultiplayerViewController

@synthesize scoreProgressView   = _scoreProgressView;
@synthesize currentScoreLabel   = _currentScoreLabel;
@synthesize countdownLabel      = _countdownLabel;
@synthesize tipTextView         = _tipTextView;
@synthesize addScoreButton      = _addScoreButton;
@synthesize subtractScoreButton = _subtractScoreButton;
@synthesize postScoreButton     = _postScoreButton;
@synthesize currentScore        = _currentScore;

- (void)viewDidLoad {
    [super viewDidLoad];

    if (PPSExAppDelegate.sessionReady) {
        [self.scoreProgressView sessionReady];
    }
    
    [[MNDirect getSession]addDelegate:self];
}

- (void)viewDidUnload {
    [MNDirect cancelGame];
    
    [self setScoreProgressView  :nil];
    [self setCurrentScoreLabel  :nil];
    [self setCountdownLabel     :nil];
    [self setTipTextView        :nil];
    [self setAddScoreButton     :nil];
    [self setSubtractScoreButton:nil];
    [self setPostScoreButton    :nil];
    
    [[MNDirect getSession]removeDelegate:self];

    [super viewDidUnload];
}

- (void)dealloc {
    [MNDirect cancelGame];
    
    [_scoreProgressView   release];
    [_currentScoreLabel   release];
    [_countdownLabel      release];
    [_tipTextView         release];
    [_addScoreButton      release];
    [_subtractScoreButton release];
    [_postScoreButton     release];

    [[MNDirect getSession]removeDelegate:self];
    
    [super dealloc];
}

- (void)setCurrentScore:(long long)currentScore {
    _currentScore = currentScore;

    if (self.scoreProgressView.hidden == NO) {
        [self.scoreProgressView postScore:currentScore];
    }
    
    self.currentScoreLabel.text = [NSString stringWithFormat:@"Current score: %lld",_currentScore];
}

- (IBAction)doAddScore:(id)sender {
    self.currentScore += PPSExMultoplayerScoreDelta;
}

- (IBAction)doSubtractScore:(id)sender {
    self.currentScore -= PPSExMultoplayerScoreDelta;
}

- (IBAction)doPostScore:(id)sender {
    [MNDirect postGameScore:self.currentScore];
}

- (void)updateState {
    NSInteger sessionStatus = [MNDirect getSessionStatus];
    NSInteger userStatus    = [[MNDirect getSession]getRoomUserStatus];

    PPSExLogMNSessionStatus(sessionStatus);
    PPSExLogMNPlayerStatus(userStatus);
    
    long long oldScore = self.currentScore;
    self.currentScore = 0;
    self.countdownLabel.text = @"";

    self.addScoreButton     .enabled = NO;
    self.subtractScoreButton.enabled = NO;
    
    self.addScoreButton     .hidden = NO;
    self.subtractScoreButton.hidden = NO;
    self.postScoreButton    .hidden = YES;
    
    if      ((sessionStatus == MN_OFFLINE) ||
             (sessionStatus == MN_CONNECTING)) {
        self.tipTextView.text = @"Player should be logged in to use Multiplayer features. Please open PlayPhone dashboard and login to PlayPhone network";
    }
    else if (sessionStatus == MN_LOGGEDIN){
        self.tipTextView.text = @"Please open PlayPhone dashboard and press PlayNow button to start Multiplater game.";
    }
    else {
        //SessionState is one of MN_IN_GAME_*
        
        if      (userStatus == MN_USER_CHATER) {
            self.tipTextView.text = [NSString stringWithFormat:@"Currently you are \"CHATTER\". Please wait for end of current game round and then press \"%@\" button on PPS Dashboard.",PPSExMultiplayerPlayNextRoundButtonName];
        }
        else if (userStatus == MN_USER_PLAYER) {
            if      (sessionStatus == MN_IN_GAME_WAIT) {
                self.tipTextView.text = @"Waiting for opponents";
            }
            else if (sessionStatus == MN_IN_GAME_START) {
                self.tipTextView.text = @"Starting the game";
            }
            else if (sessionStatus == MN_IN_GAME_PLAY) {
                self.tipTextView.text = @"Use buttons to change your score. You will see the progress on the top indicator.";

                self.addScoreButton     .enabled = YES;
                self.subtractScoreButton.enabled = YES;

                self.currentScore = oldScore;
            }
            else if (sessionStatus == MN_IN_GAME_END) {
                self.tipTextView.text = @"Posting the scores.\nYou can use \"Post Score\" button to send current score to PPS server";
                self.addScoreButton     .hidden = YES;
                self.subtractScoreButton.hidden = YES;
                self.postScoreButton    .hidden = NO;

                self.currentScore = oldScore;
            }
            else {
                self.tipTextView.text = [NSString stringWithFormat:@"Undefined state: SessionState: [%s], UserState: [%s]",PPSExSessionStatusAsString(sessionStatus),PPSExUserStatusAsString(userStatus)];
            }
        }
        else {
            self.tipTextView.text = [NSString stringWithFormat:@"Undefined state: SessionState: [%s], UserState: [%s]",PPSExSessionStatusAsString(sessionStatus),PPSExUserStatusAsString(userStatus)];
        }
    }
}

#pragma mark - MNSessionDelegate

- (void)mnSessionStatusChangedTo:(NSUInteger)newStatus from:(NSUInteger)oldStatus {
    [self updateState];
}

- (void)mnSessionUserChangedTo:(MNUserId)userId {
    [self updateState];
}

@end
