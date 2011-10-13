//
//  PPSExLeaderboardsListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 13.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNGameSettingsProvider.h"

#import "PPSExCommon.h"
#import "PPSExLeaderboardInfoViewController.h"

#import "PPSExLeaderboardsListViewController.h"

static NSString *PPSExLeaderboardsSectionNames[] = 
{
    @"",
};

@interface PPSExLeaderboardsListViewController()

@property (nonatomic,retain) NSArray *gameSettingList;

- (void)updateView;
@end

@implementation PPSExLeaderboardsListViewController

@synthesize gameSettingList = _gameSettingList;

- (void)viewDidLoad {
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExLeaderboardsSectionNames
                                                     count:DeclaredArraySize(PPSExLeaderboardsSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
    
    self.gameSettingList = nil;
    
    [[MNDirect gameSettingsProvider]addDelegate:self];
}

- (void)dealloc {
    [[MNDirect gameSettingsProvider] removeDelegate:self];
    self.gameSettingList = nil;
    
    [super dealloc];
}

- (void)updateState  {
    if ([[MNDirect gameSettingsProvider]isGameSettingListNeedUpdate]) {
        [[MNDirect gameSettingsProvider]doGameSettingListUpdate];
    }
    else {
        [self updateView];
    }
}

-(void) onGameSettingListUpdated {
    [self updateView];
}

- (void)updateView {
    self.gameSettingList = [[MNDirect gameSettingsProvider]getGameSettingList];
    

    NSMutableArray *tableViewRows = [NSMutableArray arrayWithCapacity:[self.gameSettingList count]];
    PPSExMainScreenRowTypeObject *rowObject = nil;
    
    for (MNGameSettingInfo *gameSetting in self.gameSettingList) {
        
        if (gameSetting.isLeaderboardVisible) {
            rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:gameSetting.name 
                                                                  subTitle:@""];
            
            if (rowObject != nil) {
                rowObject.viewControllerName = @"PPSExLeaderboardInfoViewController";
                rowObject.nibName = @"PPSExLeaderboardInfoView";
                [tableViewRows addObject:rowObject];
                
                [rowObject release];
                rowObject = nil;
            }
        }
    }
    
    self.sectionRows = [NSArray arrayWithObjects:tableViewRows,nil];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSString *itemName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    MNGameSettingInfo *selectedItem = nil;
    
    for (MNGameSettingInfo *gameSetting in self.gameSettingList) {
        if ([gameSetting.name isEqualToString:itemName]) {
            selectedItem = gameSetting;
            break;
        }
    }
    
    ((PPSExLeaderboardInfoViewController*)self.navigationController.topViewController).gameSetting = selectedItem;
}

@end
