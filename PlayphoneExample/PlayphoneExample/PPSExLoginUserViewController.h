//
//  PPSExLoginUserViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 06.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExBasicViewController.h"

@interface PPSExLoginUserViewController : PPSExBasicViewController {
    UILabel  *userIdLabel;
    UILabel  *userNameLabel;
    UILabel  *userStatusLabel;
    UIButton *loginButton;
    UIButton *logoutButton;
}

@property (nonatomic, retain) IBOutlet UILabel  *userIdLabel;
@property (nonatomic, retain) IBOutlet UILabel  *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel  *userStatusLabel;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIButton *logoutButton;

- (IBAction)doLogin :(id)sender;
- (IBAction)doLogout:(id)sender;

@end
