//
//  PPSExVEVItemListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNVItemsProvider.h"
#import "PPSExCommon.h"

#import "PPSExVEVItemInfoViewController.h"
#import "PPSExVEVItemListViewController.h"

static NSString *PPSExVEVItemListScreenSectionNames[] = 
{
    @"",
};


@interface PPSExVEVItemListViewController()
@property (nonatomic,retain) NSArray *gameVItemsList;

- (void)updateView;

@end


@implementation PPSExVEVItemListViewController

@synthesize gameVItemsList  = _gameVItemsList;
@synthesize showVCurrencies = _showVCurrencies;

- (void)viewDidLoad {
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVEVItemListScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVEVItemListScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;

    _gameVItemsList  = nil;
    _showVCurrencies = NO;

    [super viewDidLoad];
    
    [[MNDirect vItemsProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [[MNDirect vItemsProvider] removeDelegate:self];

    [super viewDidUnload];
}

- (void)dealloc {
    [[MNDirect vItemsProvider] removeDelegate:self];
    
    self.gameVItemsList = nil;
    
    [super dealloc];
}

- (void)setShowVCurrencies:(BOOL)showVCurrencies {
    _showVCurrencies = showVCurrencies;
    [self updateState];
}

- (void)updateState  {
    if ([[MNDirect vItemsProvider]isGameVItemsListNeedUpdate]) {
        [[MNDirect vItemsProvider]doGameVItemsListUpdate];
    }
    else {
        [self updateView];
    }
}

- (void)onVItemsListUpdated {
    [self updateView];
}

- (void)updateView {
    self.gameVItemsList = [[MNDirect vItemsProvider]getGameVItemsList];
    
    NSMutableArray *tableViewRows = [NSMutableArray arrayWithCapacity:[self.gameVItemsList count]];
    PPSExMainScreenRowTypeObject *rowObject = nil;
    
    for (MNGameVItemInfo *itemInfo in self.gameVItemsList) {
        
        if (self.showVCurrencies) {
            if (itemInfo.model & MNVItemIsCurrencyMask) {
                rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:itemInfo.name 
                                                                      subTitle:[NSString stringWithFormat:@"Id: %d",itemInfo.vItemId]];
            }
        }
        else {
            if (!(itemInfo.model & MNVItemIsCurrencyMask)) {
                rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:itemInfo.name 
                                                                      subTitle:[NSString stringWithFormat:@"Id: %d",itemInfo.vItemId]];
            }
        }
        
        if (rowObject != nil) {
            rowObject.viewControllerName = @"PPSExVEVItemInfoViewController";
            rowObject.nibName            = @"PPSExVEVItemInfoView";
            
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
    MNGameVItemInfo *selectedItem = nil;
    
    for (MNGameVItemInfo *itemInfo in self.gameVItemsList) {
        if ([itemInfo.name isEqualToString:itemName]) {
            selectedItem = itemInfo;
            break;
        }
    }
    
    ((PPSExVEVItemInfoViewController *)self.navigationController.topViewController).vItemInfo = selectedItem;
}

@end
