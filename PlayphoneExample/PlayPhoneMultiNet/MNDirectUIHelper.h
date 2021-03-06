//
//  MNDirectUIHelper.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 22.11.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  MN_DASHBOARD_STYLE_FULLSCREEN   (1)
#define  MN_DASHBOARD_STYLE_POPUP        (2)

/**
 * @brief "MNDirectUIHelper" delegate protocol.
 *
 * By implementing methods of MNDirectUIHelperDelegate protocol, the delegate 
 * can respond to UI events.
 */
@protocol MNDirectUIHelperDelegate<NSObject>
@optional

/**
 * This message is sent when Multinet dashboard has been shown.
 */
-(void) mnUIHelperDashboardShown;

/**
 * This message is sent when Multinet dashboard has been hidden.
 */
-(void) mnUIHelperDashboardHidden;

/**
 * Asks the delegate if the popover should be dismissed.
 */
-(BOOL) mnUIHelperShouldDismissPopover;

@end

/**
 * @brief "MNDirectUIHelper".
 *
 * "MNDirectUIHelper" provides functionality which allows to show and hide 
 * Multinet Dashboard.
 */
@interface MNDirectUIHelper : NSObject {
}

/**
 * Adds delegate
 * @param delegate an object conforming to MNDirectUIHelperDelegate protocol
 */
+(void) addDelegate:(id<MNDirectUIHelperDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
+(void) removeDelegate:(id<MNDirectUIHelperDelegate>) delegate;

/**
 * Sets dashboard style
 * @param new dashboard style (one of MNDASHBOARD_STYLE_* constants)
 */
+(void) setDashboardStyle:(int) newStyle;

/**
 * Returns dashboard style.
 * @return current dashboard style (one of MNDASHBOARD_STYLE_* constants)
 */
+(int) getDashboardStyle;

/**
 * Shows Multinet Dashboard by adding it to keyWindow. Informs delegates
 * about this action.
 */
+(void) showDashboard;

/**
 * Shows Multinet Dashboard in popover window (iPad only). Informs delegates
 * about this action.
 */
+(void) showDashboardInPopoverWithSize:(CGSize) popoverSize fromRect:(CGRect) popoverFromRect;

/**
 * Hides Multinet Dashboard by removing from a superview. Informs delegates
 * about this action.
 */
+(void) hideDashboard;

/**
 * Checsk is Multinet Dashboard visible.
 */
+(BOOL) isDashboardVisible;

/**
 * Checsk is Multinet Dashboard hidden.
 */
+(BOOL) isDashboardHidden;

/**
 * Returns dashboard frame for current display mode.
 */
+(CGRect) getDashboardFrame;

/**
 * Sets/clears property wich indicate either dashboard rotates with status bar or not.
 */
+(void) setFollowStatusBarOrientationEnabled:(BOOL) autorotationFlag;

/**
 * Checks is dashboard should autorotates with status bar.
 */
+(BOOL) isFollowStatusBarOrientationEnabled;

/**
 * Force sets dashboard orientation.
 */
+(void) adjustToCurrentOrientation;

@end
