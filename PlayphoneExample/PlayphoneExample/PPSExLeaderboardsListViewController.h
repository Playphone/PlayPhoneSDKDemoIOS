//
//  PPSExLeaderboardsListViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 13.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNGameSettingsProvider.h"
#import "PPSExBasicViewController.h"

@interface PPSExLeaderboardsListViewController : PPSExBasicTableViewController <MNGameSettingsProviderDelegate> {
    NSArray *_gameSettingList;
}

@end
