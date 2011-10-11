//
//  PPSExUserAchievementsViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNAchievementsProvider.h"
#import "PPSExBasicViewController.h"

@interface PPSExUserAchievementsViewController : PPSExBasicViewController <MNAchievementsProviderDelegate>{
    UITextView *userAchievementsTextView;
    UITextField *unlockAchIdTextField;
}

@property (nonatomic, retain) IBOutlet UITextView *userAchievementsTextView;
@property (nonatomic, retain) IBOutlet UITextField *unlockAchIdTextField;

- (IBAction)doUnlockAchievements:(id)sender;
- (IBAction)achIdEditingDidEnd:(id)sender;
- (IBAction)achIdEditingDidBegin:(id)sender;

@end
