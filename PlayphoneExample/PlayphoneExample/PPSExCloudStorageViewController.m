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

@implementation PPSExCloudStorageViewController
@synthesize cookieTextField = _cookieTextField;
@synthesize cookiesListTextView = _cookiesListTextView;

- (void)viewDidLoad {
    [[MNDirect gameCookiesProvider]addDelegate:self];
}
- (void)viewDidUnload {
    [self setCookieTextField:nil];
    [self setCookiesListTextView:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [_cookieTextField release];
    [_cookiesListTextView release];
    [_doReadCloud release];
    
    [[MNDirect gameCookiesProvider]removeDelegate:self];

    [super dealloc];
}

- (void)updateState {
    if (![MNDirect isUserLoggedIn]) {
        self.cookiesListTextView.text = @"User is not logged in";
    }
    else {
        self.cookiesListTextView.text = @"";
    }
}

- (IBAction)doStoreInCloud:(id)sender {
    if ([MNDirect isUserLoggedIn]) {
        [[MNDirect gameCookiesProvider]uploadUserCookieWithKey:rand() % 5 andCookie:self.cookieTextField.text];
    }
    else {
        PPSExShowAlert(@"User is not logged in", @"Error");
    }
}

- (IBAction)doReadCloud:(id)sender {
    self.cookiesListTextView.text = @"";
    
    for (NSInteger userCookie = 0;userCookie < 5;userCookie++) {
        [[MNDirect gameCookiesProvider]downloadUserCookie:userCookie];
    }
}

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
    [[MNDirect gameCookiesProvider]downloadUserCookie:key];
}

-(void) gameCookie:(NSInteger) key uploadFailedWithError:(NSString*) error {
    PPSExShowAlert([NSString stringWithFormat:@"Message: %@",error], @"Upload error");
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    // [self updateState];
    self.cookiesListTextView.text = @"User is not logged in";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


@end
