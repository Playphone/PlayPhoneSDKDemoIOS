//
//  PPSExVEInventoryListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 10.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
@end

@implementation PPSExVEInventoryListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVEInventoryListScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVEInventoryListScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
    
    [[MNDirect vItemsProvider]addDelegate:self];

    self.cellStyle = UITableViewCellStyleValue1;
}

- (void)viewDidUnload {
    [[MNDirect vItemsProvider]removeDelegate:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType  = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)updateState {
    if ([[MNDirect vItemsProvider]isGameVItemsListNeedUpdate]) {
        [[MNDirect vItemsProvider]doGameVItemsListUpdate];
    }
    else {
        [self updateView];
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

#pragma mark - MNVItemsProviderDelegate

-(void) onVItemsListUpdated {
    [self updateView];
}

#pragma mark - PPSExBasicNotificationProtocol
- (void)playerLoggedIn {
    [self updateState];
}
- (void)playerLoggedOut {
    self.sectionRows = [NSArray arrayWithObjects: nil];
    
    [self.tableView reloadData];
}

@end
