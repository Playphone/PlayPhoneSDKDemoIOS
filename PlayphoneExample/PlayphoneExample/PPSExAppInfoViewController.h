//
//  PPSExAppInfoViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 13.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExBasicViewController.h"

@interface PPSExAppInfoViewController : PPSExBasicViewController {
    UITextView *_infoTextView;
}

@property (nonatomic, retain) IBOutlet UITextView *infoTextView;

@end
