//
//  PPSExAppInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 13.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNTools.h"
#import "MNCommon.h"

#import "PPSExCommon.h"
#import "PPSExAppInfoViewController.h"


@implementation PPSExAppInfoViewController

@synthesize infoTextView = _infoTextView;

- (void)viewDidUnload {
    [self setInfoTextView:nil];
    
    [super viewDidUnload];
}

- (void)dealloc {
    [_infoTextView release];
    
    [super dealloc];
}

- (void)updateState {
    NSMutableString *infoString = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
    
    [infoString appendFormat:@"Application version: %@\n"      ,[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    [infoString appendFormat:@"MN API version: %@\n"           ,MNClientAPIVersion];
    [infoString appendFormat:@"Game Id: %d\n"                  ,PPSExGameId];
    [infoString appendFormat:@"Configuration URL: %@\n"        ,MNGetMultiNetConfigURL()];
    [infoString appendFormat:@"Build time: %s %s\n"            ,__DATE__,__TIME__];
    [infoString appendFormat:@"Current device: %@, OS: %@ %@\n",[[UIDevice currentDevice]model],[[UIDevice currentDevice]systemName],[[UIDevice currentDevice] systemVersion]];
    
    self.infoTextView.text = infoString;
}

@end
