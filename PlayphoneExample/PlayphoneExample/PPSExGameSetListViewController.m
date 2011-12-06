//
//  PPSExGameSetListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 21.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNGameSettingsProvider.h"

#import "PPSExCommon.h"
#import "PPSExGameSetInfoViewController.h"

#import "PPSExGameSetListViewController.h"

static NSString *PPSExLeaderboardsSectionNames[] = 
{
    @"",
};


@interface PPSExGameSetListViewController()
@property (nonatomic,retain) NSArray *gameSettingList;

- (void)updateView;

@end


@implementation PPSExGameSetListViewController

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

- (void)viewDidUnload {
    [[MNDirect gameSettingsProvider] removeDelegate:self];

    [super viewDidUnload];
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

- (void)updateView {
    self.gameSettingList = [[MNDirect gameSettingsProvider]getGameSettingList];
    
    NSMutableArray *tableViewRows = [NSMutableArray arrayWithCapacity:[self.gameSettingList count]];
    PPSExMainScreenRowTypeObject *rowObject = nil;
    
    for (MNGameSettingInfo *gameSetting in self.gameSettingList) {
        
        rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:gameSetting.name 
                                                              subTitle:@""];
        
        if (rowObject != nil) {
            rowObject.viewControllerName = @"PPSExGameSetInfoViewController";
            rowObject.nibName            = @"PPSExGameSetInfoView";
            
            [tableViewRows addObject:rowObject];
            
            [rowObject release];
            rowObject = nil;
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
    
    ((PPSExGameSetInfoViewController *)self.navigationController.topViewController).gameSetting = selectedItem;
}

#pragma mark - MNGameSettingsProviderDelegate

- (void)onGameSettingListUpdated {
    [self updateView];
}

@end
