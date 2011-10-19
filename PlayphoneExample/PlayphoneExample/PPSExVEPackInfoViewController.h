//
//  PPSExVEPackInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 09.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNUIUrlImageView.h"
#import "MNVShopProvider.h"

#import "PPSExBasicViewController.h"

@interface PPSExVEPackInfoViewController : PPSExBasicViewController
{
    MNVShopPackInfo  *_packInfo;
    
    UILabel          *_packIdLabel;
    UILabel          *_nameLabel;
    UILabel          *_categoryLabel;
    UILabel          *_descriptionLabel;
    UILabel          *_priceLabel;
    MNUIUrlImageView *_packIcon;
    UISwitch         *_isHiddenSwitch;
    UISwitch         *_holdSalesSwitch;
    UITextView       *_itemsTextView;
    UITextView       *_paramsTextView;
}

@property (nonatomic, retain) MNVShopPackInfo           *packInfo;

@property (nonatomic, retain) IBOutlet UILabel          *packIdLabel;
@property (nonatomic, retain) IBOutlet UILabel          *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel          *categoryLabel;
@property (nonatomic, retain) IBOutlet UILabel          *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel          *priceLabel;
@property (nonatomic, retain) IBOutlet MNUIUrlImageView *packIcon;
@property (nonatomic, retain) IBOutlet UISwitch         *isHiddenSwitch;
@property (nonatomic, retain) IBOutlet UISwitch         *holdSalesSwitch;
@property (nonatomic, retain) IBOutlet UITextView       *itemsTextView;
@property (nonatomic, retain) IBOutlet UITextView       *paramsTextView;

@end
