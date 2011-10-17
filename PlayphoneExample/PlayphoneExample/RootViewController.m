//
//  RootViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 05.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirectButton.h"
#import "MNDirectPopup.h"

#import "PPSExCommon.h"
#import "PPSExBasicViewController.h"

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
//    { @"Multiplayer Basics"   , @"", @"" , @""}
};

static PPSExMainScreenRowType PPSExMainScreenSection3Rows[] = 
{
    { @"Application Info"     , @"", @"PPSExAppInfoViewController"          , @"PPSExAppInfoView"      }
};

@interface RootViewController()

@property (nonatomic,retain) id<PPSExBasicNotificationProtocol> basicNotificationDelegate;

@end

@implementation RootViewController

@synthesize basicNotificationDelegate;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
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
    
    [MNDirect prepareSessionWithGameId:10900
                            gameSecret:[MNDirect makeGameSecretByComponents:PPSExGameSecret1
                                                                    secret2:PPSExGameSecret2
                                                                    secret3:PPSExGameSecret3
                                                                    secret4:PPSExGameSecret4]
                           andDelegate:self];
    
    
    [MNDirectButton initWithLocation:MNDIRECTBUTTON_TOPRIGHT];
    [MNDirectButton show];
    
    [MNDirectPopup init:MNDIRECTPOPUP_WELCOME | MNDIRECTPOPUP_ACHIEVEMENTS | MNDIRECTPOPUP_NEW_HI_SCORES];
    
    self.title = @"PlayPhone SDK Demo";
    
    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (YES);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if ([viewController conformsToProtocol:@protocol(PPSExBasicNotificationProtocol)]) {
        self.basicNotificationDelegate = (PPSExBasicViewController*)viewController;
    }
    else {
        self.basicNotificationDelegate = nil;
    }
}

#pragma mark - MNDirectDelegate

-(void) mnDirectSessionStatusChangedTo:(NSUInteger) newStatus {
    
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

@end
