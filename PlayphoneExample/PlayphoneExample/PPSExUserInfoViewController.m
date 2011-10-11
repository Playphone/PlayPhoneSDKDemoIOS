//
//  PPSExUserInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNSession.h"
#import "MNUserInfo.h"

#import "PPSExUserInfoViewController.h"

#define PPSExDetailsDefCapacity        (1024)

@implementation PPSExUserInfoViewController
@synthesize headerLabel = _headerLabel;
@synthesize bodyTextView = _bodyTextView;
@synthesize image = _image;

- (void)viewDidUnload
{
    [self setHeaderLabel:nil];
    [self setBodyTextView:nil];
    [self setImage:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [_headerLabel release];
    [_bodyTextView release];
    [_image release];
    [super dealloc];
}

- (void)updateState {
    self.headerLabel.text = @"Details for the Current User";
    
    NSMutableString *userDetails = [[NSMutableString alloc]initWithCapacity:PPSExDetailsDefCapacity];
    
    MNUserInfo *userInfo = [[MNDirect getSession]getMyUserInfo];
    
    [userDetails appendFormat:@"User Name: %@\n",userInfo.userName];
    [userDetails appendFormat:@"User Id: %lld\n",userInfo.userId];
    [userDetails appendFormat:@"Current room: %d\n",[[MNDirect getSession]getCurrentRoomId]];
    
    self.bodyTextView.text = userDetails;
    
    [userDetails release];
    
    [self.image loadImageWithUrl:[NSURL URLWithString:[userInfo getAvatarUrl]]];
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    [self updateState];
}

@end
