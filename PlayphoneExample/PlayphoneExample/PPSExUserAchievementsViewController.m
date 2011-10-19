//
//  PPSExUserAchievementsViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNAchievementsProvider.h"

#import "PPSExCommon.h"
#import "PPSExUserAchievementsViewController.h"

#define PPSExKeyboardHeight                     (263)
#define PPSExNavigationPaneHeight               (65)
#define PPSExTextFieldGap                       (10)


@interface PPSExUserAchievementsViewController()
- (void)updateView;

- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;

@end

@implementation PPSExUserAchievementsViewController
@synthesize userAchievementsTextView = _userAchievementsTextView;
@synthesize unlockAchIdTextField     = _unlockAchIdTextField;
@synthesize unlockButton             = _unlockButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    [[MNDirect achievementsProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [self setUserAchievementsTextView:nil];
    [self setUnlockAchIdTextField    :nil];
    [self setUnlockButton            :nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [_userAchievementsTextView release];
    [_unlockAchIdTextField     release];
    [_unlockButton             release];

    [[MNDirect achievementsProvider]removeDelegate:self];

    [super dealloc];
}

- (IBAction)doUnlockAchievements:(id)sender {
    NSInteger unlockAchId = 0;
    
    if (![MNDirect isUserLoggedIn]) {
        PPSExShowAlert(PPSExUserNotLoggedInString, @"");
    }
    else if (!PPSExScanInteger(self.unlockAchIdTextField.text,&unlockAchId)) {
        PPSExShowInvalidNumberFormatAlert();
    }
    else {
        [[MNDirect achievementsProvider]unlockPlayerAchievement:unlockAchId];
    }

    [self.unlockAchIdTextField resignFirstResponder];
}

- (IBAction)achIdEditingDidBegin:(id)sender {
    [((UIScrollView*)self.view) 
     setContentOffset:CGPointMake(0,(self.unlockAchIdTextField.frame.origin.y    + 
                                     self.unlockAchIdTextField.frame.size.height - 
                                     PPSExKeyboardHeight                         +
                                     PPSExNavigationPaneHeight                   +
                                     PPSExTextFieldGap))
     animated:YES];
}

- (IBAction)achIdEditingDidEnd:(id)sender {
    [((UIScrollView*)self.view) setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];
        
        if ([[MNDirect achievementsProvider]isGameAchievementListNeedUpdate]) {
            [[MNDirect achievementsProvider]doGameAchievementListUpdate];
        }
        else {
            [self updateView];
        }
    }
    else {
        [self switchToNotLoggedInState];
    }
}
- (void)updateView {
    NSMutableString *userAchListString = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
    NSString        *achName           = nil;
    
    NSArray *userAchList = [[MNDirect achievementsProvider]getPlayerAchievementList];
    
    for (MNPlayerAchievementInfo* playerAchInfo in userAchList) {
        achName = [[MNDirect achievementsProvider]findGameAchievementById:playerAchInfo.achievementId].name;
        [userAchListString appendFormat:@"Id: %d Name: %@\n",playerAchInfo.achievementId,achName];
    }
    
    self.userAchievementsTextView.text = userAchListString;
}

- (void)switchToLoggedInState {
    self.unlockAchIdTextField.enabled = YES;
    self.unlockButton        .enabled = YES;
}
- (void)switchToNotLoggedInState {
    self.unlockAchIdTextField.text    = @"";
    self.unlockAchIdTextField.enabled = NO;
    self.unlockButton        .enabled = NO;
    
    self.userAchievementsTextView.text = PPSExUserNotLoggedInString;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - MNAchievementsProviderDelegate

- (void)onGameAchievementListUpdated {
    [self updateView];
}

- (void)onPlayerAchievementUnlocked:(int) achievementId {
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
