//
//  PPSExAchListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNAchievementsProvider.h"

#import "PPSExCommon.h"
#import "PPSExVEPackInfoViewController.h"
#import "PPSExAchInfoViewController.h"

#import "PPSExAchListViewController.h"

static NSString *PPSExAchListSectionNames[] = 
{
    @"",
};

@interface PPSExAchListViewController()
- (void)updateView;
@end

@implementation PPSExAchListViewController

- (void)viewDidLoad
{
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExAchListSectionNames
                                                     count:DeclaredArraySize(PPSExAchListSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    // Set the back button text to "Back"
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"Back";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];
    
    [super viewDidLoad];
    
    self.cellStyle = UITableViewCellStyleValue1;
    [[MNDirect achievementsProvider]addDelegate:self];
}

- (void)dealloc {
    [[MNDirect achievementsProvider] removeDelegate:self];
    [super dealloc];
}

- (void)updateState  {
    if ([[MNDirect achievementsProvider]isGameAchievementListNeedUpdate]) {
        [[MNDirect achievementsProvider]doGameAchievementListUpdate];
    }
    else {
        [self updateView];
    }
}

- (void)updateView {
    NSArray *achList = [[MNDirect achievementsProvider]getGameAchievementList];
    
    NSMutableArray *tableViewRows = [NSMutableArray arrayWithCapacity:[achList count]];
    
    PPSExMainScreenRowTypeObject *rowObject = nil;
    
    for (MNGameAchievementInfo *achInfo in achList) {                             
        rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:achInfo.name
                                                              subTitle:[NSString stringWithFormat:@"Id: %d",achInfo.achievementId]];
        rowObject.viewControllerName = @"PPSExAchInfoViewController";
        rowObject.nibName = @"PPSExAchInfoView";
        
        [tableViewRows addObject:rowObject];
        
        [rowObject release];
        rowObject = nil;
    }
    
    self.sectionRows = [NSArray arrayWithObjects:tableViewRows,nil];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSArray *achList = [[MNDirect achievementsProvider]getGameAchievementList];
    
    NSString *itemName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    MNGameAchievementInfo *selectedItem = nil;
    
    for (MNGameAchievementInfo *achInfo in achList) {
        if ([achInfo.name isEqualToString:itemName]) {
            selectedItem = achInfo;
            break;
        }
    }
    
    ((PPSExAchInfoViewController*)self.navigationController.topViewController).achievementInfo = selectedItem;
}

#pragma mark - MNAchievementsProviderDelegate

-(void) onGameAchievementListUpdated {
    [self updateView];    
}

@end
