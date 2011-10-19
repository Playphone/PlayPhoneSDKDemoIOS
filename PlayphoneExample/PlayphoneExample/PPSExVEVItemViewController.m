//
//  PPSExVEVItemViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExCommon.h"
#import "PPSExVEVItemListViewController.h"
#import "PPSExVEVItemViewController.h"

static NSString *PPSExVEVItemScreenSectionNames[] = 
{
    @"",
};

static PPSExMainScreenRowType PPSExVEVItemScreenRows[] = 
{
    { @"Get Virtual Items"      , @"", @"PPSExVEVItemListViewController", @"PPSExBasicTableView" },
    { @"Get Virtual Currencires", @"", @"PPSExVEVItemListViewController", @"PPSExBasicTableView" },
};

@implementation PPSExVEVItemViewController

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
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVEVItemScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVEVItemScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExVEVItemScreenRows 
                                                                               count:DeclaredArraySize(PPSExVEVItemScreenRows)],
                                  nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if      ([indexPath indexAtPosition:1] == 0) {
        ((PPSExVEVItemListViewController*)self.navigationController.topViewController).showVCurrencies = NO;
    }
    else if ([indexPath indexAtPosition:1] == 1) {
        ((PPSExVEVItemListViewController*)self.navigationController.topViewController).showVCurrencies = YES;
    }
    else {
    }
}

@end
