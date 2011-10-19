//
//  PPSExLoginUserViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 06.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNDirectUIHelper.h"

#import "PPSExCommon.h"
#import "PPSExLoginUserViewController.h"

@interface PPSExLoginUserViewController()


@end

@implementation PPSExLoginUserViewController
@synthesize userIdLabel;
@synthesize userNameLabel;
@synthesize userStatusLabel;
@synthesize loginButton;
@synthesize logoutButton;

- (void)viewDidUnload {
    [self setUserIdLabel:nil];
    [self setUserNameLabel:nil];
    [self setUserStatusLabel:nil];
    [self setLoginButton:nil];
    [self setLogoutButton:nil];

    [super viewDidUnload];
}

- (IBAction)doLogin:(id)sender {
    [MNDirect execAppCommand:@"jumpToUserHome" withParam:nil];
    [MNDirectUIHelper showDashboard];
}

- (IBAction)doLogout:(id)sender {
    [MNDirect execAppCommand:@"jumpToUserProfile" withParam:nil];
    [MNDirectUIHelper showDashboard];
}

- (void)dealloc {
    [userIdLabel release];
    [userNameLabel release];
    [userStatusLabel release];
    [loginButton release];
    [logoutButton release];
    [super dealloc];
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self playerLoggedIn];
    }
    else {
        [self playerLoggedOut];
    }
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    self.userIdLabel    .text = [NSString stringWithFormat:@"%lld",[[MNDirect getSession]getMyUserId]];
    self.userNameLabel  .text = [[MNDirect getSession]getMyUserName];
    self.userStatusLabel.text = @"User is logged in";
    
    loginButton .enabled = NO;
    logoutButton.enabled = YES;
}

- (void)playerLoggedOut {
    self.userIdLabel    .text = @"[nil]";
    self.userNameLabel  .text = @"[nil]";
    self.userStatusLabel.text = PPSExUserNotLoggedInString;
    
    loginButton .enabled = YES;
    logoutButton.enabled = NO;
}

@end
