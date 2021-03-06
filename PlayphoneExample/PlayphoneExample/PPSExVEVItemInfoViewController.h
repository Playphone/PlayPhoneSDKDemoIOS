//
//  PPSExVEVItemInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 08.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNVItemsProvider.h"
#import "MNUIUrlImageView.h"

#import "PPSExBasicViewController.h"

@interface PPSExVEVItemInfoViewController : PPSExBasicViewController
{
    UILabel          *_vItemIdLabel;
    UILabel          *_vItemNameLabel;
    UILabel          *_isConsumableLabel;
    UILabel          *_isUniqueLabel;
    UILabel          *_descriptionLabel;
    MNUIUrlImageView *_vItemImage;
    UISwitch         *_issueOnClientSwitch;
    UISwitch         *_isConsumableSwitch;
    UISwitch         *_isUniqueSwitch;
    UITextView       *_paramsTextView;
    
    MNGameVItemInfo  *_vItemInfo;
}

@property (nonatomic, retain) IBOutlet UILabel          *vItemIdLabel;
@property (nonatomic, retain) IBOutlet UILabel          *vItemNameLabel;
@property (nonatomic, retain) IBOutlet UILabel          *isConsumableLabel;
@property (nonatomic, retain) IBOutlet UILabel          *isUniqueLabel;
@property (nonatomic, retain) IBOutlet UILabel          *descriptionLabel;
@property (nonatomic, retain) IBOutlet MNUIUrlImageView *vItemImage;
@property (nonatomic, retain) IBOutlet UISwitch         *issueOnClientSwitch;
@property (nonatomic, retain) IBOutlet UISwitch         *isConsumableSwitch;
@property (nonatomic, retain) IBOutlet UISwitch         *isUniqueSwitch;
@property (nonatomic, retain) IBOutlet UITextView       *paramsTextView;

@property (nonatomic, retain) MNGameVItemInfo           *vItemInfo;

@end
