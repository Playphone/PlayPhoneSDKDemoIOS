//
//  PPSExCurrentRoomCookieViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 24.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNGameRoomCookiesProvider.h"

#import "PPSExCommon.h"

#import "PPSExCurrentRoomCookieViewController.h"


#define PPSExCurrentRoomCookieViewMinHeight (400)


@interface PPSExCurrentRoomCookieViewController()
- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;
@end


@implementation PPSExCurrentRoomCookieViewController

@synthesize infoLabel            = _infoLabel;
@synthesize cookieValueTextField = _cookieValueTextField;
@synthesize storeCookieButton    = _storeCookieButton;
@synthesize readCookiesButton    = _readCookiesButton;
@synthesize cookiesTextView      = _cookiesTextView;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.contentMinHeght = PPSExCurrentRoomCookieViewMinHeight;
}

- (void)viewDidUnload {
    [self setInfoLabel:nil];
    [self setCookieValueTextField:nil];
    [self setStoreCookieButton:nil];
    [self setReadCookiesButton:nil];
    [self setCookiesTextView:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [_infoLabel            release];
    [_cookieValueTextField release];
    [_storeCookieButton    release];
    [_readCookiesButton    release];
    [_cookiesTextView      release];
    
    [super dealloc];
}

- (IBAction)doStoreCookie:(id)sender {
    if ([MNDirect isUserLoggedIn]) {
        [[MNDirect gameRoomCookiesProvider]setCurrentGameRoomCookieWithKey:rand() % 5 andCookie:self.cookieValueTextField.text];
        
        [self doReadCookies:nil];
    }
    else {
        PPSExShowNotLoggedInAlert();
    }
    
    [self.cookieValueTextField resignFirstResponder];
}

- (IBAction)doReadCookies:(id)sender {
    [self updateState];
    
    for (NSUInteger key = 0;key < 5;key++) {
        if (self.cookiesTextView.text.length != 0) {
            self.cookiesTextView.text = [self.cookiesTextView.text stringByAppendingString:@"\n"];
        }
        
        self.cookiesTextView.text = [self.cookiesTextView.text stringByAppendingFormat:
                                     @"Id: %d, Value: %@",
                                     key,
                                     [[MNDirect gameRoomCookiesProvider]currentGameRoomCookieWithKey:key]];
    }
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)switchToLoggedInState {
    self.cookiesTextView     .text     = @"";
    self.cookiesTextView     .editable = YES;
    self.cookieValueTextField.enabled  = YES;
    self.storeCookieButton   .enabled  = YES;
    self.readCookiesButton   .enabled  = YES;
    
    self.infoLabel.text = [NSString stringWithFormat:@"Room Id: %d",[[MNDirect getSession]getCurrentRoomId]];
}

- (void)switchToNotLoggedInState {
    self.cookiesTextView     .text     = @"";
    self.cookiesTextView     .editable = NO;
    self.cookieValueTextField.enabled  = NO;
    self.storeCookieButton   .enabled  = NO;
    self.readCookiesButton   .enabled  = NO;
    
    self.infoLabel.text = PPSExUserNotLoggedInString;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    // [self updateState];
    [self switchToNotLoggedInState];
}

@end
