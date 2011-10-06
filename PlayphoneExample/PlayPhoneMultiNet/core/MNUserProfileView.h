//
//  MNUserProfileView.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/21/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MNSession.h"
#import "MNABImportDialogView.h"
#import "MNABImportTableViewDataSource.h"
#import "MNStrMaskStorage.h"
#import "MNUIWebViewHttpReqQueue.h"
#import "MNDelegateArray.h"

#define MN_IMAGE_SOURCE_MAX_COUNT (3)

typedef struct {
    NSInteger buttonIndex;
    NSUInteger imageSourceType;
} MNUserProfileViewImageSourceSelectorType;

@protocol MNUserProfileViewDelegate;

/**
 * @brief View which allows user to interact with MultiNet server.
 */
@interface MNUserProfileView : UIView<UIWebViewDelegate,
                                      MNSessionDelegate,
                                      MNSessionSocNetFBDelegate,
                                      MNABImportDelegate,
                                      UIActionSheetDelegate,
                                      MNSocNetFBStreamDialogDelegate,
                                      MNSocNetFBPermissionDialogDelegate,
                                      MNUIWebViewHttpReqQueueDelegate> {
    @private

    UIWebView* _webView;
    BOOL _errorPageLoaded;
    UIWebView* _navBarWebView;
    NSString* _navBarCurrentURL;
    UIActivityIndicatorView* activityIndicator;
    NSString* baseHost;
    NSMutableSet* _trustedHosts;
    MNSession* _session;
    NSString* _webServerURL;
    MNDelegateArray* _delegates;
    MNStrMaskStorage* trackedPluginsStorage;

    BOOL autoCancelGameOnGoBack;

    BOOL startPageLoaded;
    BOOL startNavLoaded;
    BOOL bootPageLoaded;
    BOOL statusChangedPending;
    NSMutableString* pendingChatMessages;
    BOOL contextCallWaitLoad;
    NSString* deviceUsersInfoJSSrc;

    UIActionSheet* imageSourceActionSheet;
    NSUInteger availableImageSourceCount;
    MNUserProfileViewImageSourceSelectorType imageSourceSelectors[MN_IMAGE_SOURCE_MAX_COUNT];

    NSString* _fbLoginSuccessJS;
    NSString* _fbLoginCancelJS;
    NSString* _fbPublishSuccessJS;
    NSString* _fbPublishCancelJS;
    NSString* _fbPermissionSuccessJS;
    NSString* _fbPermissionCancelJS;

    MNUIWebViewHttpReqQueue* _httpReqQueue;
}

/**
 * The delegate
 *
 * @deprecated Use addDelegate: and removeDelegate: methods instead
 */
@property (nonatomic,assign,getter=getDelegate,setter=setDelegate:) id<MNUserProfileViewDelegate> delegate;

/**
 * Boolean flag indicating if cancelGameWithParams: should be sent to session if
 * user clicked on "Go back" button(link).
 */
@property (nonatomic,assign) BOOL autoCancelGameOnGoBack;

/**
 * Initializes and return newly allocated object with specified frame rectangle. To complete
 * view initialization bindToSession: message must be sent to bind particular MNSession
 * instance to view.
 * @param frame frame rectangle
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithFrame:(CGRect) frame;
/**
 * Initializes instance after it has been loaded from nib file.
 */
-(void) awakeFromNib;
/**
 * Release all acquired resources.
 */
-(void) dealloc;

/**
 * Bind MultiNet session instance to view and load MultiNet start page.
 * @param session MNSession object instance to use with current view
 */
-(void) bindToSession:(MNSession*) session;

/**
 * Adds delegate
 * @param delegate an object conforming to MNUserProfileViewDelegate protocol
 */
-(void) addDelegate:(id<MNUserProfileViewDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNUserProfileViewDelegate>) delegate;
@end

/**
 * @brief MNUserProvileView delegate protocol.
 *
 * By implementing methods of MNUserProfileDelegate protocol, the delegate can handle
 * events such as clicks on "Go back" and "Logout" buttons(links) in MNUserProfileView
 * instance.
 */
@protocol MNUserProfileViewDelegate<NSObject>
@optional

/**
 * Tells the delegate that user clicked on "Go back" button(link).
 */
-(void) mnUserProfileViewDoGoBack;

@end
