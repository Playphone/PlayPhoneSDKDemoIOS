//
//  PPSExInfoPaneViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 04.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExBasicViewController.h"

@interface PPSExInfoPaneViewController : PPSExBasicViewController
{
    UILabel    *_headerLabel;
    UITextView *_bodyTextView;
    
    NSString *_headerText;
    NSString *_bodyText;
}

@property (retain, nonatomic) IBOutlet UILabel    *headerLabel;
@property (retain, nonatomic) IBOutlet UITextView *bodyTextView;

- (void)setHeaderTextSafe:(NSString*)headerText;
- (void)setBodyTextSafe:(NSString*)bodyText;

@end
