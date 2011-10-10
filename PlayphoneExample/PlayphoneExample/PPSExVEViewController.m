//
//  PPSExVEViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PPSExCommon.h"
#import "PPSExVEViewController.h"


static NSString *PPSExVEconomyScreenSectionNames[] = 
{
    @"",
};

static PPSExMainScreenRowType PPSExVEconomyScreenRows[] = 
{
    { @"vItems"         , @"These are the items used in game"                    , @"PPSExVEVItemViewController"    , @"PPSExBasicTableView" },
    { @"PlayPhone Store", @"User can purchase these items on the PlayPhone Store", @"PPSExVEStoreViewController"    , @"PPSExBasicTableView" },
    { @"User Inventory" , @"Inventory can be tracked per user"                   , @"PPSExVEInventoryViewController", @"PPSExBasicTableView" },
};


@implementation PPSExVEViewController

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
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVEconomyScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVEconomyScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExVEconomyScreenRows 
                                                                               count:DeclaredArraySize(PPSExVEconomyScreenRows)],
                                  nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
}

@end
