//
//  PPSExVEStoreViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 08.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PPSExCommon.h"
#import "PPSExVEStoreViewController.h"


static NSString *PPSExVEStoreScreenSectionNames[] = 
{
    @"",
};

static PPSExMainScreenRowType PPSExVEStoreScreenRows[] = 
{
    { @"vShop Categories List", @"", @"PPSExVECategoryListViewController", @"PPSExBasicTableView" },
    { @"vShop Packs List"     , @"", @"PPSExVEPackListViewController"    , @"PPSExBasicTableView" },
    { @"Buy vShop Packs"      , @"", @"", @"" },
};

@implementation PPSExVEStoreViewController

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
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVEStoreScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVEStoreScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExVEStoreScreenRows 
                                                                               count:DeclaredArraySize(PPSExVEStoreScreenRows)],
                                  nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
}

@end
