//
//  PPSExUserAchievementsViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
@end

@implementation PPSExUserAchievementsViewController
@synthesize userAchievementsTextView;
@synthesize unlockAchIdTextField;

- (void)viewDidLoad {
    [super viewDidLoad];

    [[MNDirect achievementsProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [self setUserAchievementsTextView:nil];
    [self setUnlockAchIdTextField:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [userAchievementsTextView release];
    [unlockAchIdTextField release];
    
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
    if ([[MNDirect achievementsProvider]isGameAchievementListNeedUpdate]) {
        [[MNDirect achievementsProvider]doGameAchievementListUpdate];
    }
    else {
        [self updateView];
    }
}
- (void)updateView {
    if (![MNDirect isUserLoggedIn]) {
        self.userAchievementsTextView.text = PPSExUserNotLoggedInString;
        
        return;
    }
    
    NSMutableString *userAchListString = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
    NSString        *achName           = nil;
    
    NSArray *userAchList = [[MNDirect achievementsProvider]getPlayerAchievementList];
    
    for (MNPlayerAchievementInfo* playerAchInfo in userAchList) {
        achName = [[MNDirect achievementsProvider]findGameAchievementById:playerAchInfo.achievementId].name;
        [userAchListString appendFormat:@"Id: %d Name: %@\n",playerAchInfo.achievementId,achName];
    }
    
    self.userAchievementsTextView.text = userAchListString;
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
    [self updateState];
    
    self.userAchievementsTextView.text = PPSExUserNotLoggedInString;
}


@end
