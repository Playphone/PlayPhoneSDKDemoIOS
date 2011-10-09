//
//  PPSExVEPackBuyViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 09.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "MNVShopProvider.h"

#import "PPSExBasicViewController.h"

@interface PPSExVEPackBuyViewController : PPSExBasicViewController <MNVShopProviderDelegate> {
    NSArray *_packList;
    UIPickerView *_packPickerView;
}

@property (nonatomic, retain) IBOutlet UIPickerView *packPickerView;
- (IBAction)doBuyBack:(id)sender;

@end
