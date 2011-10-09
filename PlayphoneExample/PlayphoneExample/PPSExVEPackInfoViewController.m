//
//  PPSExVEPackInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 09.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNVItemsProvider.h"
#import "MNVShopProvider.h"

#import "PPSExCommon.h"

#import "PPSExVEPackInfoViewController.h"

@implementation PPSExVEPackInfoViewController

@synthesize packInfo = _packInfo;
@synthesize packIdLabel = _packIdLabel;
@synthesize nameLabel = _nameLabel;
@synthesize categoryLabel = _categoryLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize priceLabel = _priceLabel;
@synthesize packIcon = _packIcon;
@synthesize isHiddenSwitch = _isHiddenSwitch;
@synthesize holdSalesSwitch = _holdSalesSwitch;
@synthesize itemsTextView = _itemsTextView;
@synthesize paramsTextView = _paramsTextView;

- (void)viewDidUnload {
    [self setPackIdLabel:nil];
    [self setNameLabel:nil];
    [self setCategoryLabel:nil];
    [self setDescriptionLabel:nil];
    [self setPriceLabel:nil];
    [self setPackIcon:nil];
    [self setIsHiddenSwitch:nil];
    [self setHoldSalesSwitch:nil];
    [self setItemsTextView:nil];
    [self setParamsTextView:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [_packIdLabel release];
    [_nameLabel release];
    [_categoryLabel release];
    [_descriptionLabel release];
    [_priceLabel release];
    [_packIcon release];
    [_isHiddenSwitch release];
    [_holdSalesSwitch release];
    [_itemsTextView release];
    [_paramsTextView release];
    [_packInfo release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UIScrollView*)self.view).contentSize = CGSizeMake(self.view.frame.size.width, 510);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    ((UIScrollView*)self.view).contentSize = CGSizeMake(self.view.frame.size.width, 510);
}

- (void)setPackInfo:(MNVShopPackInfo *)packInfo {
    if (_packInfo != nil) {
        [_packInfo release];
    }
    _packInfo = [packInfo retain];
    
    [self updateState];
}

- (void)updateState {
    if (self.packInfo == nil) {
        return;
    }
    
    self.packIdLabel     .text = [NSString stringWithFormat:@"Id: %d"         ,self.packInfo.packId];
    self.nameLabel       .text = [NSString stringWithFormat:@"Name: %@"       ,self.packInfo.name];
    self.categoryLabel   .text = [NSString stringWithFormat:@"Category: %@"   ,[[MNDirect vShopProvider]findVShopCategoryById:self.packInfo.categoryId].name];
    self.priceLabel      .text = [NSString stringWithFormat:@"Price: %@"      ,MNVShopPackGetPriceString(self.packInfo)];
    self.descriptionLabel.text = [NSString stringWithFormat:@"Description: %@",self.packInfo.description];
    
    self.isHiddenSwitch .on = self.packInfo.model & MNVItemIsHiddenMask;
    self.holdSalesSwitch.on = self.packInfo.model & MNVItemIsHoldSalesMask;
    
    self.paramsTextView.text = self.packInfo.appParams;
    
    [self.packIcon loadImageWithUrl:[[MNDirect vShopProvider]getVShopPackImageURL:self.packInfo.packId]];
    
    NSString *deliveryString = nil;
    for (MNVShopDeliveryInfo *deliveryInfo in self.packInfo.delivery) {
        deliveryString = [NSString stringWithFormat:@"%@\t%d",[[MNDirect vItemsProvider]findGameVItemById:deliveryInfo.vItemId].name,deliveryInfo.amount];
        
        if (deliveryString != nil) {
            self.itemsTextView.text = [NSString stringWithFormat:@"%@\n",self.itemsTextView.text];
        }
        
        self.itemsTextView.text = [NSString stringWithFormat:@"%@\n",deliveryString];
    }
}

@end
