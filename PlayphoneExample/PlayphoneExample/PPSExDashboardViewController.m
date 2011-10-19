//
//  PPSExDashboardViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirectButton.h"
#import "MNDirectUIHelper.h"

#import "PPSExDashboardViewController.h"


@implementation PPSExDashboardViewController

- (void)dealloc {
    [super dealloc];
}

- (IBAction)doShowLauncherIcon:(id)sender {
    [MNDirectButton show];
}

- (IBAction)doHideLauncherIcon:(id)sender {
    [MNDirectButton hide];
}

- (IBAction)doShowDashboard:(id)sender {
    [MNDirectUIHelper showDashboard];
}

@end
