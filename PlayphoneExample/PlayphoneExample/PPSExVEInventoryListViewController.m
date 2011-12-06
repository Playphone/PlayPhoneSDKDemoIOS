//
//  PPSExVEInventoryListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 10.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"

#import "PPSExCommon.h"
#import "PPSExVEInventoryListViewController.h"

static NSString *PPSExVEInventoryListScreenSectionNames[] = 
{
    @"Curencies",
    @"Items"
};


@interface PPSExVEInventoryListViewController()
- (void)updateView;

- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;

@end


@implementation PPSExVEInventoryListViewController

- (void)viewDidLoad {
    self.sectionNames = [NSArray arrayWithObjects:PPSExVEInventoryListScreenSectionNames
                                            count:DeclaredArraySize(PPSExVEInventoryListScreenSectionNames)];
    
    self.sectionRows  = [NSArray arrayWithObjects:nil];
    
    [super viewDidLoad];
    
    [[MNDirect vItemsProvider]addDelegate:self];

    self.cellStyle = UITableViewCellStyleValue1;
}

- (void)viewDidUnload {
    [[MNDirect vItemsProvider]removeDelegate:self];

    [super viewDidUnload];
}

- (void)dealloc {
    [[MNDirect vItemsProvider]removeDelegate:self];

    [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType  = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];

        if ([[MNDirect vItemsProvider]isGameVItemsListNeedUpdate]) {
            [[MNDirect vItemsProvider]doGameVItemsListUpdate];
        }
        else {
            [self updateView];
        }
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)updateView {
    NSArray *playerVItemsList = [[MNDirect vItemsProvider]getPlayerVItemList];
    
    MNGameVItemInfo *itemInfo   = nil;
    NSString        *itemTitle  = nil;
    NSString        *itemAmount = nil;
    
    PPSExMainScreenRowTypeObject *rowObject = nil;
    
    NSMutableArray *itemsRows      = [NSMutableArray arrayWithCapacity:[playerVItemsList count]];
    NSMutableArray *currenciesRows = [NSMutableArray arrayWithCapacity:[playerVItemsList count]];
    
    for (MNPlayerVItemInfo *playerItemInfo in playerVItemsList) {
        itemInfo = [[MNDirect vItemsProvider]findGameVItemById:playerItemInfo.vItemId];
        itemTitle = [NSString stringWithFormat:@"%@ (Id: %d)",itemInfo.name,itemInfo.vItemId];
        itemAmount = [NSString stringWithFormat:@"%lld",playerItemInfo.count];
        
        rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:itemTitle subTitle:itemAmount];

        if (itemInfo.model & MNVItemIsCurrencyMask) {
            [currenciesRows addObject:rowObject];
        }
        else {
            [itemsRows addObject:rowObject];
        }
        
        [rowObject release];
    }
    
    self.sectionRows = [NSArray arrayWithObjects:currenciesRows,itemsRows, nil];

    [self.tableView reloadData];
}

- (void)switchToLoggedInState {
    [self showFooterLabelWithText:@""];

    self.sectionNames = [NSArray arrayWithObjects:PPSExVEInventoryListScreenSectionNames
                                            count:DeclaredArraySize(PPSExVEInventoryListScreenSectionNames)];

    [self.tableView reloadData];
}
- (void)switchToNotLoggedInState {
    [self showFooterLabelWithText:PPSExUserNotLoggedInString];

    self.sectionNames = [NSArray arrayWithObjects:nil];
    self.sectionRows  = [NSArray arrayWithObjects:nil];
    
    [self.tableView reloadData];
}

#pragma mark - MNVItemsProviderDelegate

-(void) onVItemsListUpdated {
    [self updateView];
}

#pragma mark - PPSExBasicNotificationProtocol
- (void)playerLoggedIn {
    [self updateState];
}
- (void)playerLoggedOut {
    //[self updateState];
    [self switchToNotLoggedInState];
}

@end
