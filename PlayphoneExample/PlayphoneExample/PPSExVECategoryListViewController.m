//
//  PPSExVECategoryListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 08.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNVShopProvider.h"

#import "PPSExCommon.h"
#import "PPSExVECategoryListViewController.h"

static NSString *PPSExVECategoriesScreenSectionNames[] = 
{
    @"",
};


@interface PPSExVECategoryListViewController()
- (void)updateView;
@end


@implementation PPSExVECategoryListViewController

- (void)viewDidLoad {
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVECategoriesScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVECategoriesScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
    
    [[MNDirect vItemsProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [[MNDirect vItemsProvider] removeDelegate:self];

    [super viewDidUnload];
}

- (void)dealloc {
    [[MNDirect vItemsProvider] removeDelegate:self];

    [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType  = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


-(void) onVShopInfoUpdated {
    [self updateView];    
}

- (void)updateState {
    if ([[MNDirect vShopProvider]isVShopInfoNeedUpdate]) {
        [[MNDirect vShopProvider]doVShopInfoUpdate];
    }
    else {
        [self updateView];
    }
}

- (void)updateView {
    NSArray *categoryList = [[MNDirect vShopProvider]getVShopCategoryList];
    
    NSMutableArray *tableViewRows = [NSMutableArray arrayWithCapacity:[categoryList count]];

    PPSExMainScreenRowTypeObject *rowObject = nil;
    
    for (MNVShopCategoryInfo *categoryInfo in categoryList) {
        
        rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:categoryInfo.name 
                                                              subTitle:[NSString stringWithFormat:@"Id: %d",categoryInfo.categoryId]];
        [tableViewRows addObject:rowObject];
        
        [rowObject release];
        rowObject = nil;
    }
    
    self.sectionRows = [NSArray arrayWithObjects:tableViewRows,nil];
    [self.tableView reloadData];
}

@end
