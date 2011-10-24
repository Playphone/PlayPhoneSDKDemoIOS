//
//  PPSExVEVItemInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 08.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"

#import "PPSExVEVItemInfoViewController.h"


#define PPSExVEVItemInfoViewMinHeight (460)


@implementation PPSExVEVItemInfoViewController

@synthesize vItemIdLabel        = _vItemIdLabel;
@synthesize vItemNameLabel      = _vItemNameLabel;
@synthesize isConsumableLabel   = _isConsumableLabel;
@synthesize isUniqueLabel       = _isUniqueLabel;
@synthesize descriptionLabel    = _descriptionLabel;
@synthesize vItemImage          = _vItemImage;
@synthesize issueOnClientSwitch = _issueOnClientSwitch;
@synthesize isConsumableSwitch  = _isConsumableSwitch;
@synthesize isUniqueSwitch      = _isUniqueSwitch;
@synthesize paramsTextView      = _paramsTextView;
@synthesize vItemInfo           = _vItemInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentMinHeght = PPSExVEVItemInfoViewMinHeight;
}

- (void)viewDidUnload {
    [self setVItemIdLabel       :nil];
    [self setVItemNameLabel     :nil];
    [self setIsConsumableLabel  :nil];
    [self setIsUniqueLabel      :nil];
    [self setDescriptionLabel   :nil];
    [self setVItemImage         :nil];
    [self setIssueOnClientSwitch:nil];
    [self setIsConsumableSwitch :nil];
    [self setIsUniqueSwitch     :nil];
    [self setParamsTextView     :nil];
    
    self.vItemInfo = nil;
    
    [super viewDidUnload];
}

- (void)dealloc {
    [_vItemIdLabel        release];
    [_vItemNameLabel      release];
    [_isConsumableLabel   release];
    [_isUniqueLabel       release];
    [_descriptionLabel    release];
    [_vItemImage          release];
    [_issueOnClientSwitch release];
    [_isConsumableSwitch  release];
    [_isUniqueSwitch      release];
    [_paramsTextView      release];
    
    [_vItemInfo           release];
    
    [super dealloc];
}

- (void)setVItemInfo:(MNGameVItemInfo *)vItemInfo {
    if (_vItemInfo != nil) {
        [_vItemInfo release];
    }
    _vItemInfo = [vItemInfo retain];
    
    [self updateState];
}

- (void)updateState {
    if (self.vItemInfo == nil) {
        return;
    }
    
    if (self.vItemInfo.model & MNVItemIsCurrencyMask) {
        self.isConsumableLabel .hidden = YES;
        self.isConsumableSwitch.hidden = YES;
        self.isUniqueSwitch    .hidden = YES;
        self.isUniqueLabel     .hidden = YES;
    }
    else {
        self.isConsumableLabel .hidden = NO;
        self.isConsumableSwitch.hidden = NO;
        self.isUniqueSwitch    .hidden = NO;
        self.isUniqueLabel     .hidden = NO;
        
        self.isConsumableSwitch .on = self.vItemInfo.model & MNVItemIsConsumableMask;
        self.isUniqueSwitch     .on = self.vItemInfo.model & MNVItemIsUniqueMask;
    }
    
    [self.vItemImage loadImageWithUrl:[[MNDirect vItemsProvider]getVItemImageURL:self.vItemInfo.vItemId]];
    self.issueOnClientSwitch.on = self.vItemInfo.model & MNVItemIssueOnClientMask;

    self.vItemIdLabel    .text = [NSString stringWithFormat:@"Id: %d",self.vItemInfo.vItemId];
    self.vItemNameLabel  .text = self.vItemInfo.name;
    self.descriptionLabel.text = self.vItemInfo.description;
    self.paramsTextView  .text = self.vItemInfo.params;
}

@end
