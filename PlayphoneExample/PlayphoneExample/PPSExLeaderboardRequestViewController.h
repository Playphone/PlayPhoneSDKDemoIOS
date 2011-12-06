//
//  PPSExLeaderboardRequestViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 02.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "MNWSRequest.h"

#import "PPSExInfoPaneViewController.h"
#import "PPSExBasicViewController.h"

@interface PPSExLeaderboardRequestViewController : PPSExBasicViewController <MNWSRequestDelegate> {
    BOOL                _showPlayerSelection;
    NSString           *_wsRequestBlockName;
    MNWSRequest        *_wsRequest;

    UITextField        *_playerIdTextField;
    UITextField        *_gameIdTextField;
    UISegmentedControl *_playerSegmentedControl;
    UISegmentedControl *_gameSegmentedControl;
    UISegmentedControl *_periodSegmentedControl;
    UIView             *_playerView;
    UIView             *_gameView;
    
    PPSExInfoPaneViewController *_infoViewController;
}

@property (assign, nonatomic) BOOL                         showPlayerSelection;

@property (retain, nonatomic) IBOutlet UITextField        *playerIdTextField;
@property (retain, nonatomic) IBOutlet UITextField        *gameIdTextField;
@property (retain, nonatomic) IBOutlet UITextField        *gameSetIdTextField;
@property (retain, nonatomic) IBOutlet UISegmentedControl *playerSegmentedControl;
@property (retain, nonatomic) IBOutlet UISegmentedControl *gameSegmentedControl;
@property (retain, nonatomic) IBOutlet UISegmentedControl *periodSegmentedControl;
@property (retain, nonatomic) IBOutlet UIView             *playerView;
@property (retain, nonatomic) IBOutlet UIView             *gameView;

- (IBAction)playerChanged:(id)sender;
- (IBAction)gameChanged  :(id)sender;
- (IBAction)periodChanged:(id)sender;
- (IBAction)doSendRequest:(id)sender;

@end
