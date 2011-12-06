//
//  RootViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 05.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirectButton.h"
#import "MNDirectPopup.h"

#import "PPSExCommon.h"
#import "PPSExBasicViewController.h"
#import "PPSExMultiplayerViewController.h"
#import "PlayphoneExampleAppDelegate.h"

#import "RootViewController.h"

#pragma mark - Defines

static NSString *PPSExMainScreenSectionNames[] = 
{
    @"Required Integration",
    @"Advanced Features"   ,
    @"System Information"
};

static PPSExMainScreenRowType PPSExMainScreenSection1Rows[] = 
{
    { @"Login User"           , @"", @"PPSExLoginUserViewController"         , @"PPSExLoginUserView"   },
    { @"Dashboard"            , @"", @"PPSExDashboardViewController"         , @"PPSExDashboardView"   },
    { @"Virtual Economy"      , @"", @"PPSExVEViewController"                , @"PPSExBasicTableView"  }
};

static PPSExMainScreenRowType PPSExMainScreenSection2Rows[] = 
{
    { @"Current User Info"    , @"", @"PPSExUserInfoViewController"          , @"PPSExUserInfoView"    },
    { @"Leaderboards"         , @"", @"PPSExLeaderboardsListViewController"  , @"PPSExBasicTableView"  },
    { @"Achievements"         , @"", @"PPSExAchievementsViewController"      , @"PPSExBasicTableView"  },
    { @"Social Graph"         , @"", @"PPSExSocialGraphViewController"       , @"PPSExBasicTableView"  },
    { @"Dashboard Control"    , @"", @"PPSExDashboardCtlViewController"      , @"PPSExBasicTableView"  },
    { @"Cloud Storage"        , @"", @"PPSExCloudStorageViewController"      , @"PPSExCloudStorageView"},
    { @"Game Settings"        , @"", @"PPSExGameSetListViewController"       , @"PPSExBasicTableView"  },
    { @"Room Cookies"         , @"", @"PPSExRoomCookieViewController"        , @"PPSExBasicTableView"  },
    { @"Multiplayer Basics"   , @"", @"PPSExMultiplayerViewController"       , @"PPSExMultiplayerView" },
    { @"Server Info"          , @"", @"PPSExServerInfoViewController"        , @"PPSExServerInfoView"  },
};

static PPSExMainScreenRowType PPSExMainScreenSection3Rows[] = 
{
    { @"Application Info"     , @"", @"PPSExAppInfoViewController"          , @"PPSExAppInfoView"      }
};


#define PPSExMultiplayerRowIndex (8)

@interface RootViewController()

@property (nonatomic,retain) id<PPSExBasicNotificationProtocol> basicNotificationDelegate;

@end


@implementation RootViewController

@synthesize basicNotificationDelegate = _basicNotificationDelegate;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad {
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExMainScreenSectionNames
                                                     count:DeclaredArraySize(PPSExMainScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExMainScreenSection1Rows 
                                                                               count:DeclaredArraySize(PPSExMainScreenSection1Rows)],
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExMainScreenSection2Rows 
                                                                               count:DeclaredArraySize(PPSExMainScreenSection2Rows)],
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExMainScreenSection3Rows
                                                                               count:DeclaredArraySize(PPSExMainScreenSection3Rows)],
                                  nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];

    self.title = @"PlayPhone SDK Demo";
    
    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (YES);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if ([viewController conformsToProtocol:@protocol(PPSExBasicNotificationProtocol)]) {
        self.basicNotificationDelegate = (PPSExBasicViewController *)viewController;
    }
    else {
        self.basicNotificationDelegate = nil;
    }
}

#pragma mark - MNDirectDelegate

- (void)mnDirectSessionReady:(MNSession *)session {
    PPSExAppDelegate.sessionReady = YES;
    
    // Call scoreProgerssView's sessionReady if topViewController is PPSExMultiplayerViewController
    if ([self.navigationController.topViewController isKindOfClass:[PPSExMultiplayerViewController class]]) {
        [((PPSExMultiplayerViewController *)self.navigationController.topViewController).scoreProgressView sessionReady];
    }
}

- (void)mnDirectSessionStatusChangedTo:(NSUInteger) newStatus {
    if (((mnDirectCurStatus == MN_OFFLINE) || (mnDirectCurStatus == MN_CONNECTING)) && 
        (newStatus == MN_LOGGEDIN)) {
        //Player just logged in
        [self.basicNotificationDelegate playerLoggedIn];
    }
    
    if (((mnDirectCurStatus != MN_OFFLINE) && (mnDirectCurStatus != MN_CONNECTING)) && 
        ((newStatus == MN_OFFLINE) || (newStatus == MN_CONNECTING))) {
        //Player just logged out
        [self.basicNotificationDelegate playerLoggedOut];
    }
    
    mnDirectCurStatus = newStatus;
}

- (void)mnDirectDoStartGameWithParams:(MNGameParams *)params {
    MARK;

    if (![self.navigationController.topViewController isKindOfClass:[PPSExMultiplayerViewController class]]) {
        PPSExMainScreenRowType multiplayerRow = PPSExMainScreenSection2Rows[PPSExMultiplayerRowIndex];
        
        PPSExMultiplayerViewController *viewController = [[NSClassFromString(multiplayerRow.viewControllerName) alloc] initWithNibName:multiplayerRow.nibName
                                                                                                                                bundle:[NSBundle mainBundle]];
        if (viewController != nil) {
            viewController.title = multiplayerRow.rowTitle;
            
            [self.navigationController pushViewController:viewController animated:YES];
            
            [viewController release];
        }
    }
}

- (void)mnDirectDoCancelGame {
    MARK;
}

- (void)mnDirectDoFinishGame {
    MARK;
}

@end
