//
//  PPSExVEVItemListViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNVItemsProvider.h"
#import "PPSExBasicViewController.h"

@interface PPSExVEVItemListViewController : PPSExBasicTableViewController <MNVItemsProviderDelegate>
{
    NSArray *_gameVItemsList;
    BOOL     _showVCurrencies;
}

@property (nonatomic, assign) BOOL showVCurrencies;

@end
