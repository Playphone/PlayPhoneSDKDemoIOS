//
//  PPSExDashboardCtlViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNDirectUIHelper.h"

#import "PPSExCommon.h"
#import "PPSExDashboardCtlViewController.h"


static NSString *PPSExDashboardCtlSectionNames[] = 
{
    @"",
};

static PPSExMainScreenRowType PPSExDashboardCtlRows[] = 
{
    { @"Leaderboards", @"jumpToLeaderboard" , @"", @"" },
    { @"Friends list", @"jumpToBuddyList"   , @"", @"" },
    { @"User Profile", @"jumpToUserProfile" , @"", @"" },
    { @"User Home"   , @"jumpToUserHome"    , @"", @"" },
    { @"Achievements", @"jumpToAchievements", @"", @"" },
};


@implementation PPSExDashboardCtlViewController

- (void)viewDidLoad {
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExDashboardCtlSectionNames
                                                     count:DeclaredArraySize(PPSExDashboardCtlSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExDashboardCtlRows 
                                                                               count:DeclaredArraySize(PPSExDashboardCtlRows)],
                                  nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType  = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *applicationCommand = selectedCell.detailTextLabel.text;
    [MNDirect execAppCommand:applicationCommand withParam:nil];
    [MNDirectUIHelper showDashboard];
    
    [selectedCell setSelected:NO animated:YES];
}

@end
