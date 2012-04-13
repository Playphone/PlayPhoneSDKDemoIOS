//
//  PPSExLeaderboardRequestViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 02.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNSession.h"
#import "MNWSRequest.h"
#import "MNWSLeaderboardListItem.h"

#import "PPSExCommon.h"

#import "PPSExLeaderboardRequestViewController.h"


#define PPSExLeaderboardRequestViewMinHeight   (455)

#define PPSExLeaderboardRequestPlayerCurrent   (0)
#define PPSExLeaderboardRequestPlayerCustom    (1)
#define PPSExLeaderboardRequestPlayerDefValue  (PPSExLeaderboardRequestPlayerCurrent)

#define PPSExLeaderboardRequestGameCurrent     (0)
#define PPSExLeaderboardRequestGameCustom      (1)
#define PPSExLeaderboardRequestGameDefValue    (PPSExLeaderboardRequestGameCurrent)

#define PPSExLeaderboardRequestPeriodAllTime   (0)
#define PPSExLeaderboardRequestPeriodThisWeek  (1)
#define PPSExLeaderboardRequestPeriodThisMonth (2)

#define PPSExLeaderboardRequestPeriodDefValue  (PPSExLeaderboardRequestPeriodAllTime)

static NSString *PPSExLeaderboardRequestResultViewTitle = @"Request Result";


@interface PPSExLeaderboardRequestViewController()
@property (retain, nonatomic) PPSExInfoPaneViewController *infoViewController;
@property (retain, nonatomic) NSString                    *wsRequestBlockName;
@property (retain, nonatomic) MNWSRequest                 *wsRequest;

- (void)cancelRequestSafely;

- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;

- (void)updatePlayerSelector;
- (void)updateGameSelector;

- (void)fillCurrentPlayerId;
- (void)fillCurrentGameId;

@end


@implementation PPSExLeaderboardRequestViewController

@synthesize showPlayerSelection    = _showPlayerSelection;
@synthesize wsRequestBlockName     = _wsRequestBlockName;
@synthesize wsRequest              = _wsRequest;
@synthesize gameIdTextField        = _gameIdTextField;
@synthesize gameSetIdTextField     = _gameSetIdTextField;
@synthesize playerSegmentedControl = _playerSegmentedControl;
@synthesize gameSegmentedControl   = _gameSegmentedControl;
@synthesize periodSegmentedControl = _periodSegmentedControl;
@synthesize playerView             = _playerView;
@synthesize gameView               = _gameView;
@synthesize playerIdTextField      = _playerIdTextField;
@synthesize infoViewController     = _infoViewController;


- (void)viewDidLoad {
    [super viewDidLoad];

    self.contentMinHeght = PPSExLeaderboardRequestViewMinHeight;
    
    self.playerSegmentedControl.selectedSegmentIndex = PPSExLeaderboardRequestPlayerDefValue;
    self.gameSegmentedControl  .selectedSegmentIndex = PPSExLeaderboardRequestGameDefValue;
    self.periodSegmentedControl.selectedSegmentIndex = PPSExLeaderboardRequestPeriodDefValue;
        
    [self fillCurrentPlayerId];
    [self fillCurrentGameId];
    
    [self updatePlayerSelector];
    [self updateGameSelector];

    self.gameSetIdTextField.text = @"0";
}

- (void)viewDidUnload {
    [self setPlayerIdTextField     :nil];
    [self setGameIdTextField       :nil];
    [self setGameSetIdTextField    :nil];
    [self setPlayerSegmentedControl:nil];
    [self setGameSegmentedControl  :nil];
    [self setPeriodSegmentedControl:nil];
    [self setPlayerView            :nil];
    [self setGameView              :nil];

    self.infoViewController = nil;

    [self cancelRequestSafely];

    [super viewDidUnload];
}

- (void)dealloc {
    [_playerIdTextField      release];
    [_gameIdTextField        release];
    [_gameSetIdTextField     release];
    [_playerSegmentedControl release];
    [_gameSegmentedControl   release];
    [_periodSegmentedControl release];
    [_playerView             release];
    [_gameView               release];

    [_infoViewController     release];
    
    [self cancelRequestSafely];
    
    [super dealloc];
}

- (void)cancelRequestSafely {
    [self stopActivityIndicator];
    
    self.wsRequestBlockName = nil;
    
    if (self.wsRequest != nil) {
        [self.wsRequest cancel];
        
        self.wsRequest = nil;
    }
}

- (void)setShowPlayerSelection:(BOOL)showPlayerSelection {
    _showPlayerSelection = showPlayerSelection;
    
    if ((self.playerView != nil) && (self.gameView != nil)) {
        if (_showPlayerSelection) {
            self.playerView.hidden = NO;
            
            self.gameView.frame = CGRectMake(self.gameView  .frame.origin.x  ,self.playerView.frame.size.height,
                                             self.gameView  .frame.size.width,self.gameView  .frame.size.height);

            self.contentMinHeght = PPSExLeaderboardRequestViewMinHeight;
        }
        else {
            self.playerView.hidden = YES;
            self.gameView.frame = CGRectMake(self.gameView.frame.origin.x  ,0,
                                             self.gameView.frame.size.width,self.gameView.frame.size.height);

            self.contentMinHeght = PPSExLeaderboardRequestViewMinHeight - self.playerView.frame.size.height;
        }
    }
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)switchToLoggedInState {
    [self.playerSegmentedControl setEnabled:YES forSegmentAtIndex:PPSExLeaderboardRequestPlayerCurrent];
}

- (void)switchToNotLoggedInState {
    self.playerSegmentedControl.selectedSegmentIndex = PPSExLeaderboardRequestPlayerCustom;
    [self.playerSegmentedControl setEnabled:NO forSegmentAtIndex:PPSExLeaderboardRequestPlayerCurrent];

    [self updatePlayerSelector];
}

- (IBAction)playerChanged:(id)sender {
    if (self.playerSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestPlayerCurrent) {
        [self fillCurrentPlayerId];
    }
    
    [self updatePlayerSelector];
}

- (IBAction)gameChanged:(id)sender {
    if (self.gameSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestGameCurrent) {
        [self fillCurrentGameId];
    }
    
    [self updateGameSelector];
}

- (IBAction)periodChanged:(id)sender {
}

- (IBAction)doSendRequest:(id)sender {
    
    BOOL resultFlag = YES;
    
    NSInteger gameId;
    NSInteger gameSetId;
    NSInteger periodId;
    
    resultFlag = resultFlag & PPSExScanInteger(self.gameIdTextField.text,&gameId);
    
    if (!resultFlag) {
        PPSExShowAlert(PPSExInvalidNumberFormatString,@"Game Id Field Error");
    }
    else {
        self.gameIdTextField.text = [NSString stringWithFormat:@"%d",gameId];
    }
        
    
    resultFlag = resultFlag & PPSExScanInteger(self.gameSetIdTextField.text,&gameSetId);

    if (!resultFlag) {
        PPSExShowAlert(PPSExInvalidNumberFormatString,@"GameSet Id Field Error");
    }
    else {
        self.gameSetIdTextField.text = [NSString stringWithFormat:@"%d",gameSetId];
    }

    if      (self.periodSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestPeriodAllTime  ) {
        periodId = MNWS_LEADERBOARD_PERIOD_ALL_TIME;
    }
    else if (self.periodSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestPeriodThisMonth) {
        periodId = MNWS_LEADERBOARD_PERIOD_THIS_MONTH;
    }
    else if (self.periodSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestPeriodThisWeek ) {
        periodId = MNWS_LEADERBOARD_PERIOD_THIS_WEEK;
    }
    else {
        periodId = PPSExLeaderboardRequestPeriodDefValue;
    }
    
    if (resultFlag) {
        if (!self.showPlayerSelection) {
            MNWSRequestContent* requestContent = [[[MNWSRequestContent alloc] init] autorelease];
            
            self.wsRequestBlockName = [requestContent addAnyGameLeaderboardGlobal:gameId gameSetId:gameSetId period:periodId];
            
            MNWSRequestSender* requestSender = [[[MNWSRequestSender alloc] initWithSession: [MNDirect getSession]] autorelease];
            
            //NOTE: not autorized request!
            self.wsRequest = [requestSender sendWSRequest: requestContent withDelegate: self];
            
            [self startActivityIndicator];
        }
        else {
            NSInteger playerId;
            
            resultFlag = resultFlag & PPSExScanInteger(self.playerIdTextField.text,&playerId);
            
            if (!resultFlag) {
                PPSExShowAlert(PPSExInvalidNumberFormatString,@"Player Id Field Error");
            }
            else {
                self.playerIdTextField.text = [NSString stringWithFormat:@"%d",playerId];
                
                MNWSRequestContent* requestContent = [[[MNWSRequestContent alloc] init] autorelease];
                MNWSRequestSender*  requestSender  = [[[MNWSRequestSender alloc] initWithSession: [MNDirect getSession]] autorelease];

                if (self.playerSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestPlayerCurrent) {
                    self.wsRequestBlockName = [requestContent addCurrUserAnyGameLeaderboardLocal:gameId gameSetId:gameSetId period:periodId];

                    //NOTE: autorized request!
                    self.wsRequest = [requestSender sendWSRequestAuthorized: requestContent withDelegate: self];
                }
                else {
                    self.wsRequestBlockName = [requestContent addAnyUserAnyGameLeaderboardGlobal:playerId gameId:gameId gameSetId:gameSetId period:periodId];
                    
                    //NOTE: not autorized request!
                    self.wsRequest = [requestSender sendWSRequest: requestContent withDelegate: self];
                }
                
                [self startActivityIndicator];
            }
        }
    }
}

- (void)updatePlayerSelector {
    if (self.playerSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestPlayerCurrent) {
        self.playerIdTextField.enabled = NO;
        self.playerIdTextField.textColor = [UIColor darkGrayColor];
    }
    else if (self.playerSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestPlayerCustom) {
        self.playerIdTextField.enabled = YES;
        self.playerIdTextField.textColor = [UIColor darkTextColor];
    }
}

- (void)updateGameSelector {
    if (self.gameSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestGameCurrent) {
        self.gameIdTextField.enabled = NO;
        self.gameIdTextField.textColor = [UIColor darkGrayColor];
    }
    else if (self.gameSegmentedControl.selectedSegmentIndex == PPSExLeaderboardRequestGameCustom) {
        self.gameIdTextField.enabled = YES;
        self.gameIdTextField.textColor = [UIColor darkTextColor];
    }
}

- (void)fillCurrentPlayerId {
    self.playerIdTextField.text = [NSString stringWithFormat:@"%lld",[[MNDirect getSession]getMyUserId]];
}

- (void)fillCurrentGameId {
    self.gameIdTextField.text = [NSString stringWithFormat:@"%d",PPSExGameId];
}

#pragma mark - MNWSRequestDelegate

-(void) wsRequestDidSucceed:(MNWSResponse *) response {
    [self stopActivityIndicator];
    
    NSArray *leaderboard = [response getDataForBlock: self.wsRequestBlockName];
    NSMutableString *leaderboardString = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
    
    for (MNWSLeaderboardListItem* leaderboardItem in leaderboard) {
        if ([leaderboardString length] > 0) {
            [leaderboardString appendString:@"\n"];
        }
        
        [leaderboardString appendFormat:
         @"%d. %@ : %@",
         [leaderboardItem getOutUserPlace].intValue,
         [leaderboardItem getUserNickName],
         [leaderboardItem getOutHiScoreText]];
    }
    
    if ([leaderboardString length] == 0) {
        leaderboardString = [NSString stringWithString:PPSExLeaderboardEmpty];
    }

    self.infoViewController = [[[PPSExInfoPaneViewController alloc]initWithNibName:@"PPSExInfoPaneView" bundle:[NSBundle mainBundle]]autorelease];
    
    if (self.infoViewController != nil) {
        [self.infoViewController setHeaderTextSafe:PPSExLeaderboardRequestResultViewTitle];
        [self.infoViewController setBodyTextSafe:leaderboardString];
        
        self.infoViewController.title = PPSExLeaderboardRequestResultViewTitle;
        
        [self.navigationController pushViewController:self.infoViewController animated:YES];
    }
    
    self.wsRequestBlockName = nil;
    self.wsRequest          = nil;
}

-(void) wsRequestDidFailWithError:(MNWSRequestError *) error {
    [self stopActivityIndicator];
    
    PPSExShowWSRequestErrorAlert(error.message);
    
    self.wsRequestBlockName = nil;
    self.wsRequest          = nil;
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
