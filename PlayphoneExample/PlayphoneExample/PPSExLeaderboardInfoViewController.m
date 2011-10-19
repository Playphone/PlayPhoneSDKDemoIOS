//
//  PPSExLeaderboardInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 13.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNWSRequest.h"
#import "MNWSLeaderboardListItem.h"

#import "PPSExCommon.h"

#import "PPSExLeaderboardInfoViewController.h"

static NSString *PPSExLeaderboardEmpty = @"<No data>";

@interface PPSExLeaderboardInfoViewController()
@property (nonatomic,retain) NSString    *requestBlockName;
@property (nonatomic,retain) NSArray     *leaderboardData;
@property (nonatomic,retain) MNWSRequest *wsRequest;

- (void)updateView;
- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;
- (void)cancelRequestSafely;

@end

@implementation PPSExLeaderboardInfoViewController

@synthesize requestBlockName    = _requestBlockName;
@synthesize leaderboardData     = _leaderboardData;
@synthesize gameSetting         = _gameSetting;
@synthesize scoreTextField      = _scoreTextField;
@synthesize leaderboardTextView = _leaderboardTextView;
@synthesize postScoreButton     = _postScoreButton;
@synthesize wsRequest           = _wsRequest;

- (void)viewDidLoad {
    _requestBlockName = nil;
    _leaderboardData  = nil;
    _gameSetting      = nil;
    _wsRequest        = nil;
}

- (void)viewDidUnload {
    [self setScoreTextField     :nil];
    [self setLeaderboardTextView:nil];
    [self setPostScoreButton    :nil];
    
    [self cancelRequestSafely];
    
    [super viewDidUnload];
}

- (void)dealloc {
    [_scoreTextField      release];
    [_leaderboardTextView release];
    [_postScoreButton     release];

    [self cancelRequestSafely];

    [super dealloc];
}

- (void)cancelRequestSafely {
    if (self.wsRequest != nil) {
        [self.wsRequest cancel];

        self.wsRequest = nil;
    }
}

- (void)setGameSetting:(MNGameSettingInfo *)gameSetting {
    if (_gameSetting != nil) {
        [_gameSetting release];
    }
    
    _gameSetting = gameSetting;
    
    [self updateState];
}

- (IBAction)doPostScore:(id)sender {
    long long  score = 0;
    
    if (![MNDirect isUserLoggedIn]) {
        PPSExShowNotLoggedInAlert();
    }
    else if (!PPSExScanLongLong(self.scoreTextField.text,&score)) {
        PPSExShowInvalidNumberFormatAlert();
    }
    else {
        [MNDirect postGameScore:score];
        
        [self updateState];
    }

    [self.scoreTextField resignFirstResponder];
}

- (void)updateState {
    if (![MNDirect isUserLoggedIn]) {
        [self switchToNotLoggedInState];
    }
    else if (self.gameSetting != nil) {
        [self switchToLoggedInState];
        
        [MNDirect setDefaultGameSetId:self.gameSetting.gameSetId];
        
        MNWSRequestContent* requestContent = [[[MNWSRequestContent alloc] init] autorelease];
        
        self.requestBlockName = [requestContent addCurrUserLeaderboard: MNWS_LEADERBOARD_SCOPE_GLOBAL period: MNWS_LEADERBOARD_PERIOD_ALL_TIME];
        
        MNWSRequestSender* requestSender = [[[MNWSRequestSender alloc] initWithSession: [MNDirect getSession]] autorelease];
        
        self.wsRequest = [requestSender sendWSRequestAuthorized: requestContent withDelegate: self];
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)updateView {
    if ((self.leaderboardData == nil) || ([self.leaderboardData count] == 0)) {
        self.leaderboardTextView.text = PPSExLeaderboardEmpty;
    }
    else {
        NSMutableString *leaderboardDataString = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
        
        for (MNWSLeaderboardListItem* leaderboardItem in self.leaderboardData) {
            if ([leaderboardItem getGamesetId].intValue == self.gameSetting.gameSetId) {
                [leaderboardDataString appendFormat:
                 @"%@ : %@\n",
                 [leaderboardItem getUserNickName],
                 [leaderboardItem getOutHiScoreText]];
            }
        }
        
        self.leaderboardTextView.text = leaderboardDataString;
    }
}

- (void)switchToLoggedInState {
    self.postScoreButton.enabled = YES;
    self.leaderboardTextView.text = PPSExLeaderboardEmpty;
}

- (void)switchToNotLoggedInState {
    self.postScoreButton.enabled = NO;
    self.leaderboardTextView.text = PPSExUserNotLoggedInString;
}

#pragma mark - MNWSRequestDelegate

-(void) wsRequestDidSucceed:(MNWSResponse*) response {
    self.leaderboardData = [response getDataForBlock: self.requestBlockName];
    
    [self updateView];
    
    self.requestBlockName = nil;
    self.wsRequest        = nil;
}

-(void) wsRequestDidFailWithError:(MNWSRequestError*) error {
    PPSExShowWSRequestErrorAlert(error.message);
    
    self.requestBlockName = nil;
    self.wsRequest        = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    // [self updateState];
    [self switchToNotLoggedInState];
}

@end
