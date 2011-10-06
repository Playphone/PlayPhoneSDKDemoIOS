//
//  MNDirectButton.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 24.09.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MNSession.h"
#import "MNUserProfileView.h"
#import "MNDirectUIHelper.h"

typedef enum {
    MNDIRECTBUTTON_TOPLEFT     = 1,
    MNDIRECTBUTTON_TOPRIGHT       ,
    MNDIRECTBUTTON_BOTTOMRIGHT    ,
    MNDIRECTBUTTON_BOTTOMLEFT     ,
    MNDIRECTBUTTON_LEFT           ,
    MNDIRECTBUTTON_TOP            ,
    MNDIRECTBUTTON_RIGHT          ,
    MNDIRECTBUTTON_BOTTOM
} MNDIRECTBUTTON_LOCATION;

@protocol MNDirectButtonDelegate

-(void) mnDirectButtonDoShowDashboard;
-(void) mnDirectButtonDoHideDashboard;
-(BOOL) mnDirectButtonIsDashboardVisible;

@end


@interface MNDirectButton : NSObject <MNSessionDelegate,MNUserProfileViewDelegate> {
}

+(void) initWithLocation:(MNDIRECTBUTTON_LOCATION) location;
+(void) initWithLocation:(MNDIRECTBUTTON_LOCATION) location andDelegate:(id<MNDirectButtonDelegate>)delegate;
+(void) show;
+(void) hide;
+(BOOL) isVisible;
+(BOOL) isHidden;

+(void) setFollowStatusBarOrientationEnabled:(BOOL) autorotationFlag;
+(BOOL) isFollowStatusBarOrientationEnabled;

+(void) adjustToOrientation:(UIInterfaceOrientation)orientation;

+(void) setAutohide:(BOOL) autohideFlag;
+(BOOL) isAutohide;
+(void) notifyPopoverClosed;

@end

@interface MNDirectButtonHandlerFullscreen : NSObject<MNDirectButtonDelegate,MNDirectUIHelperDelegate> {
}

-(id) init;
-(void) dealloc;

-(void) mnDirectButtonDoShowDashboard;
-(void) mnDirectButtonDoHideDashboard;
-(BOOL) mnDirectButtonIsDashboardVisible;

-(void) mnUIHelperDashboardHidden;
-(void) mnUIHelperDashboardShown;
@end

@interface MNDirectButtonHandlerPopover : NSObject<MNDirectButtonDelegate,MNDirectUIHelperDelegate> {
    CGSize popoverContentSize;
}

@property (nonatomic) CGSize popoverContentSize;

-(id) init;
-(void) dealloc;

-(void) mnDirectButtonDoShowDashboard;
-(void) mnDirectButtonDoHideDashboard;
-(BOOL) mnDirectButtonIsDashboardVisible;

-(void) mnUIHelperDashboardHidden;
-(BOOL) mnUIHelperShouldDismissPopover;

@end
