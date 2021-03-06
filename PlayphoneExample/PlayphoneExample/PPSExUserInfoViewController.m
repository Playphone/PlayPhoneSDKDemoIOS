//
//  PPSExUserInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNSession.h"
#import "MNUserInfo.h"
#import "MNWSBuddyListItem.h"

#import "PPSExCommon.h"

#import "PPSExUserInfoViewController.h"


@interface PPSExUserInfoViewController ()
- (void)switchToNotLoggedInState;
@end


@implementation PPSExUserInfoViewController

@synthesize buddyInfo    = _buddyInfo;
@synthesize headerLabel  = _headerLabel;
@synthesize bodyTextView = _bodyTextView;
@synthesize image        = _image;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _buddyInfo = nil;
}
- (void)viewDidUnload {
    [self setHeaderLabel :nil];
    [self setBodyTextView:nil];
    [self setImage       :nil];
    
    self.buddyInfo = nil;

    [super viewDidUnload];
}

- (void)dealloc {
    [_headerLabel  release];
    [_bodyTextView release];
    [_image        release];

    [_buddyInfo    release];
    
    [super dealloc];
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        if (self.buddyInfo == nil) {
            self.headerLabel.text = @"Details for the Current User";
            
            NSMutableString *userDetails = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
            
            MNUserInfo *userInfo = [[MNDirect getSession]getMyUserInfo];
            
            [userDetails appendFormat:@"User Name: %@\n"   ,userInfo.userName];
            [userDetails appendFormat:@"User Id: %lld\n"   ,userInfo.userId];
            [userDetails appendFormat:@"Current room: %d\n",[[MNDirect getSession]getCurrentRoomId]];
            
            self.bodyTextView.text = userDetails;
            
            [self.image loadImageWithUrl:[NSURL URLWithString:[userInfo getAvatarUrl]]];
        }
        else {
            self.headerLabel.text = @"Buddy details";
            
            NSMutableString *userDetails = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
            
            [userDetails appendFormat:@"User Name: %@\n"                ,[self.buddyInfo getFriendUserNickName]];
            [userDetails appendFormat:@"User Id: %lld\n"                ,[self.buddyInfo getFriendUserId].longLongValue];
            [userDetails appendFormat:@"User is online: %@\n"           ,[self.buddyInfo getFriendUserOnlineNow].boolValue?@"YES":@"NO"];
            [userDetails appendFormat:@"Playing game: %@\n"             ,[self.buddyInfo getFriendInGameName]];
            [userDetails appendFormat:@"Has current game: %@\n"         ,[self.buddyInfo getFriendHasCurrentGame].boolValue?@"YES":@"NO"];
            [userDetails appendFormat:@"Locale: %@\n"                   ,[self.buddyInfo getFriendUserLocale]];
            [userDetails appendFormat:@"Is ignored: %@\n"               ,[self.buddyInfo getFriendIsIgnored].boolValue?@"YES":@"NO"];
            [userDetails appendFormat:@"Current room: %d\n"             ,[self.buddyInfo getFriendInRoomSfid]];
            [userDetails appendFormat:@"Current game achievements: %@\n",[self.buddyInfo getFriendCurrGameAchievementsList]];
            
            self.bodyTextView.text = userDetails;
            
            [self.image loadImageWithUrl:[NSURL URLWithString:[self.buddyInfo getFriendUserAvatarUrl]]];
        }
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)switchToNotLoggedInState {
    self.headerLabel .text = PPSExUserNotLoggedInString;
    self.bodyTextView.text = @"";
    self.image.image = [UIImage imageNamed:@"no-image.png"];
    
    if (self.buddyInfo != nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)setBuddyInfo:(MNWSBuddyListItem *)buddyInfo {
    if (_buddyInfo != nil) {
        [_buddyInfo release];
    }
    
    _buddyInfo = [buddyInfo retain];
    
    [self updateState];
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    //[self updateState];
    [self switchToNotLoggedInState];
}

@end
