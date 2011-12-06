//
//  PPSExLeaderboardsListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 13.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNGameSettingsProvider.h"

#import "PPSExCommon.h"
#import "PPSExLeaderboardInfoViewController.h"
#import "PPSExLeaderboardRequestViewController.h"

#import "PPSExLeaderboardsListViewController.h"

static NSString *PPSExLeaderboardsSectionNames[] = 
{
    @"Score Posting",
    @"Information extraction"
};

static PPSExMainScreenRowType PPSExLeaderboardsInformationExtractionRows[] = 
{
    { @"Game Leaderboard"  , @"", @"PPSExLeaderboardRequestViewController", @"PPSExLeaderboardRequestView" },
    { @"Player Leaderboard", @"", @"PPSExLeaderboardRequestViewController", @"PPSExLeaderboardRequestView" },
};

#define PPSExLeaderboardsScorePostSection             (0)
#define PPSExLeaderboardsInformationExtractionSection (1)

#define PPSExLeaderboardsInformationExtractionNeedPlayerConfigRowIndex (1)

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
        
        if (gameSetting.isLeaderboardVisible) {
            rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:gameSetting.name 
                                                                  subTitle:@""];
            
            if (rowObject != nil) {
                rowObject.viewControllerName = @"PPSExLeaderboardInfoViewController";
                rowObject.nibName            = @"PPSExLeaderboardInfoView";
                
                [tableViewRows addObject:rowObject];
                
                [rowObject release];
                rowObject = nil;
            }
        }
    }

    self.sectionRows = [NSArray arrayWithObjects:
                        tableViewRows,
                        [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExLeaderboardsInformationExtractionRows
                                                                     count:DeclaredArraySize(PPSExLeaderboardsInformationExtractionRows)],
                        nil];
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if ([indexPath indexAtPosition:0] == PPSExLeaderboardsScorePostSection) {
        NSString *itemName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        MNGameSettingInfo *selectedItem = nil;
        
        for (MNGameSettingInfo *gameSetting in self.gameSettingList) {
            if ([gameSetting.name isEqualToString:itemName]) {
                selectedItem = gameSetting;
                break;
            }
        }
        
        if ([self.navigationController.topViewController isKindOfClass:[PPSExLeaderboardInfoViewController class]]) {
            ((PPSExLeaderboardInfoViewController *)self.navigationController.topViewController).gameSetting = selectedItem;
        }
        else {
            NSLog(@"topViewController is not KindOfClass:PPSExLeaderboardInfoViewController");
        }
    }
    else if ([indexPath indexAtPosition:0] == PPSExLeaderboardsInformationExtractionSection) {
        NSInteger rowIndex = [indexPath indexAtPosition:1];
        
        if ([self.navigationController.topViewController isKindOfClass:[PPSExLeaderboardRequestViewController class]]) {
            ((PPSExLeaderboardRequestViewController *)self.navigationController.topViewController).showPlayerSelection =
            rowIndex == PPSExLeaderboardsInformationExtractionNeedPlayerConfigRowIndex;
        }
        else {
            NSLog(@"topViewController is not KindOfClass:PPSExLeaderboardRequestViewController");
        }
    }
    else {
        //assert
    }
}

#pragma mark - MNGameSettingsProviderDelegate

- (void)onGameSettingListUpdated {
    [self updateView];
}

@end
