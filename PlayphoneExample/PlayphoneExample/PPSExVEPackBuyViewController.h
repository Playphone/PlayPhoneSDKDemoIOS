//
//  PPSExVEPackBuyViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 09.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//
#import "MNVShopProvider.h"

#import "PPSExBasicViewController.h"

@interface PPSExVEPackBuyViewController : PPSExBasicViewController <MNVShopProviderDelegate> {
    NSArray      *_packList;
    UIButton     *_buyButton;
    UIPickerView *_packPickerView;
}

@property (nonatomic, retain) IBOutlet UIButton     *buyButton;
@property (nonatomic, retain) IBOutlet UIPickerView *packPickerView;

- (IBAction)doBuyBack:(id)sender;

@end
