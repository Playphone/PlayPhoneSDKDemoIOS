//
//  PPSExUserInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNUIUrlImageView.h"
#import "PPSExBasicViewController.h"

@interface PPSExUserInfoViewController : PPSExBasicViewController {
    UILabel *_headerLabel;
    UITextView *_bodyTextView;
    MNUIUrlImageView *_image;
}

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UITextView *bodyTextView;
@property (nonatomic, retain) IBOutlet MNUIUrlImageView *image;

@end
