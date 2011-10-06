//
//  RootViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 05.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirectButton.h"

#import "PPSExBasicViewController.h"

#import "RootViewController.h"

#pragma mark - Defines

#define DeclaredArraySize(Array) ((int)(sizeof(Array) / sizeof(Array[0])))

static NSString *PPSExMainScreenSectionNames[] = 
{
    @"Required Integration",
    @"Advanced Features"
};

typedef struct
{
    NSString *rowName;
    NSString *viewControllerName;
    NSString *nibName;
} PPSExMainScreenRowType;

static PPSExMainScreenRowType PPSExMainScreenSection1Rows[] = 
{
    { @"Login User"           , @"PPSExLoginUserViewController"         , @"PPSExLoginUserView"},
    { @"Dashboard"            , @"PPSExDashboardViewController"         , @""},
    { @"Virtual Economy"      , @"PPSExVirtualEconomyViewController"    , @""}
};

static PPSExMainScreenRowType PPSExMainScreenSection2Rows[] = 
{
    { @"Current User Info"    , @"PPSExCurrentUserInfoViewController"   , @""},
    { @"Leaderboards"         , @"PPSExLeaderboardsViewController"      , @""},
    { @"Achievements"         , @"PPSExAchievementsViewController"      , @""},
    { @"Social Graph"         , @"PPSExSocialGraphViewController"       , @""},
    { @"Dashboard Control"    , @"PPSExDashboardControlViewController"  , @""},
    { @"Cloud Storage"        , @"PPSExCloudStorageViewController"      , @""},
    { @"Multiplayer Basics"   , @"PPSExMultiplayerBasicsViewController" , @""}
};


#define PPSExGameId      (10900)
#define PPSExGameSecret1 (0xae2b10f2)
#define PPSExGameSecret2 (0x248f58d9)
#define PPSExGameSecret3 (0xc9654f24)
#define PPSExGameSecret4 (0x37960337)

@interface RootViewController()

@property (nonatomic,retain) id<PPSExBasicNotificationProtocol> basicNotificationDelegate;

@end

@implementation RootViewController

@synthesize basicNotificationDelegate;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MNDirect prepareSessionWithGameId:10900
                            gameSecret:[MNDirect makeGameSecretByComponents:PPSExGameSecret1
                                                                    secret2:PPSExGameSecret2
                                                                    secret3:PPSExGameSecret3
                                                                    secret4:PPSExGameSecret4]
                           andDelegate:self];
    
    
    [MNDirectButton initWithLocation:MNDIRECTBUTTON_TOPRIGHT];
    [MNDirectButton show];
    
    self.title = @"PlayPhone SDK Demo";
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
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

#pragma mark - UITableViewDataSource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sections = DeclaredArraySize(PPSExMainScreenSectionNames);
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return DeclaredArraySize(PPSExMainScreenSection1Rows);
    }
    else if (section == 1) {
        return DeclaredArraySize(PPSExMainScreenSection2Rows);
    }

    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    int sectionIndex = [indexPath indexAtPosition:0];
    int rowIndex     = [indexPath indexAtPosition:1];
    
    if      (sectionIndex == 0) {
        cell.textLabel.text = PPSExMainScreenSection1Rows[rowIndex].rowName;
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        cell.textLabel.text = PPSExMainScreenSection2Rows[rowIndex].rowName;
    }
    else {
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return PPSExMainScreenSectionNames[section];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath");

    int sectionIndex = [indexPath indexAtPosition:0];
    int rowIndex     = [indexPath indexAtPosition:1];
    
    NSString *viewControllerName = nil;
    NSString *nibName            = nil;
    
    
    if      (sectionIndex == 0) {
        viewControllerName = PPSExMainScreenSection1Rows[rowIndex].viewControllerName;
        nibName            = PPSExMainScreenSection1Rows[rowIndex].nibName;
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        viewControllerName = PPSExMainScreenSection2Rows[rowIndex].viewControllerName;
        nibName            = PPSExMainScreenSection2Rows[rowIndex].nibName;
    }
    else {
    }

    if (viewControllerName != nil) {
        PPSExBasicViewController *viewController = [[NSClassFromString(viewControllerName) alloc] initWithNibName:nibName
                                                                                                   bundle:[NSBundle mainBundle]];
        
        if (viewController == nil) {
            NSLog(@"Can not create view controller with name: [%@] and nibName: [%@]",viewControllerName,nibName);
        }
        else {
            [self.navigationController pushViewController:viewController animated:YES];
            
            self.basicNotificationDelegate = viewController;
            
            [viewController release];
        }
    }
}

#pragma mark - MNDirectDelegate

-(void) mnDirectSessionStatusChangedTo:(NSUInteger) newStatus {
    
    if (((mnDirectCurStatus == MN_OFFLINE) || (mnDirectCurStatus == MN_CONNECTING)) && 
        (newStatus == MN_LOGGEDIN)) {
        //Player just logged in
        [basicNotificationDelegate playerLoggedIn];
    }
    
    if (((mnDirectCurStatus != MN_OFFLINE) && (mnDirectCurStatus != MN_CONNECTING)) && 
        ((newStatus == MN_OFFLINE) || (newStatus == MN_CONNECTING))) {
        //Player just logged out
        [basicNotificationDelegate playerLoggedOut];
    }
    
    mnDirectCurStatus = newStatus;
}

@end
