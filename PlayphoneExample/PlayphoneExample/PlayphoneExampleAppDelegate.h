//
//  PlayphoneExampleAppDelegate.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 05.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PPSExAppDelegate ((PlayphoneExampleAppDelegate*)[UIApplication sharedApplication].delegate)

@interface PlayphoneExampleAppDelegate : NSObject <UIApplicationDelegate>
{
    BOOL       _sessionReady;
}

@property (nonatomic, retain) IBOutlet UIWindow               *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, assign) BOOL     sessionReady;

@end
