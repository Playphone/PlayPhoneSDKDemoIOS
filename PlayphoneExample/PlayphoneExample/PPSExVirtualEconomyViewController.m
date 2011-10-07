//
//  PPSExVirtualEconomyViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PPSExCommon.h"
#import "PPSExVirtualEconomyViewController.h"


static NSString *PPSExVEconomyScreenSectionNames[] = 
{
    @"",
};

static PPSExMainScreenRowType PPSExVEconomyScreenRows[] = 
{
    { @"vItems"         , @"These are the items used in game"                    , @"", @"" },
    { @"PlayPhone Store", @"User can purchase these items on the PlayPhone Store", @"", @"" },
    { @"User Inventory" , @"Inventory can be tracked per user"                   , @"", @"" },
};


@implementation PPSExVirtualEconomyViewController

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
