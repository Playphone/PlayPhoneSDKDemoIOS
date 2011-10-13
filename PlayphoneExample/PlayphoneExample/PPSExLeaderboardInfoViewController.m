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
@property (nonatomic,retain) NSString *requestBlockName;
@property (nonatomic,retain) NSArray *leaderboardData;

- (void)updateView;

@end

@implementation PPSExLeaderboardInfoViewController

@synthesize requestBlockName = _requestBlockName;
@synthesize leaderboardData = _leaderboardData;
@synthesize gameSetting = _gameSetting;
@synthesize scoreTextField = _scoreTextField;
@synthesize leaderboardTextView = _leaderboardTextView;

- (void)viewDidLoad {
    _requestBlockName = nil;
    _leaderboardData  = nil;
    _gameSetting      = nil;
}

- (void)viewDidUnload {
    [self setScoreTextField:nil];
    [self setLeaderboardTextView:nil];
    [super viewDidUnload];
}


- (void)dealloc {
    [_scoreTextField release];
    [_leaderboardTextView release];
    [super dealloc];
}

- (void)setGameSetting:(MNGameSettingInfo *)gameSetting {
    if (_gameSetting != nil) {
        [_gameSetting release];
    }
    
    _gameSetting = gameSetting;
    
    [self updateState];
}

- (IBAction)doPostScore:(id)sender {
}

- (void)updateState {
    MNWSRequestContent* requestContent = [[[MNWSRequestContent alloc] init] autorelease];
    
    self.requestBlockName = [requestContent addCurrUserLeaderboard: MNWS_LEADERBOARD_SCOPE_GLOBAL period: MNWS_LEADERBOARD_PERIOD_ALL_TIME];
    
    MNWSRequestSender* requestSender = [[[MNWSRequestSender alloc] initWithSession: [MNDirect getSession]] autorelease];
    
    [requestSender sendWSRequestAuthorized: requestContent withDelegate: self];
}

- (void)updateView {
    if ((self.leaderboardData == nil) || ([self.leaderboardData count] == 0)) {
        self.leaderboardTextView.text = PPSExLeaderboardEmpty;
    }
    else {
        NSMutableString *leaderboardDataString = [NSMutableString stringWithCapacity:1024];
        
        for (MNWSLeaderboardListItem* leaderboardItem in self.leaderboardData) {
            [leaderboardDataString appendFormat:
             @"Player: %@ score: %@\n",
             [leaderboardItem getUserNickName],
             [leaderboardItem getOutHiScoreText]];
        }
        
        self.leaderboardTextView.text = leaderboardDataString;
    }
}

#pragma mark - MNWSRequestDelegate

-(void) wsRequestDidSucceed:(MNWSResponse*) response {
    self.leaderboardData = [response getDataForBlock: self.requestBlockName];
    
    
    self.requestBlockName = nil;
}

-(void) wsRequestDidFailWithError:(MNWSRequestError*) error {
    PPSExShowAlert([NSString stringWithFormat:@"Error: %@",error.message], @"Request error");
    
    self.requestBlockName = nil;
}

@end
