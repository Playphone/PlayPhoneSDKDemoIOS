//
//  PPSExInfoPaneViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 04.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExInfoPaneViewController.h"

@interface PPSExInfoPaneViewController()
@property (retain, nonatomic)NSString *headerText;
@property (retain, nonatomic)NSString *bodyText; 
@end

@implementation PPSExInfoPaneViewController
@synthesize headerLabel  = _headerLabel;
@synthesize bodyTextView = _bodyTextView;
@synthesize headerText   = _headerText;
@synthesize bodyText     = _bodyText;

- (void)viewDidLoad {
    if (self.headerText == nil) {
        self.headerLabel.text = @"";
    }
    else {
        self.headerLabel.text = self.headerText;
    }
    
    if (self.headerText == nil) {
        self.bodyTextView.text = @"";
    }
    else {
        self.bodyTextView.text = self.bodyText;
    }
}

- (void)viewDidUnload {
    [self setHeaderLabel :nil];
    [self setBodyTextView:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [_headerLabel  release];
    [_bodyTextView release];
    
    self.bodyText   = nil;
    self.headerText = nil;
    
    [super dealloc];
}

- (void)setHeaderTextSafe:(NSString*)headerText {
    self.headerText = headerText;
    
    if (self.headerLabel != nil) {
        self.headerLabel.text = self.headerText;
    }
}

- (void)setBodyTextSafe:(NSString*)bodyText {
    self.bodyText = bodyText;
    
    if (self.bodyTextView != nil) {
        self.bodyTextView.text = self.bodyText;
    }
}

@end
