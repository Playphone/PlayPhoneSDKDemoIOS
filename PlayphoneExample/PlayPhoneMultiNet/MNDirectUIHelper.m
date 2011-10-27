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

static MNDelegateArray     *mnDirectUIHelperDelegates         = nil;
static UIView              *mnDirectUIHelperMNView            = nil;
static BOOL                 mnDirectUIHelperAutorotationFlag  = YES;
static int                  mnDirectUIHelperDashboardStyle    = MN_DASHBOARD_STYLE_POPUP;
static UIPopoverController *mnDirectUIHelperPopoverController = nil;
static CGAffineTransform    mnViewTransformOriginal;
static CGRect               mnViewTransformFrame;

#pragma mark -
#pragma MNDirectUIHelperBgView

#define MNDirectUIHelperPopupInsetX        (10.0f)
#define MNDirectUIHelperPopupInsetY        (10.0f)
#define MNDirectUIHelperPopupBorderWidth   ( 5.0f)

static float MNDirectUIHelperPopupBGColor[]     = { 0, 0, 0, 0.3f  };
static float MNDirectUIHelperPopupBorderColor[] = { 0, 0, 0, 0.24f };


@interface MNDirectUIHelperBgView : UIView

- (void)drawRect:(CGRect)rect;

@end

@implementation MNDirectUIHelperBgView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect borderInRect = CGRectInset(self.bounds,MNDirectUIHelperPopupInsetX,MNDirectUIHelperPopupInsetY);
    CGRect borderOutRect  = CGRectInset(self.bounds,MNDirectUIHelperPopupInsetX - MNDirectUIHelperPopupBorderWidth,MNDirectUIHelperPopupInsetY - MNDirectUIHelperPopupBorderWidth);
    
    float x1 = borderOutRect.origin.x;
    float x2 = borderInRect.origin.x;
    float x3 = borderInRect.origin.x + borderInRect.size.width;
    float x4 = borderOutRect.origin.x + borderOutRect.size.width;
    float y1 = borderOutRect.origin.y;
    float y2 = borderInRect.origin.y;
    float y3 = borderInRect.origin.y + borderInRect.size.height;
    float y4 = borderOutRect.origin.y + borderOutRect.size.height;

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(currentContext);
    CGContextSetShouldAntialias(currentContext,TRUE);

    CGContextBeginPath(currentContext);
    
    CGContextMoveToPoint(currentContext,x2,y1);
    CGContextAddArcToPoint(currentContext,x4,y1,x4,y2,MNDirectUIHelperPopupBorderWidth);
    CGContextAddArcToPoint(currentContext,x4,y4,x3,y4,MNDirectUIHelperPopupBorderWidth);
    CGContextAddArcToPoint(currentContext,x1,y4,x1,y3,MNDirectUIHelperPopupBorderWidth);
    CGContextAddArcToPoint(currentContext,x1,y1,x2,y1,MNDirectUIHelperPopupBorderWidth);
    CGContextClosePath(currentContext);
    CGContextAddRect(currentContext,borderInRect);
    
    CGContextSetRGBFillColor(currentContext,
                             MNDirectUIHelperPopupBorderColor[0],MNDirectUIHelperPopupBorderColor[1],
                             MNDirectUIHelperPopupBorderColor[2],MNDirectUIHelperPopupBorderColor[3]);

    
    CGContextFillPath(currentContext);

    CGContextRestoreGState(currentContext);
}

@end

#pragma mark -
#pragma MNDirectUIHelper

@interface MNDirectUIHelper()

+(NSValue*) getDashboardFrameValue;

+(void) prepareView;
+(void) releaseView;

+(void) refreshOrientationObserver;
+(void) addOrientationOserver;
+(void) removeOrientationOserver;

+(CGAffineTransform)getTransformByOrientation:(UIInterfaceOrientation)orientation;
+(CGAffineTransform)getCurrentDashboardTransform;

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

+(void) setDashboardStyle:(int) newStyle {
    mnDirectUIHelperDashboardStyle = newStyle;
}
+(int) getDashboardStyle {
    return mnDirectUIHelperDashboardStyle;
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
        
        mnDirectUIHelperPopoverController.delegate = (id<UIPopoverControllerDelegate>)self;
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

+(CGRect) getDashboardFrame {
    CGRect dashboardFrame = [[UIScreen mainScreen]applicationFrame];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        if (dashboardFrame.size.width < dashboardFrame.size.height) {
            dashboardFrame = CGRectMake(0,0,dashboardFrame.size.height,dashboardFrame.size.width);
        }
    }
    else {
        if (dashboardFrame.size.width > dashboardFrame.size.height) {
            dashboardFrame = CGRectMake(0,0,dashboardFrame.size.height,dashboardFrame.size.width);
        }        
    }

    if (mnDirectUIHelperDashboardStyle == MN_DASHBOARD_STYLE_POPUP) {
        dashboardFrame = CGRectInset(dashboardFrame,MNDirectUIHelperPopupInsetX,MNDirectUIHelperPopupInsetY);
    }
    
    return dashboardFrame;
}
+(NSValue*) getDashboardFrameValue {
    return [NSValue valueWithCGRect:[MNDirectUIHelper getDashboardFrame]];
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
    CGAffineTransform      transformNeeded    = [MNDirectUIHelper getTransformByOrientation:currentOrientation];

    mnDirectUIHelperMNView.transform = transformNeeded;
    mnDirectUIHelperMNView.frame     = [UIScreen mainScreen].applicationFrame;
    
    [mnDirectUIHelperMNView setNeedsDisplay];
}

#pragma mark -

+(void) prepareView {
    if (mnDirectUIHelperMNView == nil) {
        mnDirectUIHelperMNView = [MNDirect getView];
    }
    
    if (mnDirectUIHelperMNView != nil) {
        if (mnDirectUIHelperDashboardStyle == MN_DASHBOARD_STYLE_FULLSCREEN) {
            mnViewTransformOriginal = mnDirectUIHelperMNView.transform;
            mnViewTransformFrame    = mnDirectUIHelperMNView.frame;
        }
        else if (mnDirectUIHelperDashboardStyle == MN_DASHBOARD_STYLE_POPUP) {
            mnDirectUIHelperMNView = [[MNDirectUIHelperBgView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
            mnDirectUIHelperMNView.backgroundColor = [UIColor colorWithRed:MNDirectUIHelperPopupBGColor[0]
                                                                     green:MNDirectUIHelperPopupBGColor[1]
                                                                      blue:MNDirectUIHelperPopupBGColor[2]
                                                                     alpha:MNDirectUIHelperPopupBGColor[3]];
            
            UIView *mnView = [MNDirect getView];
            CGRect newFrame = CGRectInset(mnDirectUIHelperMNView.bounds,MNDirectUIHelperPopupInsetX,MNDirectUIHelperPopupInsetY);
            mnView.frame = newFrame;

            [mnDirectUIHelperMNView addSubview:mnView];
        }
        else {
            NSLog(@"MNDirectUIHelper: Unknown Dashboard Stye: [%d]",mnDirectUIHelperDashboardStyle);
        }

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

        if (mnDirectUIHelperDashboardStyle == MN_DASHBOARD_STYLE_POPUP) {
            [[MNDirect getView]removeFromSuperview];
            [mnDirectUIHelperMNView release];
        }
        
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

+(CGAffineTransform)getTransformByOrientation:(UIInterfaceOrientation)orientation {
    CGAffineTransform      resultTransform;
    
    if      (orientation == UIInterfaceOrientationLandscapeRight) {
        resultTransform = CGAffineTransformMakeRotation((CGFloat)M_PI_2);
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        resultTransform = CGAffineTransformMakeRotation((CGFloat)-M_PI_2);
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        resultTransform = CGAffineTransformMakeRotation((CGFloat)M_PI);
    }
    else { //currentOrientation == UIInterfaceOrientationPortrait;
        resultTransform = CGAffineTransformMakeRotation(0);
    }

    return resultTransform;
}
+(CGAffineTransform)getCurrentDashboardTransform {
    CGAffineTransform      currentNeeded;
    
    if (mnDirectUIHelperMNView != nil) {
        currentNeeded = mnDirectUIHelperMNView.transform;
    }
    else {
        currentNeeded = [MNDirectUIHelper getTransformByOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
    
    return currentNeeded;
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
