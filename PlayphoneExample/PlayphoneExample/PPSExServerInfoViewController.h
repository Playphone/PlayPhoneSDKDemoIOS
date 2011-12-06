//
//  PPSExServerInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 10.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "MNServerInfoProvider.h"

#import "PPSExInfoPaneViewController.h"
#import "PPSExBasicViewController.h"

@interface PPSExServerInfoViewController : PPSExBasicViewController <MNServerInfoProviderDelegate> {
    UIView   *_infoPaneView;
    UIButton *_getServerInfoButton;

@private
    PPSExInfoPaneViewController *_infoPaneViewController;
}

@property (retain, nonatomic) IBOutlet UIView   *infoPaneView;
@property (retain, nonatomic) IBOutlet UIButton *getServerInfoButton;

- (IBAction)doGetServerInfo:(id)sender;

@end
