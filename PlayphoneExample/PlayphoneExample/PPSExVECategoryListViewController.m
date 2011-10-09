//
//  PPSExVECategoryListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 08.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVECategoriesScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVECategoriesScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
    
    self.tableView.userInteractionEnabled = NO;
    [[MNDirect vItemsProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [[MNDirect vItemsProvider] removeDelegate:self];
    
    [super viewDidUnload];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
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
