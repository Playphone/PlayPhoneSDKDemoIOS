//
//  MNDirectUIHelper.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 22.11.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNDirect.h"
#import "MNDelegateArray.h"
#import "MNDirectUIHelper.h"

static MNDelegateArray*     mnDirectUIHelperDelegates         = nil;
static MNUserProfileView*   mnDirectUIHelperMNView            = nil;
static BOOL                 mnDirectUIHelperAutorotationFlag  = YES;
static UIPopoverController *mnDirectUIHelperPopoverController = nil;
static CGAffineTransform    mnViewTransformOriginal;
static CGRect               mnViewTransformFrame;

@interface MNDirectUIHelper()

+(void) prepareView;
+(void) releaseView;

+(void) refreshOrientationObserver;
+(void) addOrientationOserver;
+(void) removeOrientationOserver;

@end


@implementation MNDirectUIHelper

+(void) addDelegate:(id<MNDirectUIHelperDelegate>) delegate {
    if (mnDirectUIHelperDelegates == nil) {
        mnDirectUIHelperDelegates = [[MNDelegateArray alloc]init];
    }
    
    [mnDirectUIHelperDelegates addDelegate:delegate];
}
+(void) removeDelegate:(id<MNDirectUIHelperDelegate>) delegate {
    if (mnDirectUIHelperDelegates != nil) {
        [mnDirectUIHelperDelegates removeDelegate:delegate];
    }
}

+(void) showDashboard {
    if ([MNDirectUIHelper isDashboardVisible]) {
        return;
    }

    [self prepareView];

    if (mnDirectUIHelperMNView != nil) {
        UIWindow *parentWindow = [UIApplication sharedApplication].keyWindow;
        
        if (parentWindow == nil) {
            parentWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        
        [parentWindow addSubview:mnDirectUIHelperMNView];
        
        [mnDirectUIHelperDelegates beginCall];
        
        for (id<MNDirectUIHelperDelegate> delegate in mnDirectUIHelperDelegates) {
            if ([delegate respondsToSelector: @selector(mnUIHelperDashboardShown)]) {
                [delegate mnUIHelperDashboardShown];
            }
        }
        
        [mnDirectUIHelperDelegates endCall];
    }
}
+(void) showDashboardInPopoverWithSize:(CGSize) popoverSize fromRect:(CGRect) popoverFromRect {
    if ([MNDirectUIHelper isDashboardVisible]) {
        return;
    }
    
    [self prepareView];
    
    if (mnDirectUIHelperMNView != nil) {
        UIViewController *dashboardController = [[UIViewController alloc]init];
        dashboardController.view = mnDirectUIHelperMNView;
        dashboardController.view.frame = CGRectMake(0,0,popoverSize.width,popoverSize.height);

        mnDirectUIHelperPopoverController = [[UIPopoverController alloc]initWithContentViewController:dashboardController];
        
        mnDirectUIHelperPopoverController.delegate = self;
        mnDirectUIHelperPopoverController.popoverContentSize = popoverSize;
        
        [mnDirectUIHelperPopoverController presentPopoverFromRect:popoverFromRect
                                                           inView:[UIApplication sharedApplication].keyWindow 
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
        
        [dashboardController release];
        
        [mnDirectUIHelperDelegates beginCall];
        
        for (id<MNDirectUIHelperDelegate> delegate in mnDirectUIHelperDelegates) {
            if ([delegate respondsToSelector: @selector(mnUIHelperDashboardShown)]) {
                [delegate mnUIHelperDashboardShown];
            }
        }
        
        [mnDirectUIHelperDelegates endCall];
        
    }
}
+(void) hideDashboard {
    if ([MNDirectUIHelper isDashboardHidden]) {
        return;
    }
    
    if (mnDirectUIHelperPopoverController != nil) {
        [mnDirectUIHelperPopoverController dismissPopoverAnimated:YES];
    }
    
    [self releaseView];
    
    [mnDirectUIHelperDelegates beginCall];
    
    for (id<MNDirectUIHelperDelegate> delegate in mnDirectUIHelperDelegates) {
        if ([delegate respondsToSelector: @selector(mnUIHelperDashboardHidden)]) {
            [delegate mnUIHelperDashboardHidden];
        }
    }
    
    [mnDirectUIHelperDelegates endCall];
}

+(BOOL) isDashboardHidden {
    return(mnDirectUIHelperMNView == nil);
}
+(BOOL) isDashboardVisible {
    return(![self isDashboardHidden]);
}

+(void) setFollowStatusBarOrientationEnabled:(BOOL) autorotationFlag {
    mnDirectUIHelperAutorotationFlag = autorotationFlag;
    
	[MNDirectUIHelper refreshOrientationObserver];
}
+(BOOL) isFollowStatusBarOrientationEnabled {
    return mnDirectUIHelperAutorotationFlag;
}

+(void) adjustToCurrentOrientation {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGAffineTransform      transformNeeded;
    
    if      (currentOrientation == UIInterfaceOrientationLandscapeRight) {
        transformNeeded = CGAffineTransformMakeRotation((CGFloat)M_PI_2);
    }
    else if (currentOrientation == UIInterfaceOrientationLandscapeLeft) {
        transformNeeded = CGAffineTransformMakeRotation((CGFloat)-M_PI_2);
    }
    else if (currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        transformNeeded = CGAffineTransformMakeRotation((CGFloat)M_PI);
    }
    else { //currentOrientation == UIInterfaceOrientationPortrait;
        transformNeeded = CGAffineTransformMakeRotation(0);
    }
    
    mnDirectUIHelperMNView.transform = transformNeeded;
    mnDirectUIHelperMNView.frame     = [UIScreen mainScreen].applicationFrame;
}

#pragma mark -

+(void) prepareView {
    if (mnDirectUIHelperMNView == nil) {
        mnDirectUIHelperMNView = [MNDirect getView];
    }
    
    if (mnDirectUIHelperMNView != nil) {
        mnViewTransformOriginal = mnDirectUIHelperMNView.transform;
        mnViewTransformFrame    = mnDirectUIHelperMNView.frame;

        [MNDirectUIHelper refreshOrientationObserver];
    }        
}
+(void) releaseView {
    if (mnDirectUIHelperMNView != nil) {
        mnDirectUIHelperMNView.transform = mnViewTransformOriginal;
        mnDirectUIHelperMNView.frame     = mnViewTransformFrame;
        
        [mnDirectUIHelperMNView removeFromSuperview];
//        [mnDirectUIHelperMNView removeDelegate:self];
//        [[MNDirect getSession]  removeDelegate:self];
        mnDirectUIHelperMNView = nil;
        
        [MNDirectUIHelper refreshOrientationObserver];
    }       
}

+(void) refreshOrientationObserver {
    if ((mnDirectUIHelperMNView != nil) && mnDirectUIHelperAutorotationFlag) {
        [MNDirectUIHelper addOrientationOserver];
    }
    else {
        [MNDirectUIHelper removeOrientationOserver];
    }
}
+(void) addOrientationOserver {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidChangeStatusBarOrientationNotification
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didRotate:)
                                                name:UIApplicationDidChangeStatusBarOrientationNotification
                                              object:nil];

    [MNDirectUIHelper adjustToCurrentOrientation];
}
+(void) removeOrientationOserver {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidChangeStatusBarOrientationNotification
                                                 object:nil];
}

+(void) didRotate:(NSNotification *)notification {
    if (mnDirectUIHelperAutorotationFlag) {
        [MNDirectUIHelper adjustToCurrentOrientation];
    }
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate

+(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == mnDirectUIHelperPopoverController) {
        [mnDirectUIHelperPopoverController release];
        mnDirectUIHelperPopoverController = nil;
    }
    
    [self hideDashboard];
}

+(BOOL) popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    BOOL result = YES;
    
    [mnDirectUIHelperDelegates beginCall];
    
    for (id<MNDirectUIHelperDelegate> delegate in mnDirectUIHelperDelegates) {
        if ([delegate respondsToSelector: @selector(mnUIHelperShouldDismissPopover)]) {
            result = result && [delegate mnUIHelperShouldDismissPopover];
        }
    }
    
    [mnDirectUIHelperDelegates endCall];
    
    return result;
}

@end
