//
//  PPSExVEVItemInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 08.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"

#import "PPSExVEVItemInfoViewController.h"

@implementation PPSExVEVItemInfoViewController
@synthesize vItemIdLabel;
@synthesize vItemNameLabel;
@synthesize isConsumableLabel;
@synthesize isUniqueLabel;
@synthesize descriptionLabel;
@synthesize vItemImage;
@synthesize issueOnClientSwitch;
@synthesize isConsumableSwitch;
@synthesize isUniqueSwitch;
@synthesize paramsTextView;
@synthesize vItemInfo = _vItemInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [self setVItemIdLabel:nil];
    [self setVItemNameLabel:nil];
    [self setIsConsumableLabel:nil];
    [self setIsUniqueLabel:nil];
    [self setDescriptionLabel:nil];
    [self setVItemImage:nil];
    [self setIssueOnClientSwitch:nil];
    [self setIsConsumableSwitch:nil];
    [self setIsUniqueSwitch:nil];
    [self setParamsTextView:nil];
    
    [super viewDidUnload];
}

- (void)dealloc {
    [vItemIdLabel release];
    [vItemNameLabel release];
    [isConsumableLabel release];
    [isUniqueLabel release];
    [descriptionLabel release];
    [vItemImage release];
    [issueOnClientSwitch release];
    [isConsumableSwitch release];
    [isUniqueSwitch release];
    [paramsTextView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UIScrollView*)self.view).contentSize = CGSizeMake(self.view.frame.size.width, 460);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    ((UIScrollView*)self.view).contentSize = CGSizeMake(self.view.frame.size.width, 460);
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
