//
//  MNDirectButton.m
//  MultiNet client
//
//  Created by Vladislav Ogol on 24.09.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNDirect.h"
#import "MNDirectButton.h"

static UIWindow               *mnDirectButtonWindow             = nil;
static UIButton               *mnDirectButton                   = nil;
static MNDIRECTBUTTON_LOCATION mnDirectButtonLocation           =  0;
static BOOL                    mnDirectButtonAutorotationFlag   = YES;
static NSString               *mnDirectButtonImageName          = @"";
static UIInterfaceOrientation  mnDirectButtonOrientation        = UIInterfaceOrientationPortrait;
static UIInterfaceOrientation  mnDirectButtonOrientationDefault = UIInterfaceOrientationPortrait;
static BOOL                    mnDirectButtonVisible            = NO;
static id                      mnDirectButtonDelegate           = nil;
static BOOL                    mnDirectButtonAutohideFlag       = YES;

#define MNDirectButtonImageCutGap      (0)

static NSString *MNDirectButtonPositionTopPostfix    = @"t";
static NSString *MNDirectButtonPositionMiddlePostfix = @"m";
static NSString *MNDirectButtonPositionBottomPostfix = @"b";
static NSString *MNDirectButtonPositionLeftPostfix   = @"l";
static NSString *MNDirectButtonPositionCenterPostfix = @"c";
static NSString *MNDirectButtonPositionRightPostfix  = @"r";

static NSString *MNDirectButtonUserStateNoUserPostfix                = @"ns";  //UserId  = 0, any state: "ns" (NoUser, System idle)
static NSString *MNDirectButtonUserStateOfflineWithUserPostfix       = @"ou";  //UserId != 0, state = 0: "ou" (User connected Offline)
static NSString *MNDirectButtonUserStateConnectingPostfix            = @"cs";  //UserId == 0, state = 1: "cs" (Connecting to server) // Reserved
static NSString *MNDirectButtonUserStateConnectingFromOfflinePostfix = @"cu";  //UserId != 0, state = 1: "cu" (Connecting offline User to server) // Reserved
static NSString *MNDirectButtonUserStateActiveUserPostfix            = @"au";  //UserId != 0, state >= 50: "au" (Active user / user online)

static NSString *MNDirectButtonImageNameFormat = @"%@_%@_%@.png";
static NSString *MNDirectButtonImageNamePrefix = @"mn_direct_button";
static NSString *MNDirectButtonBundlePath      = @"MNDirectButton.bundle/Images/";

@interface MNDirectButton()
+(void) refreshButton;

+(NSString*) getCurrentLocationPostfix;
+(MNDIRECTBUTTON_LOCATION) getRealLocation:(MNDIRECTBUTTON_LOCATION) location
                             atOrientation:(UIInterfaceOrientation) orientation;
+(UIImage*) getButtonImage;
+(CGRect) getButtonFrameForImage:(UIImage*) buttonImage;
+(CGAffineTransform) getButtonTransform;

+(void) updateButtonState;
+(void) markMNButtonAsOffline;
+(void) markMNButtonAsOfflineWithUser;
+(void) markMNButtonAsConnecting;
+(void) markMNButtonAsConnectingFromOffline;
+(void) markMNButtonAsOnline;

+(void) performShowLogic;

+(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus;
+(void) mnSessionUserChangedTo:(MNUserId) userId;
+(void) mnSessionDoStartGameWithParams:(MNGameParams*) params;

+(void) mnUserProfileViewDoGoBack;

@end

@implementation MNDirectButton

+(void) initWithLocation:(MNDIRECTBUTTON_LOCATION) location {
    [MNDirectButton initWithLocation:location andDelegate:[[[MNDirectButtonHandlerFullscreen alloc]init]autorelease]];
}
+(void) initWithLocation:(MNDIRECTBUTTON_LOCATION) location andDelegate:(id<MNDirectButtonDelegate>)delegate {
    if (mnDirectButton != nil) {
        [mnDirectButton removeFromSuperview];
        [mnDirectButton release];
        mnDirectButton = nil; 
    }
    if (mnDirectButtonWindow != nil) {
        mnDirectButtonWindow.hidden = YES;
        [mnDirectButtonWindow release];
        mnDirectButtonWindow = nil;
    }
    
    mnDirectButtonLocation = location;

    [mnDirectButtonDelegate release];
    mnDirectButtonDelegate = delegate;
    [mnDirectButtonDelegate retain];
    
    mnDirectButtonWindow = [[UIWindow alloc]init];
    mnDirectButtonWindow.windowLevel = UIWindowLevelAlert;
    mnDirectButtonWindow.autoresizingMask = UIViewAutoresizingNone;
    mnDirectButton.autoresizingMask = UIViewAutoresizingNone;
    mnDirectButtonOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    mnDirectButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [mnDirectButton addTarget:self action:@selector(mnDirectButtonOnTap:) forControlEvents:UIControlEventTouchUpInside];
    [mnDirectButtonWindow addSubview:mnDirectButton];
    
    //[MNDirectUIHelper      addDelegate:self];
    [[MNDirect getSession] addDelegate:self];
    [[MNDirect getView   ] addDelegate:self];
    
    [MNDirectButton markMNButtonAsOffline];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didRotate:)
                                                name:UIApplicationDidChangeStatusBarOrientationNotification
                                              object:nil];
}

+(void) mnDirectButtonOnTap:(id) sender {
    assert(mnDirectButtonDelegate);
    
    if ([self isAutohide]) {
        [mnDirectButtonDelegate mnDirectButtonDoShowDashboard];
    }
    else {
        if ([mnDirectButtonDelegate mnDirectButtonIsDashboardVisible]) {
            [mnDirectButtonDelegate mnDirectButtonDoHideDashboard];
        }
        else {
            [mnDirectButtonDelegate mnDirectButtonDoShowDashboard];
        }
    }
    
    [MNDirectButton performShowLogic];
}

+(void) show {
    mnDirectButtonVisible = YES;
    [self performShowLogic];
}
+(void) hide {
    mnDirectButtonVisible = NO;
    [self performShowLogic];
}
+(BOOL) isVisible {
    return (![self isHidden]);
}
+(BOOL) isHidden {
    if (mnDirectButtonWindow == nil) return YES;
  
    return !mnDirectButtonVisible;
}

+(void) setFollowStatusBarOrientationEnabled:(BOOL) autorotationFlag {
    mnDirectButtonAutorotationFlag = autorotationFlag;
}
+(BOOL) isFollowStatusBarOrientationEnabled {
    return mnDirectButtonAutorotationFlag;
}

+(void) adjustToOrientation:(UIInterfaceOrientation)orientation {
    if ((orientation != UIInterfaceOrientationPortrait          ) &&
        (orientation != UIInterfaceOrientationPortraitUpsideDown) &&
        (orientation != UIInterfaceOrientationLandscapeLeft     ) &&
        (orientation != UIInterfaceOrientationLandscapeRight    )) {
        orientation = mnDirectButtonOrientationDefault;
    }
    
    mnDirectButtonOrientation = orientation;
    [MNDirectButton refreshButton];
}

+(void) setAutohide:(BOOL) autohideFlag {
    mnDirectButtonAutohideFlag = autohideFlag;
}
+(BOOL) isAutohide {
    return mnDirectButtonAutohideFlag;
}


+(void) didRotate:(NSNotification *)notification {
    if (mnDirectButtonAutorotationFlag) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        [MNDirectButton adjustToOrientation:orientation];
    }
}

+(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus {
    [MNDirectButton updateButtonState];
}
+(void) mnSessionUserChangedTo:(MNUserId) userId {
    [MNDirectButton updateButtonState];
}
+(void) mnSessionDoStartGameWithParams:(MNGameParams*) params {
    assert(mnDirectButtonDelegate);

    [mnDirectButtonDelegate mnDirectButtonDoHideDashboard];
    [MNDirectButton performShowLogic];
}

+(void) mnUserProfileViewDoGoBack {
    assert(mnDirectButtonDelegate);

    [mnDirectButtonDelegate mnDirectButtonDoHideDashboard];
    [MNDirectButton performShowLogic];
}

+(void) refreshButton {
    UIImage  *buttonImage = [MNDirectButton getButtonImage];
    CGRect    buttonRect  = [MNDirectButton getButtonFrameForImage:buttonImage];
    /*
    //[UIView beginAnimations:@"mnDirectButtonAnimation" context:NULL];
    //[UIView setAnimationDuration:0.3];
    mnDirectButtonWindow.frame     = buttonRect;
    mnDirectButton      .frame     = CGRectMake(0,0,buttonRect.size.width,buttonRect.size.height);
    mnDirectButton      .transform = [MNDirectButton getButtonTransform];
    //[UIView commitAnimations];
    */
    mnDirectButtonWindow.transform = [MNDirectButton getButtonTransform];
    mnDirectButtonWindow.frame     = buttonRect;
    mnDirectButton      .frame     = mnDirectButtonWindow.bounds;

    [mnDirectButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
}
+(NSString*) getCurrentLocationPostfix {
    NSString *locationPostfix = @"";

    if      (mnDirectButtonLocation == MNDIRECTBUTTON_TOPLEFT    ) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionTopPostfix,
                           MNDirectButtonPositionLeftPostfix];
    }
    else if (mnDirectButtonLocation == MNDIRECTBUTTON_TOPRIGHT   ) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionTopPostfix,
                           MNDirectButtonPositionRightPostfix];
    }
    else if (mnDirectButtonLocation == MNDIRECTBUTTON_BOTTOMRIGHT) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionBottomPostfix,
                           MNDirectButtonPositionRightPostfix];
    }
    else if (mnDirectButtonLocation == MNDIRECTBUTTON_BOTTOMLEFT ) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionBottomPostfix,
                           MNDirectButtonPositionLeftPostfix];
    }
    else if (mnDirectButtonLocation == MNDIRECTBUTTON_LEFT       ) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionMiddlePostfix,
                           MNDirectButtonPositionLeftPostfix];
    }
    else if (mnDirectButtonLocation == MNDIRECTBUTTON_TOP        ) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionTopPostfix,
                           MNDirectButtonPositionCenterPostfix];
    }
    else if (mnDirectButtonLocation == MNDIRECTBUTTON_RIGHT      ) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionMiddlePostfix,
                           MNDirectButtonPositionRightPostfix];
    }
    else if (mnDirectButtonLocation == MNDIRECTBUTTON_BOTTOM     ) {
        locationPostfix = [NSString stringWithFormat:
                           @"%@%@",
                           MNDirectButtonPositionBottomPostfix,
                           MNDirectButtonPositionCenterPostfix];
    }
 
    return locationPostfix;
}
+(MNDIRECTBUTTON_LOCATION) getRealLocation:(MNDIRECTBUTTON_LOCATION) location
                             atOrientation:(UIInterfaceOrientation) orientation {
    if      (orientation == UIInterfaceOrientationPortrait) {
        return location;
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        switch (location) {
            case (MNDIRECTBUTTON_TOPLEFT    ): return MNDIRECTBUTTON_BOTTOMRIGHT; break;
            case (MNDIRECTBUTTON_TOPRIGHT   ): return MNDIRECTBUTTON_BOTTOMLEFT ; break;
            case (MNDIRECTBUTTON_BOTTOMRIGHT): return MNDIRECTBUTTON_TOPLEFT    ; break;
            case (MNDIRECTBUTTON_BOTTOMLEFT ): return MNDIRECTBUTTON_TOPRIGHT   ; break;
            case (MNDIRECTBUTTON_LEFT       ): return MNDIRECTBUTTON_RIGHT      ; break;
            case (MNDIRECTBUTTON_TOP        ): return MNDIRECTBUTTON_BOTTOM     ; break;
            case (MNDIRECTBUTTON_RIGHT      ): return MNDIRECTBUTTON_LEFT       ; break;
            case (MNDIRECTBUTTON_BOTTOM     ): return MNDIRECTBUTTON_TOP        ; break;
            default                          : return MNDIRECTBUTTON_BOTTOMLEFT ; break;
        }
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight) {
        switch (location) {
            case (MNDIRECTBUTTON_TOPLEFT    ): return MNDIRECTBUTTON_TOPRIGHT   ; break;
            case (MNDIRECTBUTTON_TOPRIGHT   ): return MNDIRECTBUTTON_BOTTOMRIGHT; break;
            case (MNDIRECTBUTTON_BOTTOMRIGHT): return MNDIRECTBUTTON_BOTTOMLEFT ; break;
            case (MNDIRECTBUTTON_BOTTOMLEFT ): return MNDIRECTBUTTON_TOPLEFT    ; break;
            case (MNDIRECTBUTTON_LEFT       ): return MNDIRECTBUTTON_TOP        ; break;
            case (MNDIRECTBUTTON_TOP        ): return MNDIRECTBUTTON_RIGHT      ; break;
            case (MNDIRECTBUTTON_RIGHT      ): return MNDIRECTBUTTON_BOTTOM     ; break;
            case (MNDIRECTBUTTON_BOTTOM     ): return MNDIRECTBUTTON_LEFT       ; break;
            default                          : return MNDIRECTBUTTON_BOTTOMRIGHT; break;
        }
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        switch (location) {
            case (MNDIRECTBUTTON_TOPLEFT    ): return MNDIRECTBUTTON_BOTTOMLEFT ; break;
            case (MNDIRECTBUTTON_TOPRIGHT   ): return MNDIRECTBUTTON_TOPLEFT    ; break;
            case (MNDIRECTBUTTON_BOTTOMRIGHT): return MNDIRECTBUTTON_TOPRIGHT   ; break;
            case (MNDIRECTBUTTON_BOTTOMLEFT ): return MNDIRECTBUTTON_BOTTOMRIGHT; break;
            case (MNDIRECTBUTTON_LEFT       ): return MNDIRECTBUTTON_BOTTOM     ; break;
            case (MNDIRECTBUTTON_TOP        ): return MNDIRECTBUTTON_LEFT       ; break;
            case (MNDIRECTBUTTON_RIGHT      ): return MNDIRECTBUTTON_TOP        ; break;
            case (MNDIRECTBUTTON_BOTTOM     ): return MNDIRECTBUTTON_RIGHT      ; break;
            default                          : return MNDIRECTBUTTON_TOPLEFT    ; break;
        }
    }
    else {
        return MNDIRECTBUTTON_TOPLEFT;
    }
}
+(UIImage*) getButtonImage {
    UIImage  *buttonImage  = nil;

    buttonImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",MNDirectButtonBundlePath,mnDirectButtonImageName]];
    
    if (buttonImage == nil) {
        NSString *newImageName = [NSString stringWithFormat:
                                  MNDirectButtonImageNameFormat,
                                  MNDirectButtonImageNamePrefix,
                                  [MNDirectButton getCurrentLocationPostfix],
                                  MNDirectButtonUserStateNoUserPostfix];

        buttonImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",MNDirectButtonBundlePath,newImageName]];
    }
    
    return buttonImage;
}
+(CGRect) getButtonFrameForImage:(UIImage*) buttonImage {
    CGFloat   buttonLongSideLength;
    CGFloat   buttonShortSideLength;
    CGFloat   screenTop;
    CGFloat   screenLeft;
    CGFloat   screenWidth;
    CGFloat   screenHeight;
    CGFloat   width;
    CGFloat   height;
    CGFloat   top;
    CGFloat   left;
    
    if (UIInterfaceOrientationIsPortrait(mnDirectButtonOrientation)) {
        buttonLongSideLength  = MAX(buttonImage.size.width,buttonImage.size.height);
        buttonShortSideLength = MIN(buttonImage.size.width,buttonImage.size.height);
    }
    else {
        buttonLongSideLength  = MIN(buttonImage.size.width,buttonImage.size.height);
        buttonShortSideLength = MAX(buttonImage.size.width,buttonImage.size.height);
    }
    
    screenTop    = [UIScreen mainScreen].applicationFrame.origin.y;
    screenLeft   = [UIScreen mainScreen].applicationFrame.origin.x;
    screenWidth  = [UIScreen mainScreen].applicationFrame.size.width;
    screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    
    width  = buttonLongSideLength;
    height = buttonShortSideLength;
    
    MNDIRECTBUTTON_LOCATION realLocation = [MNDirectButton getRealLocation:mnDirectButtonLocation atOrientation:mnDirectButtonOrientation];
    
    if (realLocation == MNDIRECTBUTTON_TOP             ) {
        if (UIInterfaceOrientationIsPortrait(mnDirectButtonOrientation)) {
            width  = buttonLongSideLength;
            height = buttonShortSideLength;
        }
        else {
            width  = buttonShortSideLength;
            height = buttonLongSideLength;
        }
        
        top  = screenTop - MNDirectButtonImageCutGap;
        left = (screenWidth - width) / 2;
    }
    else if (realLocation == MNDIRECTBUTTON_BOTTOM     ) {
        if (UIInterfaceOrientationIsPortrait(mnDirectButtonOrientation)) {
            width  = buttonLongSideLength;
            height = buttonShortSideLength;
        }
        else {
            width  = buttonShortSideLength;
            height = buttonLongSideLength;
        }
        
        top  = screenHeight - height + MNDirectButtonImageCutGap;
        left = (screenWidth - width) / 2;
    }
    else if (realLocation == MNDIRECTBUTTON_LEFT       ) {
        if (UIInterfaceOrientationIsPortrait(mnDirectButtonOrientation)) {
            width  = buttonShortSideLength;
            height = buttonLongSideLength;
        }
        else {
            width  = buttonLongSideLength;
            height = buttonShortSideLength;
        }
        
        top  = (screenHeight - height) / 2;
        left = screenLeft - MNDirectButtonImageCutGap;
    }
    else if (realLocation == MNDIRECTBUTTON_RIGHT      ) {
        if (UIInterfaceOrientationIsPortrait(mnDirectButtonOrientation)) {
            width  = buttonShortSideLength;
            height = buttonLongSideLength;
        }
        else {
            width  = buttonLongSideLength;
            height = buttonShortSideLength;
        }
        
        top  = (screenHeight - height) / 2;
        left = screenWidth - width + MNDirectButtonImageCutGap;
    }
    else if (realLocation == MNDIRECTBUTTON_TOPLEFT    ) {
        top  = screenTop  - MNDirectButtonImageCutGap;
        left = screenLeft - MNDirectButtonImageCutGap;
    }
    else if (realLocation == MNDIRECTBUTTON_BOTTOMRIGHT) {
        top  = screenHeight - height + MNDirectButtonImageCutGap;
        left = screenWidth  - width  + MNDirectButtonImageCutGap;
    }
    else if (realLocation == MNDIRECTBUTTON_BOTTOMLEFT ) {
        top  = screenHeight - height + MNDirectButtonImageCutGap;
        left = screenLeft - MNDirectButtonImageCutGap;
    }
    else {
        //MNDIRECTBUTTON_TOPRIGHT - by default
        top  = screenTop - MNDirectButtonImageCutGap;
        left = screenWidth  - width + MNDirectButtonImageCutGap;
    }

    return CGRectMake(left,top,width,height);
}
+(CGAffineTransform) getButtonTransform {
    CGAffineTransform buttonTransform;
    
    if      (mnDirectButtonOrientation == UIInterfaceOrientationPortrait          ) {
        buttonTransform = CGAffineTransformMakeRotation(0);
    }
    else if (mnDirectButtonOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        buttonTransform = CGAffineTransformMakeRotation((CGFloat)M_PI);
    }
    else if (mnDirectButtonOrientation == UIInterfaceOrientationLandscapeLeft     ) {
        buttonTransform = CGAffineTransformMakeRotation((CGFloat)-M_PI_2);
    }
    else if (mnDirectButtonOrientation == UIInterfaceOrientationLandscapeRight    ) {
        buttonTransform = CGAffineTransformMakeRotation((CGFloat)M_PI_2);
    }
    
    return buttonTransform;
}

+(void) updateButtonState {
    MNUserId userId	= [[MNDirect getSession] getMyUserId];
    MNUserId state	= [[MNDirect getSession] getStatus  ];
    
    if      (state == MN_OFFLINE) {
        if      (userId == 0) {
            [self markMNButtonAsOffline];
        }
        else {
            [self markMNButtonAsOfflineWithUser];
        }
    }
    else if (state == MN_CONNECTING) {
        if      (userId == 0) {
            [self markMNButtonAsConnecting];
        }
        else {
            [self markMNButtonAsConnectingFromOffline];
        }
    }
    else
    {
        [MNDirectButton markMNButtonAsOnline];
    }
}
+(void) markMNButtonAsOffline {
    NSString *newImageName = [NSString stringWithFormat:
                              MNDirectButtonImageNameFormat,
                              MNDirectButtonImageNamePrefix,
                              [MNDirectButton getCurrentLocationPostfix],
                              MNDirectButtonUserStateNoUserPostfix];
    
    if (![mnDirectButtonImageName isEqualToString:newImageName]) {
        [mnDirectButtonImageName release];
        mnDirectButtonImageName = newImageName;
        [mnDirectButtonImageName retain];
        
        [MNDirectButton refreshButton];
    }
}
+(void) markMNButtonAsOfflineWithUser {
    NSString *newImageName = [NSString stringWithFormat:
                              MNDirectButtonImageNameFormat,
                              MNDirectButtonImageNamePrefix,
                              [MNDirectButton getCurrentLocationPostfix],
                              MNDirectButtonUserStateOfflineWithUserPostfix];
    
    if (![mnDirectButtonImageName isEqualToString:newImageName]) {
        [mnDirectButtonImageName release];
        mnDirectButtonImageName = newImageName;
        [mnDirectButtonImageName retain];
        
        [MNDirectButton refreshButton];
    }
}
+(void) markMNButtonAsConnecting {
    NSString *newImageName = [NSString stringWithFormat:
                              MNDirectButtonImageNameFormat,
                              MNDirectButtonImageNamePrefix,
                              [MNDirectButton getCurrentLocationPostfix],
                              MNDirectButtonUserStateConnectingPostfix];
    
    if (![mnDirectButtonImageName isEqualToString:newImageName]) {
        [mnDirectButtonImageName release];
        mnDirectButtonImageName = newImageName;
        [mnDirectButtonImageName retain];
        
        [MNDirectButton refreshButton];
    }
}
+(void) markMNButtonAsConnectingFromOffline {
    NSString *newImageName = [NSString stringWithFormat:
                              MNDirectButtonImageNameFormat,
                              MNDirectButtonImageNamePrefix,
                              [MNDirectButton getCurrentLocationPostfix],
                              MNDirectButtonUserStateConnectingFromOfflinePostfix];
    
    if (![mnDirectButtonImageName isEqualToString:newImageName]) {
        [mnDirectButtonImageName release];
        mnDirectButtonImageName = newImageName;
        [mnDirectButtonImageName retain];
        
        [MNDirectButton refreshButton];
    }
}
+(void) markMNButtonAsOnline {
    NSString *newImageName = [NSString stringWithFormat:
                              MNDirectButtonImageNameFormat,
                              MNDirectButtonImageNamePrefix,
                              [MNDirectButton getCurrentLocationPostfix],
                              MNDirectButtonUserStateActiveUserPostfix];
    
    if (![mnDirectButtonImageName isEqualToString:newImageName]) {
        [mnDirectButtonImageName release];
        mnDirectButtonImageName = newImageName;
        [mnDirectButtonImageName retain];
        
        [MNDirectButton refreshButton];
    }
}

+(void) performShowLogic {
    if (mnDirectButtonWindow != nil) {
        if ([self isHidden]) {
            mnDirectButtonWindow.hidden = YES;
        }
        else {
            if ([self isAutohide]) {
                assert(mnDirectButtonDelegate);

                if ([mnDirectButtonDelegate mnDirectButtonIsDashboardVisible]) {
                    mnDirectButtonWindow.hidden = YES;
                }
                else {
                    mnDirectButtonWindow.hidden = NO;
                }    
            }
            else {
                //DO NOTHING
                //mnDirectButtonWindow.hidden = NO;
            }
        }
    }
}

+(void) notifyPopoverClosed {
    [self performShowLogic];
}

@end

@implementation MNDirectButtonHandlerFullscreen

-(id) init {
    self = [super init];

    [MNDirectUIHelper addDelegate:self];
    
    return self;
}
-(void) dealloc {
    [super dealloc];
}

-(void) mnDirectButtonDoShowDashboard {
    [MNDirectUIHelper showDashboard];
}
-(void) mnDirectButtonDoHideDashboard {
    [MNDirectUIHelper hideDashboard];
}
-(BOOL) mnDirectButtonIsDashboardVisible {
    return [MNDirectUIHelper isDashboardVisible];
}

-(void) mnUIHelperDashboardHidden {
    [MNDirectButton performShowLogic];
}
-(void) mnUIHelperDashboardShown {
    [MNDirectButton performShowLogic];
}

@end

#define MNDirectButtonHandlerPopoverDefSize (CGSizeMake(500,500))

@implementation MNDirectButtonHandlerPopover

@synthesize popoverContentSize;

-(id) init {
    self = [super init];
    
    if (self) {
        [MNDirectButton setAutohide:NO];
        [MNDirectUIHelper addDelegate:self];
        self.popoverContentSize = MNDirectButtonHandlerPopoverDefSize;
    }
    
    return self;
}
-(void) dealloc {
    [MNDirectButton setAutohide:NO];
    [MNDirectUIHelper removeDelegate:self];
    
    [super dealloc];
}

-(void) mnDirectButtonDoShowDashboard {
    [MNDirectUIHelper showDashboardInPopoverWithSize:self.popoverContentSize fromRect:mnDirectButtonWindow.frame];
}
-(void) mnDirectButtonDoHideDashboard {
    [MNDirectUIHelper hideDashboard];
}
-(BOOL) mnDirectButtonIsDashboardVisible {
    return [MNDirectUIHelper isDashboardVisible];
}

-(void) mnUIHelperDashboardHidden {
    [MNDirectButton notifyPopoverClosed];
}
-(BOOL) mnUIHelperShouldDismissPopover {
    return YES;
}


@end
