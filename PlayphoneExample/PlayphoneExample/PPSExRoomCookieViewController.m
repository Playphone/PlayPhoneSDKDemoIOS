//
//  PPSExRoomCookieViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 24.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExCommon.h"
#import "PPSExRoomCookieViewController.h"


static NSString *PPSExVEStoreScreenSectionNames[] = 
{
    @"",
};

static PPSExMainScreenRowType PPSExVEStoreScreenRows[] = 
{
    { @"Current room", @"", @"PPSExCurrentRoomCookieViewController", @"PPSExCurrentRoomCookieView" },
    { @"Any room"    , @"", @"PPSExAnyRoomCookieViewController"    , @"PPSExAnyRoomCookieView"     },
};


@implementation PPSExRoomCookieViewController

- (void)viewDidLoad {
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
