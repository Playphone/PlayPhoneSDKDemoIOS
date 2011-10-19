//
//  PPSExAchievementsViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExCommon.h"
#import "PPSExAchievementsViewController.h"

static NSString *PPSExAchievementsSectionNames[] = 
{
    @""
};

static PPSExMainScreenRowType PPSExAchievementsRows[] = 
{
    { @"Achievements List" , @"", @"PPSExAchListViewController"         , @"PPSExBasicTableView"       },
    { @"User Achievemens"  , @"", @"PPSExUserAchievementsViewController", @"PPSExUserAchievementsView" }
};

@implementation PPSExAchievementsViewController

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
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExAchievementsSectionNames
                                                     count:DeclaredArraySize(PPSExAchievementsSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:
                                  [PPSExMainScreenRowTypeObject getArrayOfNativeRows:PPSExAchievementsRows 
                                                                               count:DeclaredArraySize(PPSExAchievementsRows)],
                                  nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
}


@end
