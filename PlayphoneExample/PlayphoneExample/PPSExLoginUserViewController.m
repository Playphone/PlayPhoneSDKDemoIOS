//
//  PPSExLoginUserViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 06.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNDirectUIHelper.h"

#import "PPSExLoginUserViewController.h"

@interface PPSExLoginUserViewController()


@end

@implementation PPSExLoginUserViewController
@synthesize userIdLabel;
@synthesize userNameLabel;
@synthesize userStatusLabel;
@synthesize loginButton;
@synthesize logoutButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Login User";
}

- (void)viewDidUnload
{
    [self setUserIdLabel:nil];
    [self setUserNameLabel:nil];
    [self setUserStatusLabel:nil];
    [self setLoginButton:nil];
    [self setLogoutButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    self.userStatusLabel.text = @"User is not logged in";
    
    loginButton .enabled = YES;
    logoutButton.enabled = NO;
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self playerLoggedIn];
    }
    else {
        [self playerLoggedOut];
    }
}

@end
