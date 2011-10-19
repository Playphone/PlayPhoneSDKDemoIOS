//
//  PPSExCloudStorageViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 12.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNGameCookiesProvider.h"

#import "PPSExCommon.h"
#import "PPSExCloudStorageViewController.h"

static NSString *PPSExCloudStorageUploadError = @"Upload Error";

@interface PPSExCloudStorageViewController()
- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;
@end

@implementation PPSExCloudStorageViewController
@synthesize cookieTextField     = _cookieTextField;
@synthesize cookiesListTextView = _cookiesListTextView;
@synthesize storeInCloudButton  = _storeInCloudButton;
@synthesize readCloudButton     = _readCloudButton;

- (void)viewDidLoad {
    [[MNDirect gameCookiesProvider]addDelegate:self];
}
- (void)viewDidUnload {
    [self setCookieTextField    :nil];
    [self setCookiesListTextView:nil];
    [self setStoreInCloudButton :nil];
    [self setReadCloudButton    :nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [_cookieTextField     release];
    [_cookiesListTextView release];
    [_storeInCloudButton  release];
    [_readCloudButton     release];
    
    [[MNDirect gameCookiesProvider]removeDelegate:self];

    [super dealloc];
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
    self.cookiesListTextView.text = @"";
    self.cookieTextField   .enabled = YES;
    self.storeInCloudButton.enabled = YES;
    self.readCloudButton   .enabled = YES;
}

- (void)switchToNotLoggedInState {
    self.cookiesListTextView.text = PPSExUserNotLoggedInString;
    self.cookieTextField   .enabled = NO;
    self.storeInCloudButton.enabled = NO;
    self.readCloudButton   .enabled = NO;
}

- (IBAction)doStoreInCloud:(id)sender {
    if ([MNDirect isUserLoggedIn]) {
        [[MNDirect gameCookiesProvider]uploadUserCookieWithKey:rand() % 5 andCookie:self.cookieTextField.text];
    }
    else {
        PPSExShowNotLoggedInAlert();
    }
    
    [self.cookieTextField resignFirstResponder];
}

- (IBAction)doReadCloud:(id)sender {
    [self updateState];
    
    if ([MNDirect isUserLoggedIn]) {
        for (NSInteger userCookie = 0;userCookie < 5;userCookie++) {
            [[MNDirect gameCookiesProvider]downloadUserCookie:userCookie];
        }
    }
    else {
        PPSExShowNotLoggedInAlert();
    }
}

#pragma mark - MNGameCookiesProviderDelegate

-(void) gameCookie:(NSInteger) key downloadSucceeded:(NSString*) cookie {
    self.cookiesListTextView.text = [NSString stringWithFormat:
                                     @"%@\nId: %d, Value: %@",
                                     self.cookiesListTextView.text,
                                     key,cookie];
    
}

-(void) gameCookie:(NSInteger) key downloadFailedWithError:(NSString*) error {
    self.cookiesListTextView.text = [NSString stringWithFormat:
                                     @"%@\nId: %d, Error: %@",
                                     self.cookiesListTextView.text,
                                     key,error];
}

-(void) gameCookieUploadSucceeded:(NSInteger) key {
    [self doReadCloud:nil];
}

-(void) gameCookie:(NSInteger) key uploadFailedWithError:(NSString*) error {
    PPSExShowAlert(error,PPSExCloudStorageUploadError);
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    // [self updateState];
    [self switchToNotLoggedInState];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
