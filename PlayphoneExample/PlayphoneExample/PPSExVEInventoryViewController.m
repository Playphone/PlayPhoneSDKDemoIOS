//
//  PPSExVEInventoryViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 10.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExCommon.h"
#import "PPSExVEInventoryViewController.h"

static NSString *PPSExVEInventoryScreenSectionNames[] = 
{
    @"",
};

static PPSExMainScreenRowType PPSExVEInventoryScreenRows[] = 
{
    { @"Inventory List"  , @"", @"PPSExVEInventoryListViewController"  , @"PPSExBasicTableView"        },
    { @"Manage inventory", @"", @"PPSExVEManageInventoryViewController", @"PPSExVEManageInventoryView" },
};


@implementation PPSExVEInventoryViewController

- (void)viewDidLoad {
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVEInventoryScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVEInventoryScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExVEInventoryScreenRows 
                                                                               count:DeclaredArraySize(PPSExVEInventoryScreenRows)],
                                  nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
}

@end
