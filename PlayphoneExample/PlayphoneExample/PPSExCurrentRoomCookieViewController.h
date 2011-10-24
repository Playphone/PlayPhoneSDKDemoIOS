//
//  PPSExCurrentRoomCookieViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 24.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExBasicViewController.h"

@interface PPSExCurrentRoomCookieViewController : PPSExBasicViewController
{
    UILabel     *_infoLabel;
    UITextField *_cookieValueTextField;
    UIButton    *_storeCookieButton;
    UIButton    *_readCookiesButton;
    UITextView  *_cookiesTextView;
}

@property (retain, nonatomic) IBOutlet UILabel     *infoLabel;
@property (retain, nonatomic) IBOutlet UITextField *cookieValueTextField;
@property (retain, nonatomic) IBOutlet UIButton    *storeCookieButton;
@property (retain, nonatomic) IBOutlet UIButton    *readCookiesButton;
@property (retain, nonatomic) IBOutlet UITextView  *cookiesTextView;

- (IBAction)doStoreCookie:(id)sender;
- (IBAction)doReadCookies:(id)sender;

@end
