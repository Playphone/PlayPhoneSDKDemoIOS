//
//  MNDirectPopup.m
//  MultiNet client
//
//  Created by Vladislav Ogol on 27.09.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNDirect.h"
#import "MNUIUrlImageView.h"
#import "MNAchievementsProvider.h"
#import "MNMyHiScoresProvider.h"
#import "MNTools.h"

#import "MNDirectPopup.h"

#pragma mark -

static NSString *MNDirectPopupParamsDefCallbackId  = @"";

@interface MNDirectPopupParams : NSObject {
    NSUInteger popupAction;
    NSString  *text;
    UIImage   *defaultImage;
    NSURL     *imageUrl;
    NSString  *callbackId;
}

@property (nonatomic,assign) NSUInteger popupAction;
@property (nonatomic,retain) NSString  *text;
@property (nonatomic,retain) UIImage   *defaultImage;
@property (nonatomic,retain) NSURL     *imageUrl;
@property (nonatomic,retain) NSString  *callbackId;


-(id) initWithPopupAction:(MNDIRECTPOPUP_ACTION) action text:(NSString*) messageText defaultImage:(UIImage*) image imageUrl:(NSURL*) url;
-(void) dealloc;

@end

#pragma mark -

@interface MNDirectPopupView : UIView {
    UIImageView      *bgrLeftImageView;
    UIImageView      *bgrImageView;
    UIImageView      *bgrRightImageView;
    MNUIUrlImageView *avatarUrlImageView;
    UILabel          *messageLabel;

    NSTimer             *showTimer;
    NSMutableArray      *paramsArray;
    MNDirectPopupParams *currentShowParams;
    
    NSUInteger        fixedHeight;
}

@property (nonatomic,retain) NSTimer                *showTimer;
@property (nonatomic,retain) NSMutableArray         *paramsArray;
@property (nonatomic,retain) MNDirectPopupParams    *currentShowParams;
@property (nonatomic,assign) NSUInteger              fixedHeight;

-(void) showWithParams:(MNDirectPopupParams*) params;

-(void) updateWithParams:(MNDirectPopupParams*) params;
-(void) close;

@end

#pragma mark -

static MNDIRECTPOPUP_ACTION   mnDirectPopupActionBitMask      = 0;
static UIWindow              *mnDirectPopupWindow             = nil;
static MNDirectPopupView     *mnDirectPopupView               = nil;
static BOOL                   mnDirectPopupActiveFlag         = NO;
static BOOL                   mnDirectPopupAutorotationFlag   = YES;
static UIInterfaceOrientation mnDirectPopupOrientation        = UIDeviceOrientationUnknown;
static UIInterfaceOrientation mnDirectPopupOrientationDefault = UIInterfaceOrientationPortrait;

static BOOL      MNDirectPopupAchievemntsListAutoUpdate       = YES;

static NSString *MNDirectPopupWelcomeMessageFormat            = @"Welcome %@";
static NSString *MNDirectPopupNewHiScoreMessage               = @"You achieved a new High Score";

static NSString *MNDirectPopupWebEventName                    = @"web.ui.doPopupShow";
static NSString *MNDirectPopupWebEventMessgaeParamName        = @"popupMessage";
static NSString *MNDirectPopupWebEventMessgaeParamImageURL    = @"popupImageUrl";

static NSString *MNDirectPopupOnClickSysEventName             = @"sys.ui.onPopupClick";
static NSString *MNDirectPopupOnClickSysEventActionParamName  = @"action";
static NSString *MNDirectPopupOnClickSysEventClickXParamName  = @"clickX";
static NSString *MNDirectPopupOnClickSysEventClickYParamName  = @"clickY";


#define MNDirectPopuClickCoordinateUnavailable             (-1)

#define MNDirectPopupShowTime                              (3)
#define MNDirectPopupShowHideAnimationDuration             (0.5)


@implementation MNDirectPopup

+(void) init:(MNDIRECTPOPUP_ACTION) actionsBitMask {
    if (mnDirectPopupView != nil) {
        [mnDirectPopupView removeFromSuperview];
        [mnDirectPopupView release];
        mnDirectPopupView = nil;
    }

    if (mnDirectPopupWindow != nil) {
        mnDirectPopupWindow.hidden = YES;
        [mnDirectPopupWindow release];
        mnDirectPopupWindow = nil;
    }
    
    mnDirectPopupActionBitMask = actionsBitMask;

    mnDirectPopupView = [[MNDirectPopupView alloc]init];
    mnDirectPopupView.hidden = YES;
    
    
    mnDirectPopupWindow = [[UIWindow alloc] initWithFrame:mnDirectPopupView.bounds];
    mnDirectPopupWindow.windowLevel      = UIWindowLevelAlert;
    mnDirectPopupWindow.backgroundColor  = [UIColor clearColor];
    
    [mnDirectPopupWindow addSubview:mnDirectPopupView];

    mnDirectPopupOrientation = UIDeviceOrientationUnknown;
    [MNDirectPopup adjustToOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    mnDirectPopupActiveFlag = YES;
    [[MNDirect getSession] addDelegate:(id)self];
    
    if (actionsBitMask & MNDIRECTPOPUP_ACHIEVEMENTS) {
        [[MNDirect achievementsProvider] addDelegate:(id)self];
    }
    
    if (actionsBitMask & MNDIRECTPOPUP_NEW_HI_SCORES) {
        [[MNDirect myHiScoresProvider] addDelegate:(id)self];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didRotate:)
                                                name:UIApplicationDidChangeStatusBarOrientationNotification
                                              object:nil];
}

+(BOOL) isActive {
    return mnDirectPopupActiveFlag;
}

+(void) setActive:(BOOL) activeFlag {
    mnDirectPopupActiveFlag = activeFlag;
}

+(void) setFollowStatusBarOrientationEnabled:(BOOL) autorotationFlag {
    mnDirectPopupAutorotationFlag = autorotationFlag;
}

+(BOOL) isFollowStatusBarOrientationEnabled {
    return mnDirectPopupAutorotationFlag;
}

+(void) adjustToOrientation:(UIInterfaceOrientation)orientation {
    if ((orientation != UIInterfaceOrientationPortrait          ) &&
        (orientation != UIInterfaceOrientationPortraitUpsideDown) &&
        (orientation != UIInterfaceOrientationLandscapeLeft     ) &&
        (orientation != UIInterfaceOrientationLandscapeRight    )) {
        orientation = mnDirectPopupOrientationDefault;
    }
    
    if (mnDirectPopupOrientation != orientation) {
        CGFloat screenTop    = [UIScreen mainScreen].applicationFrame.origin.y;
        CGFloat screenLeft   = [UIScreen mainScreen].applicationFrame.origin.x;
        CGFloat screenWidth  = [UIScreen mainScreen].applicationFrame.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
        CGRect  windowRect;

        mnDirectPopupOrientation = orientation;
        
        if      (orientation == UIInterfaceOrientationPortrait) {
            mnDirectPopupWindow.transform = CGAffineTransformMakeRotation(0);
            windowRect = CGRectMake(screenLeft,screenTop,screenWidth,mnDirectPopupView.fixedHeight);
        }
        else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            mnDirectPopupWindow.transform = CGAffineTransformMakeRotation(M_PI);
            windowRect = CGRectMake(screenLeft,screenHeight - mnDirectPopupView.fixedHeight,screenWidth,mnDirectPopupView.fixedHeight);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight) {
            mnDirectPopupWindow.transform = CGAffineTransformMakeRotation(M_PI_2);
            windowRect = CGRectMake(screenWidth - mnDirectPopupView.fixedHeight,screenTop,mnDirectPopupView.fixedHeight,screenHeight);
        }
        else if (orientation == UIInterfaceOrientationLandscapeLeft) {
            mnDirectPopupWindow.transform = CGAffineTransformMakeRotation(-M_PI_2);
            windowRect = CGRectMake(screenLeft,screenTop,mnDirectPopupView.fixedHeight,screenHeight);
        }
        else {
            mnDirectPopupOrientation = UIInterfaceOrientationPortrait;
            
            mnDirectPopupWindow.transform = CGAffineTransformMakeRotation(0);
            windowRect = CGRectMake(screenLeft,screenTop,screenWidth,mnDirectPopupView.fixedHeight);
        }
        
        mnDirectPopupWindow.frame = windowRect;
        mnDirectPopupView.frame = mnDirectPopupWindow.bounds;
    }
}

+(void) didRotate:(NSNotification *)notification {
    if (mnDirectPopupAutorotationFlag) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        [MNDirectPopup adjustToOrientation:orientation];
    }
}

#pragma mark MNSessionDelegate

+(void) mnSessionUserChangedTo:(MNUserId) userId {
    if (mnDirectPopupActiveFlag) {
        if (mnDirectPopupActionBitMask & MNDIRECTPOPUP_WELCOME) {
            if (userId != 0) {
                MNUserInfo *myUserInfo = [[MNDirect getSession]getMyUserInfo];
                MNDirectPopupParams *params = [[MNDirectPopupParams alloc]initWithPopupAction:MNDIRECTPOPUP_WELCOME
                                                                                         text:[NSString stringWithFormat:MNDirectPopupWelcomeMessageFormat,myUserInfo.userName]
                                                                                 defaultImage:[UIImage imageNamed:@"MNDirectPopup.bundle/Images/mndirectpopup_avatar_empty.png"]
                                                                                     imageUrl:[NSURL URLWithString:[myUserInfo getAvatarUrl]]];
                
                [mnDirectPopupView showWithParams:params];
                
                [params release];
            }
        }
    }
}

+(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus {
    if ((MNDirectPopupAchievemntsListAutoUpdate) && 
        (mnDirectPopupActionBitMask & MNDIRECTPOPUP_ACHIEVEMENTS)) {
        
        if (((oldStatus == MN_OFFLINE) || (oldStatus == MN_CONNECTING)) &&
            (newStatus == MN_LOGGEDIN)) {
            
            if ([[MNDirect achievementsProvider] isGameAchievementListNeedUpdate]) {
                [[MNDirect achievementsProvider] doGameAchievementListUpdate];
            }
        }            
    }
}

+(void) mnSessionWebEventReceived:(NSString*) eventName withParam:(NSString*) eventParam andCallbackId:(NSString*) callbackId {
    // Web event can not be disabled
    //if (mnDirectPopupActionBitMask & MNDIRECTPOPUP_WEB_EVENT) {
        if ([eventName compare:MNDirectPopupWebEventName] == NSOrderedSame) {
            NSDictionary* paramsDict = MNCopyDictionaryWithGetRequestParamString(eventParam);
            
            NSString *popupText      = [paramsDict valueForKey:MNDirectPopupWebEventMessgaeParamName];
            NSString *imageUrlString = [paramsDict valueForKey:MNDirectPopupWebEventMessgaeParamImageURL];
            NSURL    *imageUrl       = [NSURL URLWithString:imageUrlString];
            
            if ((popupText != nil) && (imageUrl != nil)) {
                MNDirectPopupParams *showParams = [[MNDirectPopupParams alloc]initWithPopupAction:MNDIRECTPOPUP_WEB_EVENT
                                                                                             text:popupText
                                                                                     defaultImage:nil
                                                                                         imageUrl:imageUrl];
                
                showParams.callbackId = callbackId;
                
                [mnDirectPopupView showWithParams:showParams];
                
                [showParams release];
            }
            
            [paramsDict release];
        }
    //}
}

#pragma mark MNAchievementsProviderDelegate

+(void) onPlayerAchievementUnlocked:(int) achievementId {
    NSArray *achList = [[MNDirect achievementsProvider] getGameAchievementList];
    MNGameAchievementInfo *achInfo = nil;
    NSUInteger index = 0;
    
    while ((achInfo == nil) && (index < [achList count])) {
        achInfo = [achList objectAtIndex:index];

        if (achInfo.achievementId != achievementId) {
            achInfo = nil;
            index++;
        }
    }
    
    if (achInfo != nil) {
        MNDirectPopupParams *showParams = [[MNDirectPopupParams alloc]initWithPopupAction:MNDIRECTPOPUP_ACHIEVEMENTS
                                                                                     text:achInfo.name
                                                                             defaultImage:nil
                                                                                 imageUrl:[[MNDirect achievementsProvider] getAchievementImageURL:achievementId]];
        [mnDirectPopupView showWithParams:showParams];
    
        [showParams release];
    }
}

#pragma mark MNMyHiScoresProvider

+(void) hiScoreUpdated:(NSInteger) newScore gameSetId:(NSInteger) gameSetId periodMask:(unsigned int) periodMask {
    MNDirectPopupParams *showParams = [[MNDirectPopupParams alloc]initWithPopupAction:MNDIRECTPOPUP_NEW_HI_SCORES
                                                                                 text:MNDirectPopupNewHiScoreMessage
                                                                         defaultImage:[UIImage imageNamed:@"MNDirectPopup.bundle/Images/mndirectpopup_newhiscore.png"]
                                                                             imageUrl:nil];
    [mnDirectPopupView showWithParams:showParams];
    
    [showParams release];
}

@end

#pragma mark -

@implementation MNDirectPopupParams

@synthesize text;
@synthesize defaultImage;
@synthesize imageUrl;
@synthesize popupAction;
@synthesize callbackId;

-(id) initWithPopupAction:(MNDIRECTPOPUP_ACTION) action text:(NSString*) messageText defaultImage:(UIImage*) image imageUrl:(NSURL*) url {
    if (self = [super init]) {
        self.popupAction  = action;
        self.text         = messageText;
        self.defaultImage = image;
        self.imageUrl     = url;
        
        self.callbackId   = MNDirectPopupParamsDefCallbackId;
    }
    
    return self;
}

-(void) dealloc {
    self.popupAction  = -1;
    self.text         = nil;
    self.defaultImage = nil;
    self.imageUrl     = nil;
    self.callbackId   = nil;
    
    [super dealloc];
}

@end

#pragma mark -
@implementation MNDirectPopupView

@synthesize showTimer;
@synthesize paramsArray;
@synthesize fixedHeight;
@synthesize currentShowParams;

static NSString *MNDirectPopupSettingsImageXOffset       = @"image-offset-x";
static NSString *MNDirectPopupSettingsImageYOffset       = @"image-offset-y";
static NSString *MNDirectPopupSettingsLabelXOffset       = @"label-offset-x";
static NSString *MNDirectPopupSettingsLabelYOffset       = @"label-offset-y";
static NSString *MNDirectPopupSettingsLabelXBackOffset   = @"label-back-offset-x";
static NSString *MNDirectPopupSettingsLabelYBackOffset   = @"label-back-offset-y";
static NSString *MNDirectPopupSettingsLabelColorR        = @"label-color-r";
static NSString *MNDirectPopupSettingsLabelColorG        = @"label-color-g";
static NSString *MNDirectPopupSettingsLabelColorB        = @"label-color-b";
static NSString *MNDirectPopupSettingsLabelFontSize      = @"label-font-size";
static NSString *MNDirectPopupSettingsLabelFontName      = @"label-font-name";
static NSString *MNDirectPopupSettingsLabelShadowColorR  = @"label-shadow-color-r";
static NSString *MNDirectPopupSettingsLabelShadowColorG  = @"label-shadow-color-g";
static NSString *MNDirectPopupSettingsLabelShadowColorB  = @"label-shadow-color-b";
static NSString *MNDirectPopupSettingsLabelShadowXOffset = @"label-shadow-offset-x";
static NSString *MNDirectPopupSettingsLabelShadowYOffset = @"label-shadow-offset-y";

-(id) init {
    if (self = [super init]) {
        self.paramsArray = [[[NSMutableArray alloc]init]autorelease];

        bgrLeftImageView = [[UIImageView alloc]init];
        bgrLeftImageView.image = [UIImage imageNamed:@"MNDirectPopup.bundle/Images/mn_direct_popup_l.png"];
        bgrLeftImageView.frame = CGRectMake(0,0,bgrLeftImageView.image.size.width,bgrLeftImageView.image.size.height);
        bgrLeftImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        bgrLeftImageView.contentMode = UIViewContentModeScaleToFill;
        
        bgrImageView = [[UIImageView alloc]init];
        bgrImageView.image = [UIImage imageNamed:@"MNDirectPopup.bundle/Images/mn_direct_popup_m.png"];
        bgrImageView.frame = CGRectMake(bgrLeftImageView.frame.size.width,0,bgrImageView.image.size.width,bgrImageView.image.size.height);
        bgrImageView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        bgrImageView.contentMode = UIViewContentModeScaleToFill;

        bgrRightImageView = [[UIImageView alloc]init];
        bgrRightImageView.image = [UIImage imageNamed:@"MNDirectPopup.bundle/Images/mn_direct_popup_r.png"];
        bgrRightImageView.frame = CGRectMake(bgrLeftImageView.frame.size.width + bgrImageView.frame.size.width,0,
                                             bgrRightImageView.image.size.width,bgrRightImageView.image.size.height);
        bgrRightImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        bgrRightImageView.contentMode = UIViewContentModeScaleToFill;

        self.fixedHeight = MAX(MAX(bgrLeftImageView.image.size.height,bgrImageView.image.size.height),bgrRightImageView.image.size.height);
        
        self.frame = CGRectMake(0,
                                0,
                                bgrLeftImageView.image.size.width + bgrImageView.image.size.width + bgrRightImageView.image.size.width,
                                self.fixedHeight);

        [self addSubview:bgrLeftImageView];
        [self addSubview:bgrRightImageView];
        [self addSubview:bgrImageView];
        

        self.frame = CGRectMake(0,
                                0,
                                MIN([UIScreen mainScreen].applicationFrame.size.width,
                                    [UIScreen mainScreen].applicationFrame.size.height),
                                self.fixedHeight);
        
        NSString *propertiesFilePath = [[[NSBundle mainBundle] bundlePath]
                                        stringByAppendingPathComponent:@"MNDirectPopup.bundle/MNDirectPopupSetup.plist"];
        
        NSMutableDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:propertiesFilePath];
        
        NSInteger imageXOffset       = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsImageXOffset      ])integerValue];
        NSInteger imageYOffset       = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsImageYOffset      ])integerValue];
        NSInteger labelXOffset       = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelXOffset      ])integerValue];
        NSInteger labelYOffset       = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelYOffset      ])integerValue];
        NSInteger labelXBackOffset   = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelXBackOffset  ])integerValue];
        NSInteger labelYBackOffset   = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelYBackOffset  ])integerValue];
        NSInteger labelColorR        = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelColorR       ])integerValue];
        NSInteger labelColorG        = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelColorG       ])integerValue];
        NSInteger labelColorB        = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelColorB       ])integerValue];
        NSInteger labelFontSize      = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelFontSize     ])integerValue];
        NSString *labelFontName      = [dictionary valueForKey:MNDirectPopupSettingsLabelFontName];
        NSInteger labelShadowColorR  = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelShadowColorR ])integerValue];
        NSInteger labelShadowColorG  = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelShadowColorG ])integerValue];
        NSInteger labelShadowColorB  = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelShadowColorB ])integerValue];
        NSInteger labelShadowXOffset = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelShadowXOffset])integerValue];
        NSInteger labelShadowYOffset = [((NSNumber*)[dictionary valueForKey:MNDirectPopupSettingsLabelShadowYOffset])integerValue];
        
        avatarUrlImageView = [[MNUIUrlImageView alloc]initWithImage:[UIImage imageNamed:@"MNDirectPopup.bundle/Images/mndirectpopup_avatar_empty.png"]];

        avatarUrlImageView.frame = CGRectMake(imageXOffset,
                                              imageYOffset,
                                              avatarUrlImageView.frame.size.width,
                                              avatarUrlImageView.frame.size.height);

        avatarUrlImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;

        [self addSubview:avatarUrlImageView];

        messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelXOffset,
                                                                labelYOffset,
                                                                self.frame.size.width  - labelXBackOffset - labelXOffset,
                                                                labelYBackOffset - labelYOffset)];
        
        messageLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        messageLabel.autoresizingMask   = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        messageLabel.font               = [UIFont fontWithName:labelFontName
                                                          size:labelFontSize];
        messageLabel.textColor          = [UIColor colorWithRed:labelColorR/255.0
                                                          green:labelColorG/255.0
                                                           blue:labelColorB/255.0
                                                          alpha:1];
        messageLabel.shadowColor        = [UIColor colorWithRed:labelShadowColorR/255.0
                                                          green:labelShadowColorG/255.0
                                                           blue:labelShadowColorB/255.0
                                                          alpha:1];
        messageLabel.shadowOffset       = CGSizeMake(labelShadowXOffset,labelShadowYOffset);
        messageLabel.minimumFontSize    = 13;
        messageLabel.backgroundColor    = [UIColor clearColor];
        messageLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:messageLabel];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

-(void) dealloc {
    [self.showTimer invalidate];

    self.currentShowParams = nil;
    self.showTimer         = nil;
    self.paramsArray       = nil;

    [bgrLeftImageView   removeFromSuperview];
    [bgrImageView       removeFromSuperview];
    [bgrRightImageView  removeFromSuperview];
    [avatarUrlImageView removeFromSuperview];
    [messageLabel       removeFromSuperview];
    
    [bgrLeftImageView   release];
    [bgrImageView       release];
    [bgrRightImageView  release];
    [avatarUrlImageView release];
    [messageLabel       release];
    
    [super dealloc];
}

-(void) showWithParams:(MNDirectPopupParams*) params {
    
    mnDirectPopupWindow.hidden = NO;
    if (self.showTimer == nil) {
        self.frame  = self.superview.bounds;
        self.center = CGPointMake(self.superview.bounds.size.width * 0.5,-self.superview.bounds.size.height * 0.5);
        
        self.hidden = NO;
        
        [self updateWithParams:params];
        
        [UIView beginAnimations:@"MNBarShowAnimation" context:nil];
        [UIView setAnimationDuration:MNDirectPopupShowHideAnimationDuration];
        
        self.frame = self.superview.bounds;
        
        [UIView commitAnimations];
        
        self.showTimer = [NSTimer scheduledTimerWithTimeInterval:MNDirectPopupShowTime + MNDirectPopupShowHideAnimationDuration
                                                          target:self
                                                        selector:@selector(showTimerFire:)
                                                        userInfo:nil
                                                         repeats:NO];
    }
    else {
        [self.paramsArray addObject:params];
    }
}

-(void) updateWithParams:(MNDirectPopupParams*) params {
    self.currentShowParams = params;
    
    avatarUrlImageView.image = params.defaultImage;
    messageLabel.text        = params.text;
    
    if (params.imageUrl != nil) {
        [avatarUrlImageView loadImageWithUrl:params.imageUrl];
    }
}

-(void) close {
    [self.showTimer invalidate];
    self.showTimer = nil;
    
    [UIView beginAnimations:@"MNBarShowAnimation" context:nil];
    [UIView setAnimationDuration:MNDirectPopupShowHideAnimationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];

    self.center = CGPointMake(self.superview.bounds.size.width * 0.5,-self.superview.bounds.size.height * 0.5);

    [UIView commitAnimations];
}

-(void) showTimerFire:(NSTimer*) timer {
    if ([self.paramsArray count] > 0) {
        [self.showTimer invalidate];
        self.showTimer = nil;
        
        self.showTimer = [NSTimer scheduledTimerWithTimeInterval:MNDirectPopupShowTime
                                                          target:self
                                                        selector:@selector(showTimerFire:)
                                                        userInfo:nil
                                                         repeats:NO];
        
        MNDirectPopupParams *curParams = [self.paramsArray objectAtIndex:0];
        
        [self updateWithParams:curParams];
        
        [self.paramsArray removeObjectAtIndex:0];
    }
    else {
        [self close];
    }
}

-(void) hideAnimationDidStop:(NSString*) animationID finished:(NSNumber*) finished context:(void*) context {
    self.currentShowParams     = nil;
    mnDirectPopupWindow.hidden = YES;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        MNSession *session = [MNDirect getSession];
        
        if (session != nil) {
            CGPoint touchLocation = [touch locationInView:self];
            NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]init];
            
            [paramsDict setValue:[NSString stringWithFormat:@"0x%02X",self.currentShowParams.popupAction]
                          forKey:MNDirectPopupOnClickSysEventActionParamName];
            
            [paramsDict setValue:[NSString stringWithFormat:@"%d",(int)touchLocation.x]
                          forKey:MNDirectPopupOnClickSysEventClickXParamName];
            
            [paramsDict setValue:[NSString stringWithFormat:@"%d",(int)touchLocation.y]
                          forKey:MNDirectPopupOnClickSysEventClickYParamName];
            
            NSString *paramsString = MNGetRequestStringFromParams(paramsDict);
            
            [session postSysEvent:MNDirectPopupOnClickSysEventName
                        withParam:paramsString
                    andCallbackId:self.currentShowParams.callbackId];
            
            [paramsDict release];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

@end
