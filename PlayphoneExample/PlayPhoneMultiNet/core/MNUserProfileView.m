//
//  MNUserProfileView.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/21/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNTools.h"
#import "MNUserInfo.h"
#import "MNChatMessage.h"
#import "MNMessageCodes.h"
#import "MNUserProfileView.h"
#import "MNSocNetSessionFB.h"
#import "MNUserCredentials.h"
#import "MNNetworkStatus.h"
#import "MNABImportDialogView.h"
#import "MNABImportTableViewDataSource.h"
#import "MNLauncherTools.h"

#import "MNSessionInternal.h"

#define ACTIVITY_INDICATOR_ENABLED (0)

#define MNProfileViewAvatarImageDimension (55)

#define MNProfileViewNavBarDefaultHeight (49)

static NSString* MNSessionActionURLPrefix = @"apphost_";
static NSString* MNSessionActionWelcomeURL = @"welcome.php";
static NSString* MNSessionActionConnectURL = @"connect.php";
static NSString* MNSessionActionReconnectURL = @"reconnect.php";
static NSString* MNSessionActionGoBackURL = @"goback.php";
static NSString* MNSessionActionLogoutURL = @"logout.php";
static NSString* MNSessionActionSendPrivateMessageURL = @"sendmess.php";
static NSString* MNSessionActionSendPublicMessageURL = @"chatmess.php";
static NSString* MNSessionActionJoinBuddyRoomURL = @"joinbuddyroom.php";
static NSString* MNSessionActionJoinAutoRoomURL = @"joinautoroom.php";
static NSString* MNSessionActionPlayGameURL = @"playgame.php";
static NSString* MNSessionActionLoginFacebookURL = @"sn_facebook_login.php";
static NSString* MNSessionActionResumeFacebookURL = @"sn_facebook_resume.php";
static NSString* MNSessionActionLogoutFacebookURL = @"sn_facebook_logout.php";
static NSString* MNSessionActionShowFacebookPublishDialogURL = @"sn_facebook_dialog_publish_show.php";
static NSString* MNSessionActionShowFacebookPermissionDialogURL = @"sn_facebook_dialog_permission_req_show.php";
static NSString* MNSessionActionImportAddressBookURL = @"do_user_ab_import.php";
static NSString* MNSessionActionGetAddressBookDataURL = @"get_user_ab_data.php";
static NSString* MNSessionActionNewBuddyRoomURL = @"newbuddyroom.php";
static NSString* MNSessionActionStartRoomGameURL = @"start_room_game.php";
static NSString* MNSessionActionGetContextURL = @"get_context.php";
static NSString* MNSessionActionGetRoomUserListURL = @"get_room_userlist.php";
static NSString* MNSessionActionGetGameResultsURL = @"get_game_results.php";
static NSString* MNSessionActionLeaveRoomURL = @"leaveroom.php";
static NSString* MNSessionActionImportUserPhotoURL = @"do_photo_import.php";
static NSString* MNSessionActionSetRoomUserStatusURL = @"set_room_user_status.php";
static NSString* MNSessionActionNavBarShowURL = @"navbar_show.php";
static NSString* MNSessionActionNavBarHideURL = @"navbar_hide.php";
static NSString* MNSessionActionScriptEvalURL = @"script_eval.php";
static NSString* MNSessionActionWebViewReloadURL = @"webview_reload.php";
static NSString* MNSessionActionVarSaveURL = @"var_save.php";
static NSString* MNSessionActionVarsClearURL = @"vars_clear.php";
static NSString* MNSessionActionVarsGetURL = @"vars_get.php";
static NSString* MNSessionActionConfigVarsGetURL = @"config_vars_get.php";
static NSString* MNSessionActionVoidURL = @"void.php";
static NSString* MNSessionActionSetHostParamURL = @"set_host_param.php";
static NSString* MNSessionActionPluginMessageSubscribeURL = @"plugin_message_subscribe.php";
static NSString* MNSessionActionPluginMessageUnSubscribeURL = @"plugin_message_unsubscribe.php";
static NSString* MNSessionActionPluginMessageSendURL = @"plugin_message_send.php";
static NSString* MNSessionActionSendHttpRequestURL = @"http_request.php";
static NSString* MNSessionActionSetGameResultsURL = @"set_game_results.php";
static NSString* MNSessionActionExecUICommandURL = @"exec_ui_command.php";
static NSString* MNSessionActionPostWebEventURL = @"post_web_event.php";
static NSString* MNSessionActionAddSourceDomainURL = @"add_source_domain.php";
static NSString* MNSessionActionRemoveSourceDomainURL = @"remove_source_domain.php";
static NSString* MNSessionActionAppIsInstalledQueryURL = @"app_is_installed.php";
static NSString* MNSessionActionAppTryLaunchURL = @"app_try_launch.php";
static NSString* MNSessionActionAppShowInMarketURL = @"app_show_in_market.php";

static NSString* MNSessionActionRequestParamReqInArg  = @"apphost_req_in_arg";
static NSString* MNSessionActionRequestParamReqOutArg = @"apphost_req_out_arg";

static NSString* MNUserProfileViewConnectRequestParamMode = @"mode";
static NSString* MNUserProfileViewConnectRequestParamUserId = @"user_id";
static NSString* MNUserProfileViewConnectRequestParamUserLogin = @"user_login";
static NSString* MNUserProfileViewConnectRequestParamUserPassword = @"user_password";
static NSString* MNUserProfileViewConnectRequestParamUserPasswordHash = @"user_password_hash";
static NSString* MNUserProfileViewConnectRequestParamUserDevSetHome = @"user_dev_set_home";
static NSString* MNUserProfileViewConnectRequestParamUserAuthSign = @"user_auth_sign";
static NSString* MNUserProfileViewConnectRequestModeMultiNetByPHash = @"login_multinet_by_user_id_and_phash";
static NSString* MNUserProfileViewConnectRequestModeMultiNet = @"login_multinet";
static NSString* MNUserProfileViewConnectRequestModeMultiNetByAuthSign = @"login_multinet_user_id_and_auth_sign";
static NSString* MNUserProfileViewConnectRequestModeMultiNetAuto = @"login_multinet_auto";
static NSString* MNUserProfileViewConnectRequestModeMultiNetByAuthSignOffline = @"login_multinet_user_id_and_auth_sign_offline";
static NSString* MNUserProfileViewConnectRequestModeMultiNetSignupOffline = @"login_multinet_signup_offline";
static NSString* MNUserProfileViewPluginMsgSubscribeRequestParamPluginName = @"plugin_mask";
static NSString* MNUserProfileViewPluginMsgUnSubscribeRequestParamPluginName = @"plugin_mask";
static NSString* MNUserProfileViewPluginMsgSendRequestParamPluginName = @"plugin_name";
static NSString* MNUserProfileViewPluginMsgSendRequestParamPluginMessage = @"plugin_message";

static NSString* MNUserProfileViewRequestParamGameSetId = @"gameset_id";

static NSString* MNUserProfileViewRequestParamNavBarURL = @"navbar_url";
static NSString* MNUserProfileViewRequestParamNavBarHeight = @"navbar_height";

static NSString* MNUserProfileViewRequestParamJScriptEval= @"jscript_eval";
static NSString* MNUserProfileViewRequestParamJScriptEvalForce = @"force_eval";

static NSString* MNUserProfileViewSendMessRequestParamToUserSFId = @"to_user_sfid";
static NSString* MNUserProfileViewSendMessRequestParamMessText = @"mess_text";

static NSString* MNUserProfileViewJoinBuddyRoomRequestParamRoomSFId = @"room_sfid";

static NSString* MNUserProfileViewPlayGameRequestParamGameSetParams = @"gameset_params";
static NSString* MNUserProfileViewPlayGameRequestParamGameScorePostLinkId = @"game_scorepostlink_id";
static NSString* MNUserProfileViewPlayGameRequestParamGameSeed = @"game_seed";
static NSString* MNUserProfileViewPlayGameRequestParamPlayParamNamePrefix = @"gameset_play_param_";

static NSString* MNUserProfileViewCreateBuddyRoomRequestParamRoomName = @"room_name";
static NSString* MNUserProfileViewCreateBuddyRoomRequestParamToUserIdList = @"to_user_id_list";
static NSString* MNUserProfileViewCreateBuddyRoomRequestParamToUserSFIdList = @"to_user_sfid_list";
static NSString* MNUserProfileViewCreateBuddyRoomRequestParamInviteText = @"mess_text";

static NSString* MNUserProfileViewSetRoomUserStatusRequestParamUserStatus = @"mn_user_status";

static NSString* MNUserProfileViewLogoutRequestParamWipeHome = @"user_dev_wipe_home";

static NSString* MNUserProfileViewWebViewReloadRequestParamWebViewUrl = @"webview_url";

static NSString* MNUserProfileViewRequestParamVarName  = @"var_name";
static NSString* MNUserProfileViewRequestParamVarValue = @"var_value";
static NSString* MNUserProfileViewRequestParamVarNameList = @"var_name_list";

static NSString* MNUserProfileViewRequestParamContextCallWaitLoad = @"context_call_wait_load";

static NSString* MNURLHttpScheme  = @"http";
static NSString* MNURLHttpsScheme = @"https";

static NSString* MNUserProfileViewErrorPageTemplateFileName = @"MN.bundle/multinet_http_error";
static NSString* MNUserProfileViewErrorPageTemplateFileType = @"html";
static NSString* MNUserProfileViewErrorPageTemplateTextPlaceHolder = @"{0}";
static NSString* MNUserProfileViewErrorPageTemplateEmbedded =
 @"<html>"
  @"<head>"
   @"<title>MultiNet: Error</title>"
  @"</head>"
  @"<body onclick=\"location.assign('apphost_goback.php');\">"
   @"<div align=\"center\" style=\"padding:20px;padding-top:150px;padding-bottom:150px;color:red\" "
   @"     onclick=\";\" " // Empty event handler is needed to workaround browser bug (onclick not fired on body if no handler defined here)
   @">"
   @"<b>MultiNet: Error</b><br/>"
   @"<script>document.write({0});</script>"
   @"</div>"
  @"</body>"
 @"</html>";

static NSString* MNUserProfileViewBootPageFileName = @"MN.bundle/multinet_boot";
static NSString* MNUserProfileViewBootPageFileType = @"html";

#define MNJSUpdateContextJSSrcInitialLen (256)
#define MNJSUpdateContextDevUserInfoInitialLen (256)

static NSString* MNStartUrlFormat = @"%@/welcome.php"; /* the only format argument must be MultiNetWebServerURL value */

static BOOL stringStartsWithFileURLScheme (NSString* str) {
    NSInteger fileURLFileSchemeLen = [NSURLFileScheme length];

    if ([str length] < fileURLFileSchemeLen) {
        return NO;
    }

    return [str compare: NSURLFileScheme options: 0 range: NSMakeRange(0,fileURLFileSchemeLen)] == NSOrderedSame;
}

static NSURLRequest* MNUserProfileViewGetStartRequestOnline (NSString* webServerURL, NSInteger gameId) {
    NSString* startURL = [NSString stringWithFormat: MNStartUrlFormat, webServerURL];

    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat: @"%d",gameId],
                             @"game_id",
                             MNGetDeviceIdMD5(),
                             @"dev_id",
                             [NSString stringWithFormat: @"%d",MNDeviceTypeiPhoneiPod],
                             @"dev_type",
                             MNClientAPIVersion,
                             @"client_ver",
                             [[NSLocale currentLocale] localeIdentifier],
                             @"client_locale",
                             nil];

    return MNGetURLRequestWithPostMethod([NSURL URLWithString: startURL],params);
}

static NSURLRequest* MNUserProfileViewGetStartRequestOffline (NSString* webServerURL, NSInteger gameId) {
    NSString* startURL = [[NSString stringWithFormat: @"%@/welcome.php.html?game_id=%d&dev_id=%@&dev_type=%d&client_ver=%@&client_locale=%@",
                           webServerURL,
                           gameId,
                           MNGetDeviceIdMD5(),
                           MNDeviceTypeiPhoneiPod,
                           MNClientAPIVersion,
                           [[NSLocale currentLocale] localeIdentifier]] stringByReplacingOccurrencesOfString: @" " withString: @"%20"];

    return [NSURLRequest requestWithURL: [NSURL URLWithString: startURL]];
}

static NSURLRequest* MNUserProfileViewGetStartRequest (NSString* webServerURL, NSInteger gameId) {
    if (webServerURL != nil) {
        if (stringStartsWithFileURLScheme(webServerURL)) {
            return MNUserProfileViewGetStartRequestOffline(webServerURL,gameId);
        }
        else {
            return MNUserProfileViewGetStartRequestOnline(webServerURL,gameId);
        }
    }
    else {
        return nil;
    }
}

static void accumulateVarsList (NSMutableString* javaScriptSrc, NSDictionary* vars) {
    BOOL needComma = NO;

    for (NSString* key in vars) {
        if (needComma) {
            [javaScriptSrc appendString: @","];
        }
        else {
            needComma = YES;
        }

        [javaScriptSrc appendFormat: @"new MN_HostVar(%@,%@)",
         MNStringAsJSString(key),
         MNStringAsJSString([vars objectForKey: key])];
    }
}

/* Fully-transparent view */
@interface MNTransparentView: UIView {
}

-(id) initWithFrame:(CGRect) aRect;
-(void) dealloc;
@end

@implementation MNTransparentView

-(id) initWithFrame:(CGRect) aRect {
    self = [super initWithFrame: aRect];

    if (self != nil) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithWhite: 0.0f alpha: 0.0f];
    }

    return self;
}

-(void) dealloc {
    [super dealloc];
}

@end

/*  ImagePicker  */
@interface MNTransparentViewController: UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    @private

    id _target;
    SEL _action;
    BOOL releaseOnViewAppear;
}

-(id) initWithTarget:(id) target action:(SEL) action;
-(void) dealloc;

-(void) loadView;

/* UIImagePickerControllerDelegate */
-(void) imagePickerController:(UIImagePickerController*) picker didFinishPickingImage:(UIImage*) image editingInfo:(NSDictionary*) editingInfo;
-(void) imagePickerControllerDidCancel:(UIImagePickerController*) picker;
@end

@implementation MNTransparentViewController

-(id) initWithTarget:(id) target action:(SEL) action {
    self = [super init];

    if (self != nil) {
        _target = target;
        _action = action;
        releaseOnViewAppear = NO;
    }

    return self;
}

-(void) dealloc {
    self.view.hidden = YES;
    [self.view removeFromSuperview];

    [super dealloc];
}

-(void) loadView {
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;

    MNTransparentView* aView = [[MNTransparentView alloc] initWithFrame: appFrame];

    [aView setAutoresizingMask: UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];

    self.view = aView;

    [aView release];

    /* add transparent view to key window */

    UIWindow* window =  [[UIApplication sharedApplication] keyWindow];

    if (window == nil) {
        window = [[UIApplication sharedApplication].windows objectAtIndex: 0];
    }

    [window addSubview: self.view];
}

-(void) imagePickerController:(UIImagePickerController*) picker didFinishPickingImage:(UIImage*) image editingInfo:(NSDictionary*) editingInfo {
    if ([_target respondsToSelector: _action]) {
        [_target performSelector: _action withObject: image];
    }

    releaseOnViewAppear = YES;

    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker release];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController*) picker {
    releaseOnViewAppear = YES;

    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker release];
}

-(void) viewDidAppear:(BOOL) animated {
    if (releaseOnViewAppear) {
        [self autorelease];
    }
}

@end

/* a class extension to declare private methods */
@interface MNUserProfileView ()
/* UIWebViewDelegate protocol */
- (void)webView:(UIWebView*) webView didFailLoadWithError:(NSError*) error;
- (BOOL)webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest*) request navigationType:(UIWebViewNavigationType) navigationType;
- (void)webViewDidFinishLoad:(UIWebView*) webView;
- (void)webViewDidStartLoad:(UIWebView*) webView;

/* MNSessionDelegate protocol */
-(void) mnSessionLoginInitiated;
-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus;
-(void) mnSessionUserChangedTo:(MNUserId) userId;
-(void) mnSessionGameFinishedWithResult:(MNGameResult*) gameResult;
-(void) mnSessionChatPrivateMessageReceived:(MNChatMessage*) chatMessage;
-(void) mnSessionChatPublicMessageReceived:(MNChatMessage*) chatMessage;
-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender;
-(void) mnSessionGameStartCountdownTick:(NSInteger) secondsLeft;
-(void) mnSessionJoinRoomInvitationReceived:(MNJoinRoomInvitationParams*) params;
-(void) mnSessionRoomUserJoin:(MNUserInfo*) userInfo;
-(void) mnSessionRoomUserLeave:(MNUserInfo*) userInfo;
-(void) mnSessionCurrGameResultsReceived:(MNCurrGameResults*) gameResults;
-(void) mnSessionRoomUserStatusChangedTo:(NSInteger) newStatus;
-(void) mnSessionSocNetLoggedOut:(NSInteger) socNetId;
-(void) mnSessionDevUsersInfoChanged;
-(void) mnSessionExecAppCommandReceived:(NSString*) cmdName withParam:(NSString*) cmdParam;
-(void) mnSessionSysEventReceived:(NSString*) eventName withParam:(NSString*) eventParam andCallbackId:(NSString*) callbackId;
-(void) mnSessionErrorOccurred:(MNErrorInfo*) error;
-(void) mnSessionWebFrontURLReady:(NSString*) url;
-(void) mnSessionHandleOpenURL:(NSURL*) url;

/* MNSessionSocNetFBDelegate */
-(void) socNetFBLoginOk:(MNSocNetSessionFB*) session;
-(void) socNetFBLoginFailed:(NSString*) error;
-(void) socNetFBLoginCancelled;

/* MNABImportDelegate */
-(void) contactImportInfoReady: (NSArray*) contactArray;

/* MNUIWebViewHttpReqQueueDelegate */
-(void) mnUiWebViewHttpReqDidSucceedWithCodeToEval:(NSString*) jsCode andFlags:(unsigned int) flags;
-(void) mnUiWebViewHttpReqDidFailWithCodeToEval:(NSString*) jsCode andFlags:(unsigned int) flags;

/* internal helper methods */
- (void) initializeData;
- (void) loadBootPage;
- (void) createViewStruct;
- (void) handleConnectRequest: (NSDictionary*) request;
- (void) handleReconnectRequest: (NSDictionary*) request;
- (void) handleLogoutRequest: (NSDictionary*) request;
- (void) handleSendPrivateMessageRequest: (NSDictionary*) request;
- (void) handleSendPublicMessageRequest: (NSDictionary*) request;
- (void) handleJoinBuddyRoomRequest: (NSDictionary*) request;
- (void) handleJoinAutoRoomRequest: (NSDictionary*) request;
- (void) handlePlayGameRequest: (NSDictionary*) request;
- (void) handleLoginFacebookRequest: (NSDictionary*) request;
- (void) handleResumeFacebookRequest: (NSDictionary*) request;
- (void) handleLogoutFacebookRequest: (NSDictionary*) request;
- (void) handleShowFacebookPublishDialogRequest: (NSDictionary*) request;
- (void) handleShowFacebookPermissionDialogRequest: (NSDictionary*) request;
- (void) handleImportAddressBookRequest;
- (void) handleGetAddressBookDataRequest;
- (void) handleNewBuddyRoomRequest: (NSDictionary*) request;
- (void) handleStartRoomGameRequest;
- (void) handleGetRoomUserListRequest: (NSDictionary*) request;
- (void) handleImportUserPhotoRequest: (NSDictionary*) request;
- (void) handleSetRoomUserStatusRequest: (NSDictionary*) request;
- (void) handleNavBarShowRequest: (NSDictionary*) request;
- (void) handleNavBarHideRequest: (NSDictionary*) request;
- (void) handleScriptEvalRequest: (NSDictionary*) request;
- (void) handleWebViewReloadRequest: (NSDictionary*) request;
- (void) handleVarSaveRequest: (NSDictionary*) request;
- (void) handleVarsClearRequest: (NSDictionary*) request;
- (void) handleVarsGetRequest: (NSDictionary*) request;
- (void) handleConfigVarsGetRequest: (NSDictionary*) request;
- (void) handleSetHostParamRequest: (NSDictionary*) request;
- (void) handlePluginMessageSubscribeRequest: (NSDictionary*) request;
- (void) handlePluginMessageUnSubscribeRequest: (NSDictionary*) request;
- (void) handlePluginMessageSendRequest: (NSDictionary*) request;
- (void) handleSendHttpRequestRequest: (NSDictionary*) request;
- (void) handleSetGameResultsRequest: (NSDictionary*) request;
- (void) handleExecUICommandRequest: (NSDictionary*) request;
- (void) handlePostWebEventRequest: (NSDictionary*) request;
- (void) handleAddSourceDomainRequest: (NSDictionary*) request;
- (void) handleRemoveSourceDomainRequest: (NSDictionary*) request;
- (void) handleAppIsInstalledQueryRequest: (NSDictionary*) request;
- (void) handleAppTryLaunchRequest: (NSDictionary*) request;
- (void) handleAppShowInMarketRequest: (NSDictionary*) request;
- (void) callSetErrorMessage: (NSString*) error;
- (void) callSetErrorMessage: (NSString*) error forActionCode:(NSInteger) actionCode;
- (void) callJSSetContext;
- (void) callJSUpdateContext;
- (void) callJSUpdateContextGeneric: (BOOL) setMode;
- (void) scheduleJSUpdateContext;
- (void) scheduleChatMessageNotification:(MNChatMessage*) chatMessage;
- (BOOL) isHostTrusted:(NSString*) host;
- (BOOL) isWebViewLocationAtTrustedHost:(UIWebView*) webView;
- (BOOL) isWebViewLocationALocalFile:(UIWebView*) webView;
- (BOOL) isWebViewLocationTrusted:(UIWebView*) webView;
- (void) callJSScript:(NSString*) script;
- (void) callJSScriptForcely:(NSString*) script;
- (void)loadErrorMessagePage:(NSString*) errorMessage;

#if ACTIVITY_INDICATOR_ENABLED
- (void) activityIndicatorStart;
- (void) activityIndicatorStop;
#endif

- (void) detachFromSession;

- (id) handleUserImageSelection:(id) image;

/* device users info cache control */

-(NSString*) getDeviceUsersInfoJSSrc;
-(void)      invalidateDeviceUsersInfo;
@end

@implementation MNUserProfileView

@synthesize autoCancelGameOnGoBack;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeData];
        [self createViewStruct];
    }
    return self;
}

-(void)awakeFromNib {
    [self initializeData];
    [self createViewStruct];
}

-(void) initializeData {
    startPageLoaded = NO;
    startNavLoaded = NO;
    statusChangedPending = NO;
    pendingChatMessages  = nil;
    deviceUsersInfoJSSrc = nil;
    autoCancelGameOnGoBack = YES;
    contextCallWaitLoad = YES;
    _webServerURL = nil;
    _trustedHosts = [[NSMutableSet alloc] init];

    _errorPageLoaded = NO;

    trackedPluginsStorage = [[MNStrMaskStorage alloc] init];

    _fbLoginSuccessJS      = nil;
    _fbLoginCancelJS       = nil;
    _fbPublishSuccessJS    = nil;
    _fbPublishCancelJS     = nil;
    _fbPermissionSuccessJS = nil;
    _fbPermissionCancelJS  = nil;

    _delegates = [[MNDelegateArray alloc] init];
    _httpReqQueue = [[MNUIWebViewHttpReqQueue alloc] initWithDelegate: (id)self];
}

/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [_delegates release];

    if (_session != nil) {
        [_session removeDelegate: self];
        [_session release];
    }

    [_httpReqQueue release];

    [_fbLoginSuccessJS      release];
    [_fbLoginCancelJS       release];
    [_fbPublishSuccessJS    release];
    [_fbPublishCancelJS     release];
    [_fbPermissionSuccessJS release];
    [_fbPermissionCancelJS  release];

    [trackedPluginsStorage release];
    [deviceUsersInfoJSSrc release];
    [pendingChatMessages release];

    [_trustedHosts release];
    [_webServerURL release];
    _navBarWebView.delegate = nil;
    [_navBarWebView release];
    [_navBarCurrentURL release];
    _webView.delegate = nil;
    [_webView release];
#if ACTIVITY_INDICATOR_ENABLED
    [activityIndicator release];
#endif
    [baseHost release];
    [super dealloc];
}

- (void) detachFromSession {
    if (_session != nil) {
        [_session removeDelegate: self];
        [_session release];

        _session = nil;
    }
}

-(void) loadStartPage {
    NSURLRequest* startRequest = MNUserProfileViewGetStartRequest(_webServerURL,[_session getGameId]);

    if (startRequest != nil) {
        baseHost = [[[startRequest URL] host] copy];
        if (baseHost != nil) {
            [_trustedHosts addObject: baseHost];
        }

        if ([[startRequest URL] isFileURL] || [MNNetworkStatus haveInternetConnection]) {
            [_webView loadRequest: startRequest];
        }
        else {
            [self loadErrorMessagePage: MNLocalizedString(@"Internet connection is not available",MNMessageCodeInternetConnectionNotAvailableError)];
        }
    }
    else {
        NSLog(@"internal error: application setup is incorrect - unable to get MultiNet startURL property");
    }
}

-(void) bindToSession:(MNSession*) session {
    if (_session != nil) {
        [_session removeDelegate: self];
        [_session release];
    }

    if (baseHost != nil) {
        [baseHost release];
        baseHost = nil;
        [_trustedHosts release];
        _trustedHosts = [[NSMutableSet alloc] init];
    }

    _session = [session retain];
    [_session addDelegate: self];

    startPageLoaded = NO;
    startNavLoaded = NO;

    if (bootPageLoaded) {
        _webServerURL = [[_session getWebFrontURL] retain];

        if (_webServerURL != nil) {
            [self loadStartPage];
        }
    }
}

/*
-(void) mnSessionConfigLoaded {
    if (_session != nil && _webServerURL == nil) {
        _webServerURL = [[_session getWebServerURL] retain];

        [self loadStartPage];
    }
}
*/

-(id<MNUserProfileViewDelegate>) getDelegate {
    if ([_delegates count] > 0) {
        return [_delegates delegateAtIndex: 0];
    }
    else {
        return nil;
    }
}

-(void) setDelegate:(id<MNUserProfileViewDelegate>) delegate {
    [_delegates setDelegate: delegate];
}

-(void) addDelegate:(id<MNUserProfileViewDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNUserProfileViewDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

-(void) mnSessionWebFrontURLReady:(NSString*) url {
    if (_webServerURL == nil) {
        _webServerURL = [url retain];

        [self loadStartPage];
    }
}

- (void)loadErrorMessagePage:(NSString*) errorMessage {
    NSString* errorPageFilePath = [[[[NSBundle mainBundle] bundlePath]
                                   stringByAppendingPathComponent: MNUserProfileViewErrorPageTemplateFileName]
                                    stringByAppendingPathExtension: MNUserProfileViewErrorPageTemplateFileType];

    NSString* errorPageTemplate = [NSString stringWithContentsOfFile: errorPageFilePath encoding: NSUTF8StringEncoding error: NULL];

    if (errorPageTemplate == nil) {
        errorPageTemplate = MNUserProfileViewErrorPageTemplateEmbedded;
    }

    NSString* errorPageContent = [errorPageTemplate stringByReplacingOccurrencesOfString: MNUserProfileViewErrorPageTemplateTextPlaceHolder withString: MNStringAsJSString(errorMessage)];

    [_webView loadHTMLString: errorPageContent baseURL: [NSURL fileURLWithPath: errorPageFilePath]];

    _errorPageLoaded = YES;
}

/* UIWebViewDelegate protocol */

static NSString* MNWebKitErrorDomain = @"WebKitErrorDomain";
#define MNWebKitErrorCannotShowURL                      (101)
#define MNWebKitErrorFrameLoadInterruptedByPolicyChange (102)

- (void)webView:(UIWebView*) webView didFailLoadWithError:(NSError*) error {
#if ACTIVITY_INDICATOR_ENABLED
    [self activityIndicatorStop];
#endif

    if ([[error domain] isEqualToString: NSURLErrorDomain] &&
        [error code] == NSURLErrorCancelled) {
        return; /* ignore "cancelled" errors */
    }

    if ([[error domain] isEqualToString: MNWebKitErrorDomain] &&
        ([error code] == MNWebKitErrorFrameLoadInterruptedByPolicyChange ||
         [error code] == MNWebKitErrorCannotShowURL)) {
        return; /* ignore "frame load interrupted" and "URL cannot be shown" errors */
    }

/*
    NSLog(@"Domain: %@",[error domain]);
    NSLog(@"Error code: %d",(int)[error code]);
*/

    [self handleNavBarHideRequest: nil];

    [self loadErrorMessagePage: MNLocalizedString([error localizedDescription],MNMessageCodeHttpSystemError)];
}

-(BOOL)shouldStartLoadToNavBarExtRequest:(NSURLRequest*) request {
	BOOL      shouldStartLoad;
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_NavBarCheckLoadUrl(%@,null);",
                                MNStringAsJSString([[request URL] absoluteString])];

    NSString* result = [_navBarWebView stringByEvaluatingJavaScriptFromString: javaScriptSrc];


    shouldStartLoad = ![result isEqualToString: @"apphost_navbar_cancel_url_load.php"];

	[javaScriptSrc release];

	return shouldStartLoad;
}

- (BOOL)webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest*) request navigationType:(UIWebViewNavigationType) navigationType {
    if (request == nil) {
        return YES;
    }

    if (![self isWebViewLocationTrusted: webView]) {
        return YES;
    }

    NSURL    *requestURL  = [request URL];
    NSString *requestHost = [requestURL host];

    BOOL hasActionURLPrefix = NO;
    NSString *pathLastPart = (NSString*)CFURLCopyLastPathComponent((CFURLRef)requestURL);

    NSString* actionName = nil;

    if (pathLastPart != nil) {
        NSRange prefixRange = NSMakeRange(0,[MNSessionActionURLPrefix length]);

        if ([pathLastPart length] >= prefixRange.length) {
            if ([pathLastPart compare: MNSessionActionURLPrefix
                              options: 0
                              range: prefixRange] == NSOrderedSame) {
                hasActionURLPrefix = YES;
                actionName = [pathLastPart substringFromIndex: prefixRange.length];
            }
        }
    }

    if (webView == _navBarWebView && !hasActionURLPrefix &&
         (request == nil || ![self isHostTrusted: requestHost])) {
        [pathLastPart release];

        return [self shouldStartLoadToNavBarExtRequest: request];
    }

    if (requestHost == nil) {
    }
    else if ([self isHostTrusted: requestHost]) {
    }
    else {
        [pathLastPart release];

        return YES;
    }

    if (!hasActionURLPrefix) {
        [pathLastPart release];

        return YES;
    }

    NSDictionary* params = MNCopyDictionaryWithURLRequestParameters(request);

    NSString* requestInArgParam = (NSString*)[params objectForKey: MNSessionActionRequestParamReqInArg];

    if (requestInArgParam != nil) {
        [webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat: @"MN_AppHostReqIn(%@)", MNStringAsJSString(requestInArgParam)]];
    }

    if (![_session preprocessAppHostCall: [MNAppHostCallInfo mnAppHostCallInfoWithCommand: pathLastPart andParams: params]]) {
        if ([actionName isEqualToString: MNSessionActionSendPrivateMessageURL]) {
            if (_session != nil && [_session isOnline]) {
                [self handleSendPrivateMessageRequest: params];
            }
        }
        else if ([actionName isEqualToString: MNSessionActionSendPublicMessageURL]) {
            if (_session != nil && [_session isOnline]) {
                [self handleSendPublicMessageRequest: params];
            }
        }
        else if ([actionName isEqualToString: MNSessionActionJoinBuddyRoomURL]) {
            [self handleJoinBuddyRoomRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionJoinAutoRoomURL]) {
            [self handleJoinAutoRoomRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionPlayGameURL]) {
            [self handlePlayGameRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionSendHttpRequestURL]) {
            [self handleSendHttpRequestRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionLoginFacebookURL]) {
            [self handleLoginFacebookRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionResumeFacebookURL]) {
            [self handleResumeFacebookRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionLogoutFacebookURL]) {
            [self handleLogoutFacebookRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionShowFacebookPublishDialogURL]) {
            [self handleShowFacebookPublishDialogRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionShowFacebookPermissionDialogURL]) {
            [self handleShowFacebookPermissionDialogRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionImportAddressBookURL]) {
            [self handleImportAddressBookRequest];
        }
        else if ([actionName isEqualToString: MNSessionActionGetAddressBookDataURL]) {
            [self handleGetAddressBookDataRequest];
        }
        else if ([actionName isEqualToString: MNSessionActionNewBuddyRoomURL]) {
            [self handleNewBuddyRoomRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionStartRoomGameURL]) {
            [self handleStartRoomGameRequest];
        }
        else if ([actionName isEqualToString: MNSessionActionGetContextURL]) {
            [self callJSUpdateContext];
            /*         [self scheduleJSUpdateContext]; */
        }
        else if ([actionName isEqualToString: MNSessionActionGetRoomUserListURL]) {
            [self handleGetRoomUserListRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionGetGameResultsURL]) {
            [_session reqCurrentGameResults];
        }
        else if ([actionName isEqualToString: MNSessionActionLeaveRoomURL]) {
            [_session leaveRoom];
        }
        else if ([actionName isEqualToString: MNSessionActionImportUserPhotoURL]) {
            [self handleImportUserPhotoRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionSetRoomUserStatusURL]) {
            [self handleSetRoomUserStatusRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionNavBarShowURL]) {
            [self handleNavBarShowRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionNavBarHideURL]) {
            [self handleNavBarHideRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionScriptEvalURL]) {
            [self handleScriptEvalRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionWebViewReloadURL]) {
            [self handleWebViewReloadRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionReconnectURL]) {
            if (_session != nil) {
                [self handleReconnectRequest: params];
            }
        }
        else if ([actionName isEqualToString: MNSessionActionVarSaveURL]) {
            [self handleVarSaveRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionVarsClearURL]) {
            [self handleVarsClearRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionVarsGetURL]) {
            [self handleVarsGetRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionConfigVarsGetURL]) {
            [self handleConfigVarsGetRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionVoidURL]) {
        }
        else if ([actionName isEqualToString: MNSessionActionSetHostParamURL]) {
            [self handleSetHostParamRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionPluginMessageSubscribeURL]) {
            [self handlePluginMessageSubscribeRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionPluginMessageUnSubscribeURL]) {
            [self handlePluginMessageUnSubscribeRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionPluginMessageSendURL]) {
            [self handlePluginMessageSendRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionSetGameResultsURL]) {
            [self handleSetGameResultsRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionExecUICommandURL]) {
            [self handleExecUICommandRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionPostWebEventURL]) {
            [self handlePostWebEventRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionAddSourceDomainURL]) {
            [self handleAddSourceDomainRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionRemoveSourceDomainURL]) {
            [self handleRemoveSourceDomainRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionAppIsInstalledQueryURL]) {
            [self handleAppIsInstalledQueryRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionAppTryLaunchURL]) {
            [self handleAppTryLaunchRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionAppShowInMarketURL]) {
            [self handleAppShowInMarketRequest: params];
        }
        else if ([actionName isEqualToString: MNSessionActionConnectURL]) {
            if (_session != nil) {
                [self handleConnectRequest: params];
            }
        }
        else if ([actionName isEqualToString: MNSessionActionGoBackURL]) {
            if (self.autoCancelGameOnGoBack) {
                if (_session != nil && [_session isOnline]) {
                    [_session cancelGameWithParams: nil];
                }
            }

            [_delegates beginCall];

            for (id<MNUserProfileViewDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(mnUserProfileViewDoGoBack)]) {
                    [delegate mnUserProfileViewDoGoBack];
                }
            }

            [_delegates endCall];
        }
        else if ([actionName isEqualToString: MNSessionActionLogoutURL]) {
            [self handleLogoutRequest: params];
        }
        else {
            [self callSetErrorMessage: [NSString stringWithFormat: MNLocalizedString(@"undefined action URL (%@)",MNMessageCodeUndefinedActionURLErrorFormat), pathLastPart]];
        }
    }

    NSString* requestOutArgParam = (NSString*)[params objectForKey: MNSessionActionRequestParamReqOutArg];

    if (requestOutArgParam != nil) {
        [webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat: @"MN_AppHostReqOut(%@)", MNStringAsJSString(requestOutArgParam)]];
    }

    [params release];
    [pathLastPart release];

    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView*) webView {
    if (!bootPageLoaded) {
        bootPageLoaded = YES;

        if (_webServerURL == nil) {
            _webServerURL = [[_session getWebFrontURL] retain];
        }

        if (_webServerURL != nil) {
            [self loadStartPage];
        }

        return;
    }

    if (_session != nil) {
        if (baseHost != nil) {
            NSURL *requestURL = [[webView request] URL];
            NSString *requestHost = [requestURL host];
            BOOL needToCallJSUpdateContext = statusChangedPending;

            if (requestHost != nil) {
                if ([baseHost isEqualToString: requestHost]) {
                    NSString *pathLastPart = (NSString*)CFURLCopyLastPathComponent((CFURLRef)requestURL);

                    if (pathLastPart != nil && [pathLastPart isEqualToString: MNSessionActionWelcomeURL]) {
                        if (!startPageLoaded || _errorPageLoaded) {
/*
                            [self callJSSetContext];
*/

//                            needToCallJSUpdateContext = NO;
                            startPageLoaded = YES;
                            _errorPageLoaded = NO;
                        }
                    }

                    [pathLastPart release];

                    if (!startNavLoaded && webView == _navBarWebView) {
//                        [self callJSSetContext];

                        startNavLoaded = YES;
                    }

                    if (pendingChatMessages != nil) {
                        [self callJSScript: pendingChatMessages];
                        [pendingChatMessages release];
                        pendingChatMessages = nil;
                    }

                    if (needToCallJSUpdateContext) {
                        [self callJSUpdateContext];
                    }
                }
                else {
                    NSString* extURLOnLoadHookSrc = [_session varStorageGetValueForVariable: @"hook.js.alien_window_on_load"];

                    if (extURLOnLoadHookSrc != nil && [extURLOnLoadHookSrc length] > 0) {
                        [webView stringByEvaluatingJavaScriptFromString: extURLOnLoadHookSrc];
                    }
                }
            }
        }
    }

#if ACTIVITY_INDICATOR_ENABLED
    [self activityIndicatorStop];
#endif
}

-(void) loadBootPage {
    NSString* bootPageFilePath = [[[[NSBundle mainBundle] bundlePath]
                                   stringByAppendingPathComponent: MNUserProfileViewBootPageFileName]
                                    stringByAppendingPathExtension: MNUserProfileViewBootPageFileType];

    NSString* bootPageContent = [NSString stringWithContentsOfFile: bootPageFilePath encoding: NSUTF8StringEncoding error: NULL];

    if (bootPageContent != nil) {
        [_webView loadHTMLString: bootPageContent baseURL: [NSURL fileURLWithPath: bootPageFilePath]];
    }
}

- (void)createViewStruct {
    _webView = [[UIWebView alloc] initWithFrame: self.bounds];

    _webView.delegate = self;
#if ACTIVITY_INDICATOR_ENABLED
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
#else
    activityIndicator = nil;
#endif

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.autoresizesSubviews = YES;
    [self addSubview: _webView];
#if ACTIVITY_INDICATOR_ENABLED
    [self addSubview: activityIndicator];
#endif

    _webView.autoresizingMask = UIViewAutoresizingNone;
    _webView.scalesPageToFit = YES;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;

    bootPageLoaded = NO;
    [self loadBootPage];

#if ACTIVITY_INDICATOR_ENABLED
    activityIndicator.center = _webView.center;
#endif

    CGRect navBarFrame = CGRectMake(0,self.bounds.size.height - MNProfileViewNavBarDefaultHeight,
                                    self.bounds.size.width,MNProfileViewNavBarDefaultHeight);

    _navBarWebView = [[UIWebView alloc] initWithFrame: navBarFrame];
    _navBarWebView.hidden = YES;
    _navBarWebView.autoresizingMask = UIViewAutoresizingNone;
    _navBarWebView.scalesPageToFit = YES;
    _navBarWebView.delegate = self;
    _navBarWebView.dataDetectorTypes = UIDataDetectorTypeNone;

    [self addSubview: _navBarWebView];
}

- (void)webViewDidStartLoad:(UIWebView*) webView {
#if ACTIVITY_INDICATOR_ENABLED
    [self activityIndicatorStart];
#endif
}

- (void) layoutSubviews {
    if (_navBarWebView.hidden) {
        CGRect webViewFrame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height);

        _webView.frame = webViewFrame;
    }
    else {
        CGFloat webViewHeight = self.bounds.size.height - _navBarWebView.bounds.size.height;

        CGRect webViewFrame = CGRectMake(0,0,self.bounds.size.width,webViewHeight);
        CGRect navBarFrame  = CGRectMake(0,webViewHeight,self.bounds.size.width,_navBarWebView.bounds.size.height);

        _webView.frame = webViewFrame;
        _navBarWebView.frame = navBarFrame;
    }
}

/* MNSessionDelegate protocol */

-(void) mnSessionErrorOccurred:(MNErrorInfo*) error {
    NSInteger actionCode = error.actionCode;

    if (actionCode == MNErrorInfoActionCodeLogin) {
#if ACTIVITY_INDICATOR_ENABLED
        [self activityIndicatorStop];
#endif
        [self callSetErrorMessage: error.errorMessage forActionCode: actionCode];
     }
    else if (actionCode == MNErrorInfoActionCodeLoadConfig) {
        if (_session != nil && _webServerURL == nil) {
            [self loadErrorMessagePage: MNLocalizedString(@"Internet connection is not available",MNMessageCodeInternetConnectionNotAvailableError)];
        }
    }
    else {
        [self callSetErrorMessage: error.errorMessage forActionCode: actionCode];
    }
}

-(void) mnSessionLoginInitiated {
#if ACTIVITY_INDICATOR_ENABLED
    [self activityIndicatorStart];
#endif
}

-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus {
    if (oldStatus == MN_OFFLINE && _errorPageLoaded) {
        if (_webServerURL == nil) {
            _webServerURL = [[_session getWebFrontURL] retain];
        }

        if (_webServerURL != nil) {
            [self loadStartPage];
        }
    }
    else {
        if (oldStatus == MN_CONNECTING && newStatus != MN_CONNECTING) {
#if ACTIVITY_INDICATOR_ENABLED
            [self activityIndicatorStop];
#endif
        }

        [self scheduleJSUpdateContext];
    }
}

-(void) mnSessionUserChangedTo:(MNUserId) userId {
    [self scheduleJSUpdateContext];
}

-(void) scheduleChatMessageNotification:(MNChatMessage*) chatMessage {
    NSString* userInfoParam;

    if (chatMessage.sender != nil && chatMessage.sender.userName != nil) {
        userInfoParam = [[NSString alloc] initWithFormat: @"new MN_SF_UserInfo(%d,%@,'%lld')",
                                                          chatMessage.sender.userSFId,
                                                          MNStringAsJSString(chatMessage.sender.userName),
                                                          chatMessage.sender.userId];
    }
    else {
        userInfoParam = [[NSString alloc] initWithString: @"null"];
    }

    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"%@(%d,%@,%@);",
                                                             chatMessage.privateMessage ?
                                                              @"MN_InChatPrivateMessage" :
                                                              @"MN_InChatPublicMessage",
                                                             chatMessage.sender.userSFId,
                                                             userInfoParam,
                                                             MNStringAsJSString(chatMessage.message)];

    [userInfoParam release];

    if (pendingChatMessages != nil) {
        [pendingChatMessages appendFormat: @" %@", javaScriptSrc];
    }
    else if (contextCallWaitLoad && _webView.loading) {
        pendingChatMessages = [[NSMutableString alloc] initWithString: javaScriptSrc];
    }
    else {
        [self callJSScript: javaScriptSrc];
    }

    [javaScriptSrc release];
}

-(void) mnSessionChatPrivateMessageReceived:(MNChatMessage*) chatMessage {
    [self scheduleChatMessageNotification: chatMessage];
}

-(void) mnSessionChatPublicMessageReceived:(MNChatMessage*) chatMessage {
    [self scheduleChatMessageNotification: chatMessage];
}

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if ([trackedPluginsStorage checkString: pluginName]) {
        NSString* senderInfo;

        if (sender != nil) {
            senderInfo = [NSString stringWithFormat: @"new MN_SF_UserInfo(%d,%@,'%lld')",
                                   sender.userSFId,
                                   MNStringAsJSString(sender.userName),
                                   sender.userId];
        }
        else {
            senderInfo = @"null";
        }

        NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_RecvPluginMessage(%@,%@,%@);",
                                                    MNStringAsJSString(pluginName),
                                                    MNStringAsJSString(message),
                                                    senderInfo];

        [self callJSScript: javaScriptSrc];

        [javaScriptSrc release];
    }
}

-(void) mnSessionGameStartCountdownTick:(NSInteger) secondsLeft {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_InGameStartCountdown(%d);", secondsLeft];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionRoomUserStatusChangedTo:(NSInteger) newStatus {
    NSString* newStatusValue;

    if (newStatus == MN_USER_STATUS_UNDEFINED) {
        newStatusValue = nil;
    }
    else {
        newStatusValue = [NSString stringWithFormat: @"%d",newStatus];
    }

    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_UpdateRoomUserStatus(%@)",
                                                                MNStringAsJSString(newStatusValue)];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionJoinRoomInvitationReceived:(MNJoinRoomInvitationParams*) params {
    MNUserId  userId;
    NSString* userName;

    if (!MNParseMNUserNameToComponents(&userId,&userName,params.fromUserName)) {
        userId   = MNUserIdUndefined;
        userName = params.fromUserName;
    }

    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_InJoinRoomInvitation(%d,"
                                                                @"new MN_SF_UserInfo(%d,%@,'%lld'),"
                                                                @"new MN_SF_InviteRoom(%d,%@,%d,%d),%@);",
                                                                params.fromUserSFId,
                                                                params.fromUserSFId,
                                                                MNStringAsJSString(userName),
                                                                userId,
                                                                params.roomSFId,
                                                                MNStringAsJSString(params.roomName),
                                                                params.roomGameId,
                                                                params.roomGameSetId,
                                                                MNStringAsJSString(params.inviteText)];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionGameFinishedWithResult:(MNGameResult*) gameResult {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_InFinishGameNotify(%lld,%@,%d);",
                                                                gameResult.score,
                                                                MNStringAsJSString(gameResult.scorePostLinkId),
                                                                gameResult.gameSetId];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionRoomUserJoin:(MNUserInfo*) userInfo {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_InRoomUserJoin(%d,"
                                                                @"new MN_SF_UserInfo(%d,%@,'%lld'));",
                                                                userInfo.userSFId,
                                                                userInfo.userSFId,
                                                                MNStringAsJSString(userInfo.userName),
                                                                userInfo.userId];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionRoomUserLeave:(MNUserInfo*) userInfo {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_InRoomUserLeave(%d,"
                                                                @"new MN_SF_UserInfo(%d,%@,'%lld'));",
                                                                userInfo.userSFId,
                                                                userInfo.userSFId,
                                                                MNStringAsJSString(userInfo.userName),
                                                                userInfo.userId];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

#define MNCurrGameResultJSEntryApproxLength (128)

-(void) mnSessionCurrGameResultsReceived:(MNCurrGameResults*) gameResults {
    NSUInteger userCount = [gameResults.userInfoList count];

    NSMutableString* javaScriptSrc = [[NSMutableString alloc] initWithCapacity: MNCurrGameResultJSEntryApproxLength * userCount];

    [javaScriptSrc appendFormat: @"MN_InCurrGameResults(new Array("];

    for (NSUInteger index = 0; index < userCount; index++) {
        MNUserInfo* userInfo = [gameResults.userInfoList objectAtIndex: index];

        if (index > 0) {
            [javaScriptSrc appendString: @","];
        }

        [javaScriptSrc appendFormat: @"new MN_UserGameResult(%d,"
                                      @"new MN_SF_UserInfo(%d,%@,'%lld'),%d,%lld)",
                                     userInfo.userSFId,
                                     userInfo.userSFId,
                                     MNStringAsJSString(userInfo.userName),
                                     userInfo.userId,
                                     [[gameResults.userPlaceList objectAtIndex: index] integerValue],
                                     [[gameResults.userScoreList objectAtIndex: index] longLongValue]];
    }

    [javaScriptSrc appendFormat: @"),%d);", gameResults.finalResult ? 1 : 0];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionDefaultGameSetIdChangedTo:(NSInteger)gameSetId {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_UpdateDefaultGameSetId(%d);", gameSetId];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionExecAppCommandReceived:(NSString*) cmdName withParam:(NSString*) cmdParam {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_RecvAppCommand(%@,%@);",
                                                                MNStringAsJSString(cmdName),
                                                                MNStringAsJSString(cmdParam)];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionSysEventReceived:(NSString*) eventName withParam:(NSString*) eventParam andCallbackId:(NSString*) callbackId {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_HandleSysEvent({ 'eventName' : %@, 'eventParam' : %@, 'callbackId' : %@});",
                               MNStringAsJSString(eventName),
                               MNStringAsJSString(eventParam),
                               MNStringAsJSString(callbackId)];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

-(void) mnSessionHandleOpenURL:(NSURL*) url {
    [self scheduleJSUpdateContext];
}

- (void)handleConnectRequest: (NSDictionary*) params {
    NSString* modeParam = nil;

    if (params != nil) {
        modeParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamMode];
    }

    if (modeParam != nil) {
        if ([modeParam isEqualToString: MNUserProfileViewConnectRequestModeMultiNetByPHash]) {
            NSString* userIdParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserId];
            NSString* userPasswordHashParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserPasswordHash];
            NSString* userDevSetHomeParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserDevSetHome];
            MNUserId userId;
            NSInteger userDevSetHome;

            if (userIdParam == nil || !MNStringScanLongLong(&userId,userIdParam)) {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: user_id is not set or formated incorrectly in login_multinet_user_id_and_phash mode",MNMessageCodeInvalidUserIdInLoginMultiNetUserIdAndPhashModeInternalError)];
            }
            else if (userPasswordHashParam == nil) {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: user_password_hash is not set in login_multinet_user_id_and_phash mode",MNMessageCodeUserPasswordHashNotSetInLoginMultiNetUserIdAndPhashModeInternalError)];
            }
            else {
                if (userDevSetHomeParam == nil) {
                    userDevSetHome = 0;
                }
                else if (!MNStringScanInteger(&userDevSetHome,userDevSetHomeParam)) {
                    userDevSetHome = 0;
                }

                [_session loginWithUserId: userId passwordHash: userPasswordHashParam saveCredentials: userDevSetHome];
            }
        }
        else if ([modeParam isEqualToString: MNUserProfileViewConnectRequestModeMultiNetByAuthSign]) {
            NSString* userIdParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserId];
            NSString* userAuthSignParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserAuthSign];
            MNUserId userId;

            if (userIdParam == nil || !MNStringScanLongLong(&userId,userIdParam)) {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: user_id is not set or formated incorrectly in login_multinet_user_id_and_auth_sign mode",MNMessageCodeInvalidUserIdInLoginMultiNetUserIdAndAuthSignModeInternalError)];
            }
            else if (userAuthSignParam == nil) {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: user_password_hash is not set in login_multinet_user_id_and_auth_sign mode",MNMessageCodeUserAuthSignNotSetInLoginMultiNetUserIdAndAuthSignModeInternalError)];
            }
            else {
                [_session loginWithUserId: userId authSign: userAuthSignParam];
            }
        }
        else if ([modeParam isEqualToString: MNUserProfileViewConnectRequestModeMultiNetAuto]) {
                [_session loginAuto];
        }
        else if ([modeParam isEqualToString: MNUserProfileViewConnectRequestModeMultiNet]) {
            NSString* userLoginParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserLogin];
            NSString* userPasswordParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserPassword];
            NSString* userDevSetHomeParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserDevSetHome];
            NSInteger userDevSetHome;

            if (userLoginParam == nil) {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: user_login is not set in login_multinet mode",MNMessageCodeUserLoginNotSetInLoginMultiNetModeInternalError)];
            }
            else if (userPasswordParam == nil) {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: user_password is not set in login_multinet mode",MNMessageCodeUserPasswordNotSetInLoginMultiNetModeInternalError)];
            }
            else {
                if (userDevSetHomeParam == nil) {
                    userDevSetHome = 0;
                }
                else if (!MNStringScanInteger(&userDevSetHome,userDevSetHomeParam)) {
                    userDevSetHome = 0;
                }

                [_session loginWithUserLogin: userLoginParam password: userPasswordParam saveCredentials: userDevSetHome];
            }
        }
        else if ([modeParam isEqualToString: MNUserProfileViewConnectRequestModeMultiNetByAuthSignOffline]) {
            NSString* userIdParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserId];
            NSString* userAuthSignParam = (NSString*)[params objectForKey: MNUserProfileViewConnectRequestParamUserAuthSign];
            MNUserId userId;

            if (userIdParam == nil || !MNStringScanLongLong(&userId,userIdParam)) {
                NSLog(@"Warning: user_id is not set or formated incorrectly in login_multinet_user_id_and_auth_sign_offline mode");
            }
            else if (userAuthSignParam == nil) {
                NSLog(@"Warning: user_auth_sign is not set in login_multinet_user_id_and_auth_sign_offline mode");
            }
            else {
                [_session loginOfflineWithUserId: userId authSign: userAuthSignParam];
            }
        }
        else if ([modeParam isEqualToString: MNUserProfileViewConnectRequestModeMultiNetSignupOffline]) {
            [_session signupOffline];
        }
        else {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: invalid connect mode",MNMessageCodeInvalidConnectModeInternalError)];
        }
    }
    else {
        [self callSetErrorMessage: MNLocalizedString(@"internal error: connect mode is not set",MNMessageCodeConnectModeIsNotSetInternalError)];
    }
}

- (void)handleReconnectRequest: (NSDictionary*) params {
    if ([_session getStatus] == MN_OFFLINE && [_session isReLoginPossible]) {
        [_session reLogin];
    }

    if (_webServerURL == nil) {
        _webServerURL = [[_session getWebFrontURL] retain];
    }

    if (_webServerURL != nil) {
        [self loadStartPage];
    }
}

- (void)handleLogoutRequest: (NSDictionary*) params {
    if (_session != nil) {
        NSString* wipeHomeParam = (NSString*)[params objectForKey: MNUserProfileViewLogoutRequestParamWipeHome];
        NSInteger wipeMode;

        if  (wipeHomeParam != nil && MNStringScanInteger(&wipeMode,wipeHomeParam)) {
        }
        else {
            wipeMode = MN_CREDENTIALS_WIPE_NONE;
        }

        [_session logoutAndWipeUserCredentialsByMode: wipeMode];

        [self invalidateDeviceUsersInfo];
    }
}

- (void) handleSendPrivateMessageRequest: (NSDictionary*) params {
    if (params != nil) {
        NSString* toUserSFIdParam = (NSString*)[params objectForKey: MNUserProfileViewSendMessRequestParamToUserSFId];
        NSString* messageTextParam = (NSString*)[params objectForKey: MNUserProfileViewSendMessRequestParamMessText];

        if (toUserSFIdParam == nil) {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: receiver user id is not set in private message sending request",MNMessageCodeUserIdNotSetInPvtMessageSendingRequestInternalError)];
        }
        else if (messageTextParam == nil)
        {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: message text is not set in private message sending request",MNMessageCodeMessageTextIsNotSetInPvtMessageSendingRequestInternalError)];
        }
        else {
            NSInteger toUserSFId;

            if (!MNStringScanInteger(&toUserSFId,toUserSFIdParam)) {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: receiver user id is invalid in private message sending request",MNMessageCodeUserIdIsInvalidInPvtMessageSendingRequestInternalError)];
            }
            else {
                [_session sendPrivateMessage: messageTextParam to: toUserSFId];
            }
        }
    }
}

- (void) handleSendPublicMessageRequest: (NSDictionary*) params {
    if (params != nil) {
        NSString* messageTextParam = (NSString*)[params objectForKey: MNUserProfileViewSendMessRequestParamMessText];

        if (messageTextParam == nil) {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: message text is not set in public message sending request",MNMessageCodeMessageTextIsNotSetInPubMessageSendingRequestInternalError)];
        }
        else {
            [_session sendChatMessage: messageTextParam];
        }
    }
}

- (void) handleJoinBuddyRoomRequest: (NSDictionary*) params {
    if (_session == nil || (![_session isOnline])) {
        return;
    }

    if (params != nil) {
        NSString* roomSFIdParam = [params objectForKey: MNUserProfileViewJoinBuddyRoomRequestParamRoomSFId];
        NSInteger roomSFId;

        if (roomSFIdParam != nil) {
            if (MNStringScanInteger(&roomSFId,roomSFIdParam)) {
                [_session reqJoinBuddyRoom: roomSFId];
            }
            else {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: invalid room id in join buddy room request",MNMessageCodeInvalidRoomIdInJoinBuddyRoomRequestInternalError)];
            }
        }
        else {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: room id is not set in join buddy room request",MNMessageCodeRoomIdNotSetInJoinBuddyRoomRequestInternalError)];
        }
    }
}

-(void) handleStartRoomGameRequest {
    if (_session == nil || [_session getStatus] != MN_IN_GAME_WAIT) {
        [self callSetErrorMessage: MNLocalizedString(@"Room not ready",MNMessageCodeRoomIsNotReadyToStartAGameError)];
    }
    else {
        [_session reqStartBuddyRoomGame];
    }
}

#define MNSFUserInfoJSEntryApproxLength (128)

- (void) handleGetRoomUserListRequest: (NSDictionary*) params {
    if (_session == nil || (![_session isOnline])) {
        return;
    }

    NSArray* userList = [_session getRoomUserList];
    NSUInteger userCount = [userList count];
    NSMutableString* javaScriptSrc = [[NSMutableString alloc] initWithCapacity: MNSFUserInfoJSEntryApproxLength * (userCount + 1)];

    [javaScriptSrc appendFormat: @"MN_InRoomUserList(new Array("];

    for (NSUInteger index = 0; index < userCount; index++) {
        MNUserInfo* userInfo = [userList objectAtIndex: index];

        if (index > 0) {
            [javaScriptSrc appendString: @","];
        }

        [javaScriptSrc appendFormat: @"new MN_SF_UserInfo(%d,%@,'%lld')",
                                     userInfo.userSFId,
                                     MNStringAsJSString(userInfo.userName),
                                     userInfo.userId];
    }

    [javaScriptSrc appendString: @"));"];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

- (void) handleImportUserPhotoRequest: (NSDictionary*) params {
    if (![_session isUserLoggedIn]) {
        [self callSetErrorMessage: MNLocalizedString(@"You must be connected to import your photo",MNMessageCodeYouMustBeConnectedToImportYourPhotoError)];

        return;
    }

    BOOL photoLibrarySourceAvailable = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL cameraSourceAvailable = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
    BOOL savedPhotosAlbumSourceAvailable = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    if (photoLibrarySourceAvailable || cameraSourceAvailable || savedPhotosAlbumSourceAvailable) {
        imageSourceActionSheet = [[UIActionSheet alloc] initWithTitle: @"Choose image source" delegate: self cancelButtonTitle: nil destructiveButtonTitle: nil otherButtonTitles: nil];
        availableImageSourceCount = 0;

        if (photoLibrarySourceAvailable) {
            imageSourceSelectors[availableImageSourceCount].imageSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imageSourceSelectors[availableImageSourceCount].buttonIndex = [imageSourceActionSheet addButtonWithTitle: @"Photo albums"];
            availableImageSourceCount++;
        }

        if (cameraSourceAvailable) {
            imageSourceSelectors[availableImageSourceCount].imageSourceType = UIImagePickerControllerSourceTypeCamera;
            imageSourceSelectors[availableImageSourceCount].buttonIndex = [imageSourceActionSheet addButtonWithTitle: @"Camera"];
            availableImageSourceCount++;
        }

        if (savedPhotosAlbumSourceAvailable) {
            imageSourceSelectors[availableImageSourceCount].imageSourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            imageSourceSelectors[availableImageSourceCount].buttonIndex = [imageSourceActionSheet addButtonWithTitle: @"Saved photos"];
            availableImageSourceCount++;
        }

        imageSourceActionSheet.cancelButtonIndex = [imageSourceActionSheet addButtonWithTitle: @"Cancel"];

        [imageSourceActionSheet showInView: self];
    }
    else {
        [self callSetErrorMessage: MNLocalizedString(@"No available images source found",MNMessageCodeNoAvailableImagesSourceFoundError)];
    }
}

-(void) handleSetRoomUserStatusRequest: (NSDictionary*) params {
    if (_session == nil || (![_session isOnline])) {
        return;
    }

    if (params != nil) {
        NSString* userStatusParam = [params objectForKey: MNUserProfileViewSetRoomUserStatusRequestParamUserStatus];
        NSInteger userStatus;

        if (userStatusParam != nil) {
            if (MNStringScanInteger(&userStatus,userStatusParam)) {
                [_session reqSetUserStatus: userStatus];
            }
            else {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: invalid user status in \"set user status\" request",MNMessageCodeInvalidUserStatusInSetUserStatusRequestInternalError)];
            }
        }
        else {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: user status is not set in \"set user status\" request",MNMessageCodeUserStatusNotSetInSetUserStatusRequestInternalError)];
        }
    }
}

-(void) actionSheet:(UIActionSheet*) actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex {
    if (actionSheet == imageSourceActionSheet) {
        BOOL sourceSelected;
        NSUInteger sourceType;
        NSUInteger index;

        sourceSelected = NO;
        index = 0;

        while (!sourceSelected && index < availableImageSourceCount) {
            if (imageSourceSelectors[index].buttonIndex == buttonIndex) {
                sourceSelected = YES;
                sourceType = imageSourceSelectors[index].imageSourceType;
            }
            else {
                index++;
            }
        }

        if (sourceSelected) {
            MNTransparentViewController* baseController = [[MNTransparentViewController alloc] initWithTarget: self action: @selector(handleUserImageSelection:)];
            UIImagePickerController* pickerController = [[UIImagePickerController alloc] init];

            pickerController.sourceType = sourceType;
            pickerController.delegate = baseController;

            [baseController presentModalViewController: pickerController animated: YES];
        }
    }
}

static UIImage* MNImageCopyScaledCenteredImage(UIImage* srcImage, CGFloat maxDimension) {
    CGSize srcSize = srcImage.size;
    CGFloat scaleFactor;

    if (srcSize.width > srcSize.height) {
        scaleFactor = maxDimension / srcSize.width;
    }
    else {
        scaleFactor = maxDimension / srcSize.height;
    }

    CGSize scaledSize = CGSizeMake(srcSize.width * scaleFactor,srcSize.height * scaleFactor);

    UIImage* scaledImage;

    UIGraphicsBeginImageContext(CGSizeMake(maxDimension,maxDimension));

    CGContextRef context = UIGraphicsGetCurrentContext();
/*
    CGContextTranslateCTM(context,0.0f,maxDimension);
    CGContextScaleCTM(context,1.0f,-1.0f);
*/
    CGContextSetRGBFillColor(context,0.0f,0.0f,0.0f,0.0f);
    CGContextFillRect(context,CGRectMake(0.0f,0.0f,maxDimension,maxDimension));

    CGPoint origin = CGPointMake((maxDimension - scaledSize.width)  * 0.5f,
                                 (maxDimension - scaledSize.height) * 0.5f);

    [srcImage drawInRect: CGRectMake(origin.x,origin.y,scaledSize.width,scaledSize.height)];

    scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return [scaledImage retain];
}

-(id) handleUserImageSelection:(id) image {
    UIImage* srcImage = image;
    UIImage* scaledImage = MNImageCopyScaledCenteredImage(srcImage,MNProfileViewAvatarImageDimension);

    NSData* pngData = UIImagePNGRepresentation(scaledImage);

    if (pngData != nil) {
        NSString* pngDataInBase64 = MNDataGetBase64String(pngData);

        NSString* javaScriptSrc = [[NSString alloc] initWithFormat:
                                    @"MN_DoUserPhotoImport(%@);",
                                    MNStringAsJSString(pngDataInBase64)];

        [self callJSScript: javaScriptSrc];

        [javaScriptSrc release];
    }
    else {
        [self callSetErrorMessage: MNLocalizedString(@"can not convert image to PNG format",MNMessageCodeImageConversionToPNGFormatFailedError)];
    }

    [scaledImage release];

    return nil;
}

- (void) handleNavBarShowRequest: (NSDictionary*) params {
    NSString* navBarURL = [params objectForKey: MNUserProfileViewRequestParamNavBarURL];
    NSString* navBarHeight = [params objectForKey: MNUserProfileViewRequestParamNavBarHeight];

    if (navBarURL != nil) {
        NSInteger newHeight;/* = MNProfileViewNavBarDefaultHeight;*/

        if (navBarHeight != nil && MNStringScanInteger(&newHeight,navBarHeight)) {
            if (newHeight < 0) {
                newHeight = MNProfileViewNavBarDefaultHeight;
            }
        }
        else {
            newHeight = MNProfileViewNavBarDefaultHeight;
        }

//        if (_navBarCurrentURL == nil || [navBarURL compare: _navBarCurrentURL] != NSOrderedSame || newHeight != _navBarWebView.frame.size.height) {
        if (_navBarCurrentURL == nil || (![navBarURL isEqualToString: _navBarCurrentURL])) {
            startNavLoaded = NO;

            [_navBarWebView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: navBarURL]]];

            [_navBarCurrentURL release];
            _navBarCurrentURL = [[NSString alloc] initWithString: navBarURL];
        }

        if (_navBarWebView.hidden || newHeight != _navBarWebView.frame.size.height) {
            CGRect navBarFrame  = _navBarWebView.frame;

            navBarFrame.size.height = newHeight;

            _navBarWebView.frame = navBarFrame;

            _navBarWebView.hidden = NO;

            [self setNeedsLayout];
        }
    }
    else {
        NSLog(@"note: navbar_url parameter is not set in apphost_navbar_show request");
    }
}

- (void) handleNavBarHideRequest: (NSDictionary*) params {
    if (!_navBarWebView.hidden) {
        _navBarWebView.hidden = YES;

        [self setNeedsLayout];
    }
}

- (void) handleScriptEvalRequest: (NSDictionary*) params {
    NSString* jsCode = [params objectForKey: MNUserProfileViewRequestParamJScriptEval];

    if (jsCode != nil) {
        NSString* forceParam = [params objectForKey: MNUserProfileViewRequestParamJScriptEvalForce];

        if ([forceParam isEqualToString: @"1"]) {
            [self callJSScriptForcely: jsCode];
        }
        else {
            [self callJSScript: jsCode];
        }
    }
    else {
        NSLog(@"note: jscript_eval parameter is not set in apphost_script_eval request");
    }
}

- (void) handleWebViewReloadRequest: (NSDictionary*) params {
    NSString* urlString = [params objectForKey: MNUserProfileViewWebViewReloadRequestParamWebViewUrl];

    if (urlString != nil) {
        if (_webView.loading) {
            [_webView stopLoading];
        }

        [_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: urlString]]];

/*
        [_webView stringByEvaluatingJavaScriptFromString:
                   [NSString stringWithFormat: @"location.replace('%@')",urlString]];
*/
    }
    else {
        NSLog(@"note: webview_url parameter is not set in apphost_webview_reload request");
    }
}

- (void) handleVarSaveRequest: (NSDictionary*) params {
    NSString*     varName  = [params objectForKey: MNUserProfileViewRequestParamVarName];
    NSString*     varValue = [params objectForKey: MNUserProfileViewRequestParamVarValue];

    if (varName != nil) {
        [_session varStorageSetValue: varValue forVariable: varName];
    }
}

- (void) handleVarsClearRequest: (NSDictionary*) params {
    NSString*     varMasks = [params objectForKey: MNUserProfileViewRequestParamVarNameList];

    if (varMasks != nil) {
        NSArray* masks = [varMasks componentsSeparatedByString: @","];

        [_session varStorageRemoveVariablesByMasks: masks];
    }
}

- (void) handleVarsGetRequest: (NSDictionary*) params {
    NSString*     varMasks = [params objectForKey: MNUserProfileViewRequestParamVarNameList];

    if (varMasks != nil) {
        NSArray* masks = [varMasks componentsSeparatedByString: @","];

        NSDictionary* vars = [_session varStorageGetValuesByMasks: masks];

        NSMutableString* javaScriptSrc = [[NSMutableString alloc] initWithString: @"MN_HostVarUpdate(new Array("];

        BOOL needComma = NO;

        for (NSString* key in vars) {
            if (needComma) {
                [javaScriptSrc appendString: @","];
            }
            else {
                needComma = YES;
            }

            [javaScriptSrc appendFormat: @"new MN_HostVar(%@,%@)",
                           MNStringAsJSString(key),
                           MNStringAsJSString([vars objectForKey: key])];
        }

        [javaScriptSrc appendString: @"));"];

        [self callJSScript: javaScriptSrc];

        [javaScriptSrc release];
    }
}

- (void) handleConfigVarsGetRequest: (NSDictionary*) params {
    NSMutableString* javaScriptSrc = [[NSMutableString alloc] initWithFormat: @"MN_ConfigVarUpdate(new Array("];

    accumulateVarsList(javaScriptSrc,[_session getTrackingVars]);

    [javaScriptSrc appendString: @"),new Array("];

    accumulateVarsList(javaScriptSrc,[_session getAppConfigVars]);

    [javaScriptSrc appendString: @"));"];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

- (void) handleSetHostParamRequest: (NSDictionary*) params {
    NSString*     contextCallWaitLoadParam = [params objectForKey: MNUserProfileViewRequestParamContextCallWaitLoad];

    if (contextCallWaitLoadParam != nil) {
        if ([contextCallWaitLoadParam isEqualToString: @"0"]) {
            contextCallWaitLoad = NO;
        }
        else {
            contextCallWaitLoad = YES;
        }
    }
}

- (void) handleJoinAutoRoomRequest: (NSDictionary*) params {
    if (_session == nil || ![_session isOnline]) {
        [self callSetErrorMessage: MNLocalizedString(@"you must be in lobby room to join",MNMessageCodeMustBeInLobbyRoomToJoinRandomRoomError)];

        return;
    }

    if (params != nil) {
        NSString* gameSetId = [params objectForKey: MNUserProfileViewRequestParamGameSetId];

        if (gameSetId != nil) {
            [_session reqJoinRandomRoom: gameSetId];
        }
        else {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: game set id is not set in auto join request",MNMessageCodeGameSetIdNotSetInAutoJoinRequestInternalError)];
        }
    }
}

- (void) handlePlayGameRequest: (NSDictionary*) params {
    if (params != nil) {
        NSString* gameSetIdStr = [params objectForKey: MNUserProfileViewRequestParamGameSetId];
        NSString* gameSetParams = [params objectForKey: MNUserProfileViewPlayGameRequestParamGameSetParams];
        NSString* scorePostLinkId = [params objectForKey: MNUserProfileViewPlayGameRequestParamGameScorePostLinkId];
        NSString* gameSeedParam = [params objectForKey: MNUserProfileViewPlayGameRequestParamGameSeed];
        NSInteger gameSetId;
        NSInteger gameSeed;

        if (gameSetIdStr != nil && gameSetParams != nil) {
            if (MNStringScanInteger(&gameSetId,gameSetIdStr) && MNStringScanInteger(&gameSeed,gameSeedParam)) {
                NSUInteger playModel;

                if (scorePostLinkId != nil && [scorePostLinkId length] > 0) {
                    playModel = MN_PLAYMODEL_SINGLEPLAY_NET;
                }
                else {
                    playModel = MN_PLAYMODEL_SINGLEPLAY;
                }

                MNGameParams* gameParams = [[MNGameParams alloc] initWithGameSetId: gameSetId
                                                                 gameSetParams: gameSetParams
                                                                 scorePostLinkId: scorePostLinkId
                                                                 gameSeed: gameSeed
                                                                 playModel: playModel];

                NSInteger gameSetPlayParamNamePrefixLen = [MNUserProfileViewPlayGameRequestParamPlayParamNamePrefix length];

                for (NSString* name in params) {
                    if ([name hasPrefix: MNUserProfileViewPlayGameRequestParamPlayParamNamePrefix]) {
                        [gameParams addGameSetPlayParam: [name substringFromIndex: gameSetPlayParamNamePrefixLen] value: [params objectForKey: name]];
                    }
                }

                [_session startGameWithParams: gameParams];

                [gameParams release];
            }
            else {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: invalid gameset id or game seed in play game request",MNMessageCodeInvalidGameSetIdOrGameSeedInPlayGameRequestInternalError)];
            }
        }
        else {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: gameset id or gameset params is not set in play game request",MNMessageCodeGameSetIdOrGameSetParamsNotSetInPlayGameRequestInternalError)];
        }
    }
}

- (void) handleLoginFacebookRequest: (NSDictionary*) params {
    NSString* successJSStr     = [params objectForKey: @"mn_callback"];
    NSString* cancelJSStr      = [params objectForKey: @"mn_cancel"];
    NSString* permissionsStr   = [params objectForKey: @"permission"];
    NSString* error;

    [_fbLoginSuccessJS release]; _fbLoginSuccessJS = [successJSStr retain];
    [_fbLoginCancelJS release];  _fbLoginCancelJS  = [cancelJSStr retain];

    NSArray* permissions = permissionsStr == nil ? nil : [permissionsStr componentsSeparatedByString: @","];

    BOOL ok = [_session socNetFBConnectWithDelegate: self permissions: permissions andError: &error];

    if (!ok) {
        [self socNetFBLoginFailed: error];
    }
}

- (void) handleResumeFacebookRequest: (NSDictionary*) params {
    NSString* error;
    BOOL ok = [_session socNetFBResumeWithDelegate: self andError: &error];

    if (!ok) {
        [self socNetFBLoginFailed: error];
    }
}

- (void) handleLogoutFacebookRequest: (NSDictionary*) params {
    [_session socNetFBLogout];
}

- (void) handleShowFacebookPublishDialogRequest: (NSDictionary*) params {
    NSString* messagePromptStr = [params objectForKey: @"message_prompt"];
    NSString* attachmentStr    = [params objectForKey: @"attachment"];
    NSString* actionLinksStr   = [params objectForKey: @"action_links"];
    NSString* targetIdStr      = [params objectForKey: @"target_id"];
    NSString* successJSStr     = [params objectForKey: @"mn_callback"];
    NSString* cancelJSStr      = [params objectForKey: @"mn_cancel"];

    if (messagePromptStr != nil && attachmentStr != nil && actionLinksStr != nil &&
        targetIdStr != nil && successJSStr != nil && cancelJSStr != nil) {
        [_fbPublishSuccessJS release]; _fbPublishSuccessJS = [successJSStr retain];
        [_fbPublishCancelJS release];  _fbPublishCancelJS  = [cancelJSStr retain];

        [[_session getSocNetSessionFB] showStreamDialogWithPrompt: messagePromptStr
                                                       attachment: attachmentStr
                                                         targetId: targetIdStr
                                                      actionLinks: actionLinksStr
                                                      andDelegate: self];
    }
}

- (void) handleShowFacebookPermissionDialogRequest: (NSDictionary*) params {
    NSString* permissionStr = [params objectForKey: @"permission"];
    NSString* successJSStr     = [params objectForKey: @"mn_callback"];
    NSString* cancelJSStr      = [params objectForKey: @"mn_cancel"];

    if (permissionStr != nil && successJSStr != nil && cancelJSStr != nil) {
        [_fbPermissionSuccessJS release]; _fbPermissionSuccessJS = [successJSStr retain];
        [_fbPermissionCancelJS release];  _fbPermissionCancelJS  = [cancelJSStr retain];

        [[_session getSocNetSessionFB] showPermissionDialogWithPermission: permissionStr andDelegate: self];
    }
}

- (void) handleExecUICommandRequest: (NSDictionary*) params {
    NSString* cmdNameParam  = [params objectForKey: @"command_name"];
    NSString* cmdParamParam = [params objectForKey: @"command_param"];

    if (cmdNameParam != nil) {
        [_session execUICommand: cmdNameParam withParam: cmdParamParam];
    }
    else {
        NSLog(@"internal error: command_name parameter is not set in exec_ui_command request");
    }
}

- (void) handlePostWebEventRequest: (NSDictionary*) params {
    NSString* eventNameParam  = [params objectForKey: @"event_name"];
    NSString* eventParamParam = [params objectForKey: @"event_param"];
    NSString* callbackIdParam = [params objectForKey: @"callback_id"];

    if (eventNameParam != nil) {
        [_session processWebEvent: eventNameParam withParam: eventParamParam andCallbackId: callbackIdParam];
    }
    else {
        NSLog(@"internal error: event_name parameter is not set in post_web_event request");
    }
}

- (void) handleAddSourceDomainRequest: (NSDictionary*) params {
    NSString* domainNameParam  = [params objectForKey: @"domain_name"];

    if (domainNameParam != nil) {
        [_trustedHosts addObject: domainNameParam];
    }
    else {
        NSLog(@"internal error: domain_name parameter is not set in add_source_domain request");
    }
}

- (void) handleRemoveSourceDomainRequest: (NSDictionary*) params {
    NSString* domainNameParam  = [params objectForKey: @"domain_name"];

    if (domainNameParam != nil) {
        [_trustedHosts removeObject: domainNameParam];
    }
    else {
        NSLog(@"internal error: domain_name parameter is not set in remove_source_domain request");
    }
}

- (void) handleAppIsInstalledQueryRequest: (NSDictionary*) params {
    NSString* schemeParam  = [params objectForKey: @"app_install_bundle_id"];

    if (schemeParam != nil) {
        NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_AppCheckInstalledCallback(%@,%@);",
                                                                    MNStringAsJSString(schemeParam),
                                                                    MNLauncherIsURLSchemeSupported(schemeParam) ? @"true" : @"false"];

        [self callJSScript: javaScriptSrc];

        [javaScriptSrc release];
    }
    else {
        NSLog(@"internal error: app_install_bundle_id parameter is not set in app_is_installed request");
    }
}

- (void) handleAppTryLaunchRequest: (NSDictionary*) params {
    NSString* schemeParam  = [params objectForKey: @"app_launch_bundle_id"];
    NSString* paramsParam  = [params objectForKey: @"app_launch_param"];

    if (schemeParam != nil && paramsParam != nil) {
        BOOL result = MNLauncherStartApp(schemeParam,paramsParam);

        NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_AppLaunchCallback(%@,%@);",
                                   MNStringAsJSString(schemeParam),result ? @"true" : @"false"];

        [self callJSScript: javaScriptSrc];

        [javaScriptSrc release];
    }
    else {
        NSLog(@"internal error: app_launch_bundle_id or app_launch_param parameter is not set in app_try_launch request");
    }
}

- (void) handleAppShowInMarketRequest: (NSDictionary*) params {
    NSString* marketURLParam  = [params objectForKey: @"app_market_url"];

    if (marketURLParam != nil) {
        if (![[UIApplication sharedApplication] openURL: [NSURL URLWithString: marketURLParam]]) {
            [self callSetErrorMessage: MNLocalizedString(@"cannot open application URL",MNMessageCodeCannonOpenApplicationURLError)];
        }
    }
    else {
        NSLog(@"internal error: app_market_url parameter is not set in app_show_in_market request");
    }
}

-(void) socNetFBLoginOk:(MNSocNetSessionFB*) session {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat:
                                @"MN_SetSNContextFacebook(new MN_SNContextFacebook('%lld',%@,%@,%d),null);",
                                [session getUserId],
                                MNStringAsJSString([session getSessionKey]),
                                MNStringAsJSString([session getSessionSecret]),
                                [session didUserStoreCredentials] ? 1 : 0];

    [self callJSScript: javaScriptSrc];

    if (_fbLoginSuccessJS != nil) {
        [self callJSScript: _fbLoginSuccessJS];
    }

    [_fbLoginSuccessJS release]; _fbLoginSuccessJS = nil;
    [_fbLoginCancelJS  release]; _fbLoginCancelJS  = nil;

    [javaScriptSrc release];
}

-(void) socNetFBLoginFailed:(NSString*) error {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat:
                                @"MN_SetSNContextFacebook(null,%@);",
                                MNStringAsJSString(error)];

    [self callJSScript: javaScriptSrc];

    [_fbLoginSuccessJS release]; _fbLoginSuccessJS = nil;
    [_fbLoginCancelJS  release]; _fbLoginCancelJS  = nil;

    [javaScriptSrc release];
}

-(void) socNetFBLoginCancelled {
    if (_fbLoginCancelJS != nil) {
        [self callJSScript: _fbLoginCancelJS];
    }

    [_fbLoginSuccessJS release]; _fbLoginSuccessJS = nil;
    [_fbLoginCancelJS  release]; _fbLoginCancelJS  = nil;
}

-(void) mnSessionSocNetLoggedOut:(NSInteger) socNetId {
    if (socNetId == MNSocNetIdFaceBook) {
        [self callJSScript: @"MN_SetSNContextFacebook(null,null);"];
    }
}

-(void) mnSessionDevUsersInfoChanged {
    [self invalidateDeviceUsersInfo];
}

#define MNABAddressBookUserInfoJSEntryApproxLength (128)

-(void) contactImportInfoReady: (NSArray*) contactArray {
    if (contactArray == nil) {
        return;
    }

    NSUInteger index;
    NSUInteger count = [contactArray count];

    NSMutableString* javaScriptSrc = [[NSMutableString alloc] initWithCapacity: MNABAddressBookUserInfoJSEntryApproxLength * count];

    [javaScriptSrc appendString: @"MN_DoUserABImport(new Array(\n"];

    for (index = 0; index < count; index++) {
        MNABContactInfo* contactInfo = [contactArray objectAtIndex: index];

        if (index > 0) {
            [javaScriptSrc appendString: @",\n"];
        }

        [javaScriptSrc appendFormat: @"new MN_AB_UserInfo(%@,%@)",
                                     MNStringAsJSString(contactInfo.contactName),
                                     MNStringAsJSString(contactInfo.email)];
    }

    [javaScriptSrc appendString: @"));"];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

- (void) handleImportAddressBookRequest {
    if ([_session isUserLoggedIn]) {
        MNABImportDialogView* abImportView = [[MNABImportDialogView alloc] initWithFrame: CGRectZero];

        abImportView.contactImportDelegate = self;
        [abImportView showOnTop];
        [abImportView release];
    }
    else {
        [self callSetErrorMessage: MNLocalizedString(@"You must be connected to import your contacts",MNMessageCodeMustBeConnectedToImportContactsError)];
    }
}

- (void) handleGetAddressBookDataRequest {
    NSArray* contactInfoArray = [MNABImportTableViewDataSource copyContactInfo];
    NSMutableString* javaScriptSrc = [[NSMutableString alloc] initWithString: @"MN_ProcUserABData(new Array("];
    NSUInteger index;
    NSUInteger count = [contactInfoArray count];

    for (index = 0; index < count; index++) {
        MNABContactInfo* contactInfo = [contactInfoArray objectAtIndex: index];

        if (index > 0) {
            [javaScriptSrc appendString: @","];
        }

        [javaScriptSrc appendFormat: @"new MN_AB_UserInfo(%@,%@)",
                                     MNStringAsJSString(contactInfo.contactName),
                                     MNStringAsJSString(contactInfo.email)];
    }

    [javaScriptSrc appendString: @"));"];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
    [contactInfoArray release];
}

- (void) handleNewBuddyRoomRequest: (NSDictionary*) params {
    if (params != nil) {
        NSString* roomName = [params objectForKey: MNUserProfileViewCreateBuddyRoomRequestParamRoomName];
        NSString* gameSetIdStr = [params objectForKey: MNUserProfileViewRequestParamGameSetId];
        NSString* toUserIdList = [params objectForKey: MNUserProfileViewCreateBuddyRoomRequestParamToUserIdList];
        NSString* toUserSFIdList = [params objectForKey: MNUserProfileViewCreateBuddyRoomRequestParamToUserSFIdList];
        NSString* inviteText = [params objectForKey: MNUserProfileViewCreateBuddyRoomRequestParamInviteText];
        NSInteger gameSetId;

        if (roomName != nil && gameSetIdStr != nil && toUserIdList != nil && toUserSFIdList != nil) {
            if (MNStringScanInteger(&gameSetId,gameSetIdStr)) {
                MNBuddyRoomParams* buddyRoomParams = [[MNBuddyRoomParams alloc] init];

                if (buddyRoomParams != nil) {
                    buddyRoomParams.roomName = roomName;
                    buddyRoomParams.gameSetId = gameSetId;
                    buddyRoomParams.toUserIdList = toUserIdList;
                    buddyRoomParams.toUserSFIdList = toUserSFIdList;
                    buddyRoomParams.inviteText = inviteText == nil ? @"" : inviteText;

                    [_session reqCreateBuddyRoom: buddyRoomParams];

                    [buddyRoomParams release];
                }
            }
            else {
                [self callSetErrorMessage: MNLocalizedString(@"internal error: invalid gameset id in newBuddyRoom request",MNMessageCodeInvalidGameSetIdInNewBuddyRoomRequestInternalError)];
            }
        }
        else {
            [self callSetErrorMessage: MNLocalizedString(@"internal error: one of the required parameters is not set in newBuddyRoom request",MNMessageCodeOneOfRequiredParametersNotSetInNewBuddyRoomRequestInternalError)];
        }
    }
}

- (void) handlePluginMessageSubscribeRequest: (NSDictionary*) params {
    if (params != nil) {
        NSString* maskStr = [params objectForKey: MNUserProfileViewPluginMsgSubscribeRequestParamPluginName];

        if (maskStr != nil) {
            [trackedPluginsStorage addMask: maskStr];
        }
    }
}

- (void) handlePluginMessageUnSubscribeRequest: (NSDictionary*) params {
    if (params != nil) {
        NSString* maskStr = [params objectForKey: MNUserProfileViewPluginMsgUnSubscribeRequestParamPluginName];

        if (maskStr != nil) {
            [trackedPluginsStorage removeMask: maskStr];
        }
    }
}

- (void) handlePluginMessageSendRequest: (NSDictionary*) params {
    if ([_session isOnline] && params != nil) {
        NSString* pluginName    = [params objectForKey: MNUserProfileViewPluginMsgSendRequestParamPluginName];
        NSString* pluginMessage = [params objectForKey: MNUserProfileViewPluginMsgSendRequestParamPluginMessage];

        if (pluginName != nil && pluginMessage != nil) {
            [_session sendPlugin: pluginName message: pluginMessage];
        }
    }
}

#define MNUIWEBVIEWHTTPREQ_FLAG_EVAL_IN_MAINWEBVIEW_MASK   (0x0001)
#define MNUIWEBVIEWHTTPREQ_FLAG_EVAL_IN_NAVBARWEBVIEW_MASK (0x0002)

-(void) mnUiWebViewHttpReqDidSucceedWithCodeToEval:(NSString*) jsCode andFlags:(unsigned int) flags {
    if (flags & MNUIWEBVIEWHTTPREQ_FLAG_EVAL_IN_MAINWEBVIEW_MASK) {
        if ([self isWebViewLocationTrusted: _webView]) {
            if (!contextCallWaitLoad || !_webView.loading) {
                [_webView stringByEvaluatingJavaScriptFromString: jsCode];
            }
        }
    }

    if (flags & MNUIWEBVIEWHTTPREQ_FLAG_EVAL_IN_NAVBARWEBVIEW_MASK) {
        if ([self isWebViewLocationTrusted: _navBarWebView]) {
            if (!contextCallWaitLoad || !_navBarWebView.loading) {
                [_navBarWebView stringByEvaluatingJavaScriptFromString: jsCode];
            }
        }
    }
}

-(void) mnUiWebViewHttpReqDidFailWithCodeToEval:(NSString*) jsCode andFlags:(unsigned int) flags {
    if (flags & MNUIWEBVIEWHTTPREQ_FLAG_EVAL_IN_MAINWEBVIEW_MASK) {
        if ([self isWebViewLocationTrusted: _webView]) {
            if (!contextCallWaitLoad || !_webView.loading) {
                [_webView stringByEvaluatingJavaScriptFromString: jsCode];
            }
        }
    }

    if (flags & MNUIWEBVIEWHTTPREQ_FLAG_EVAL_IN_NAVBARWEBVIEW_MASK) {
        if ([self isWebViewLocationTrusted: _navBarWebView]) {
            if (!contextCallWaitLoad || !_navBarWebView.loading) {
                [_navBarWebView stringByEvaluatingJavaScriptFromString: jsCode];
            }
        }
    }
}

- (void) handleSendHttpRequestRequest: (NSDictionary*) params {
    NSString* url        = [params objectForKey: @"req_url"];
    NSString* postParams = [params objectForKey: @"req_post_param"];
    NSString* okJSCode   = [params objectForKey: @"req_ok_eval"];

    NSString* failJSCode = [params objectForKey: @"req_fail_eval"];
    NSString* flagsStr   = [params objectForKey: @"req_flags"];

    if (url != nil && okJSCode != nil && failJSCode != nil && flagsStr != nil) {
        long long flags;

        if (MNStringScanLongLong(&flags,flagsStr) && flags >= 0) {
            [_httpReqQueue addRequestWithUrl: url
                                  postParams: postParams
                               successJSCode: okJSCode
                                  failJSCode: failJSCode
                                    andFlags: (unsigned int)flags];
        }
    }
}

- (void) handleSetGameResultsRequest: (NSDictionary*) params {
    NSString* scoreStr        = [params objectForKey: @"score"];
    NSString* scorePostLinkId = [params objectForKey: @"score_post_link_id"];
    NSString* gameSetIdStr    = [params objectForKey: @"gameset_id"];
    long long score;
    NSInteger gameSetId;

    if (scoreStr != nil && gameSetIdStr != nil &&
        MNStringScanLongLong(&score,scoreStr) && MNStringScanInteger(&gameSetId,gameSetIdStr)) {
        MNGameResult* gameResult = [[MNGameResult alloc] init];

        gameResult.score           = score;
        gameResult.scorePostLinkId = scorePostLinkId;
        gameResult.gameSetId       = gameSetId;

        [_session finishGameWithResult: gameResult];

        [gameResult release];
    }
    else {
        NSLog(@"internal error: invalid parameters in set_game_results call");
    }
}

- (void)callSetErrorMessage: (NSString*) error {
    [self callSetErrorMessage: error forActionCode: MNErrorInfoActionCodeUndefined];
}

- (void)callSetErrorMessage: (NSString*) error forActionCode:(NSInteger) actionCode {
    NSString* javaScriptSrc = [[NSString alloc] initWithFormat: @"MN_SetErrorMessage(%@,new MN_ErrorContext(%d));", MNStringAsJSString(error),actionCode];

    [self callJSScript: javaScriptSrc];

    [javaScriptSrc release];
}

- (void) callJSUpdateContextGeneric: (BOOL) setMode {
    MNUserId currUserId = [_session getMyUserId];
    NSString* currUserIdValue;
    NSInteger status = [_session getStatus];
    NSString* roomIdValue;
    NSString* roomUserStatus;

    if (currUserId == MNUserIdUndefined) {
        currUserIdValue = nil;
    }
    else {
        currUserIdValue = [NSString stringWithFormat: @"%lld", currUserId];
    }

    if (status == MN_OFFLINE || status == MN_CONNECTING || status == MN_LOGGEDIN) {
        roomIdValue = nil;
    }
    else {
        roomIdValue = [NSString stringWithFormat: @"%d", [_session getCurrentRoomId]];
    }

    NSInteger roomUserStatusValue = [_session getRoomUserStatus];

    if (roomUserStatusValue == MN_USER_STATUS_UNDEFINED) {
        roomUserStatus = nil;
    }
    else {
        roomUserStatus = [NSString stringWithFormat: @"%d", roomUserStatusValue];
    }

    NSMutableString* javaScriptSrc = [[NSMutableString alloc] initWithCapacity: MNJSUpdateContextJSSrcInitialLen];

    MNSocNetSessionFB* fbSession = [_session getSocNetSessionFB];

    NSString* fbContext;

    if ([fbSession isConnected]) {
        fbContext = [NSString stringWithFormat: @"new MN_SNContextFacebook('%lld',%@,%@,%d)",
                              [fbSession getUserId],
                              MNStringAsJSString([fbSession getSessionKey]),
                              MNStringAsJSString([fbSession getSessionSecret]),
                              [fbSession didUserStoreCredentials] ? 1 : 0];
    }
    else {
        fbContext = @"null";
    }

    if (javaScriptSrc != nil) {
        [javaScriptSrc appendFormat:
                        @"%@("
                        @"new MN_Context(%d,%d,%@,%@,%@,%d,%@,new Array(%@),"
                        @"new Array(new MN_SNSessionInfo(%d,%d,%@)),%d,%@),"
                        @"new MN_RoomContext(%@,%d,null,%@)",
                        setMode ? @"MN_SetContext" : @"MN_UpdateContext",
                        status,
                        [_session getGameId],
                        MNStringAsJSString(currUserIdValue),
                        MNStringAsJSString([_session getMyUserName]),
                        MNStringAsJSString([_session getMySId]),
                        MNDeviceTypeiPhoneiPod,
                        MNStringAsJSString(MNGetDeviceIdMD5()),
                        [self getDeviceUsersInfoJSSrc],
                        MNSocNetIdFaceBook,
                        [fbSession isConnected] ? 10 : ([fbSession didUserStoreCredentials] ? 1 : 0),
                        fbContext,
                        [_session getDefaultGameSetId],
                        MNStringAsJSString(MNLauncherGetLaunchParams([_session getHandledURL])),
                        MNStringAsJSString(roomIdValue),
                        [_session getRoomGameSetId],
                        MNStringAsJSString(roomUserStatus)];

        if (setMode) {
            [javaScriptSrc appendString: @");"];
        }
        else {
            [javaScriptSrc appendString: @",null,null);"];
        }

        if (setMode) {
//            if ((!startPageLoaded || _errorPageLoaded) && !_webView.loading) {
            if (!startPageLoaded || _errorPageLoaded) {
                if ([self isWebViewLocationTrusted: _webView]) {
                    [_webView stringByEvaluatingJavaScriptFromString: javaScriptSrc];
                }
            }
//            else if (!startNavLoaded && !_navBarWebView.loading) {
            else if (!startNavLoaded) {
                if ([self isWebViewLocationTrusted: _navBarWebView]) {
                    [_navBarWebView stringByEvaluatingJavaScriptFromString: javaScriptSrc];
                }
            }
        }
        else {
            if ([self isWebViewLocationTrusted: _webView]) {
                [_webView stringByEvaluatingJavaScriptFromString: javaScriptSrc];
            }

            if ([self isWebViewLocationTrusted: _navBarWebView]) {
                [_navBarWebView stringByEvaluatingJavaScriptFromString: javaScriptSrc];
            }
        }

        [javaScriptSrc release];
    }
}

- (void) callJSSetContext {
    [self callJSUpdateContextGeneric: YES];
}

- (void) callJSUpdateContext {
    [self callJSUpdateContextGeneric: NO];

    statusChangedPending = NO;
}

- (void) scheduleJSUpdateContext {
    if (!contextCallWaitLoad || !_webView.loading) {
        [self callJSUpdateContext];
    }
    else {
        statusChangedPending = YES;
    }
}

- (BOOL) isHostTrusted:(NSString*) host {
    return [_trustedHosts containsObject: host];
}

- (BOOL) isWebViewLocationALocalFile:(UIWebView*) webView {
    NSString* location = [webView stringByEvaluatingJavaScriptFromString: @"location.href"];
    NSInteger fileURLFileSchemeLen = [NSURLFileScheme length];

    if ([location length] < fileURLFileSchemeLen) {
        return NO;
    }

    return [location compare: NSURLFileScheme options: 0 range: NSMakeRange(0,fileURLFileSchemeLen)] == NSOrderedSame;
}

- (BOOL) isWebViewLocationAtTrustedHost:(UIWebView*) webView {
    NSString* location = [webView stringByEvaluatingJavaScriptFromString: @"location.href"];

    NSURL* url = [NSURL URLWithString: location];
    NSString* scheme = [url scheme];
    
    if (![scheme isEqualToString: MNURLHttpScheme] && ![scheme isEqualToString: MNURLHttpsScheme]) {
        return NO;
    }

    return [self isHostTrusted: [url host]];
}

- (BOOL) isWebViewLocationTrusted:(UIWebView*) webView {
    return [self isWebViewLocationALocalFile: webView] || [self isWebViewLocationAtTrustedHost: webView];
}

- (void) callJSScript:(NSString*) script {
    if ([self isWebViewLocationTrusted: _webView]) {
        if (!contextCallWaitLoad || !_webView.loading) {
            [_webView stringByEvaluatingJavaScriptFromString: script];
        }
    }

    if ([self isWebViewLocationTrusted: _navBarWebView]) {
        if (!contextCallWaitLoad || !_navBarWebView.loading) {
            [_navBarWebView stringByEvaluatingJavaScriptFromString: script];
        }
    }
}

- (void) callJSScriptForcely:(NSString*) script {
    if (!contextCallWaitLoad || !_webView.loading) {
        [_webView stringByEvaluatingJavaScriptFromString: script];
    }

    if (!contextCallWaitLoad || !_navBarWebView.loading) {
        [_navBarWebView stringByEvaluatingJavaScriptFromString: script];
    }
}

#if ACTIVITY_INDICATOR_ENABLED
- (void) activityIndicatorStart {
    activityIndicator.center = _webView.center;

    [activityIndicator startAnimating];
}

- (void) activityIndicatorStop {
    [activityIndicator stopAnimating];
}
#endif

-(NSString*) getDeviceUsersInfoJSSrc {
    if (deviceUsersInfoJSSrc == nil) {
        NSMutableString* devUserInfoSrc = [[NSMutableString alloc] initWithCapacity: MNJSUpdateContextDevUserInfoInitialLen];
        NSArray* devUserInfoArray = MNUserCredentialsLoad([_session getVarStorage]);
        NSInteger devUserInfoIndex;
        NSInteger devUserInfoCount = [devUserInfoArray count];

        for (devUserInfoIndex = 0; devUserInfoIndex < devUserInfoCount; devUserInfoIndex++) {
            MNUserCredentials* devUserInfo = [devUserInfoArray objectAtIndex: devUserInfoIndex];

            if (devUserInfoIndex > 0) {
                [devUserInfoSrc appendString: @","];
            }

            [devUserInfoSrc appendFormat: @"new MN_DevUserInfo('%lld',%@,%@,%d,%@)",
                            (long long)devUserInfo.userId,
                            MNStringAsJSString(devUserInfo.userName),
                            MNStringAsJSString(devUserInfo.userAuthSign),
                            (int)[devUserInfo.lastLoginTime timeIntervalSince1970],
                            MNStringAsJSString(devUserInfo.userAuxInfoText)];
        }

        deviceUsersInfoJSSrc = devUserInfoSrc;
    }

    return deviceUsersInfoJSSrc;
}

-(void) invalidateDeviceUsersInfo {
    [deviceUsersInfoJSSrc release];

    deviceUsersInfoJSSrc = nil;
}

-(void) socNetFBStreamDialogDidSucceed {
    if (_fbPublishSuccessJS != nil) {
        [self callJSScript: _fbPublishSuccessJS];
    }

    [_fbPublishSuccessJS release]; _fbPublishSuccessJS = nil;
    [_fbPublishCancelJS  release]; _fbPublishCancelJS  = nil;
}

-(void) socNetFBStreamDialogDidCancel {
    if (_fbPublishCancelJS != nil) {
        [self callJSScript: _fbPublishCancelJS];
    }

    [_fbPublishSuccessJS release]; _fbPublishSuccessJS = nil;
    [_fbPublishCancelJS  release]; _fbPublishCancelJS  = nil;
}

-(void) socNetFBStreamDialogDidFailWithError:(NSError*) error {
    [_fbPublishSuccessJS release]; _fbPublishSuccessJS = nil;
    [_fbPublishCancelJS  release]; _fbPublishCancelJS  = nil;

    [self callSetErrorMessage: [error localizedDescription]];
}

-(void) socNetFBPermissionDialogDidSucceed {
    if (_fbPermissionSuccessJS != nil) {
        [self callJSScript: _fbPermissionSuccessJS];
    }

    [_fbPermissionSuccessJS release]; _fbPermissionSuccessJS = nil;
    [_fbPermissionCancelJS  release]; _fbPermissionCancelJS  = nil;
}

-(void) socNetFBPermissionDialogDidCancel {
    if (_fbPermissionCancelJS != nil) {
        [self callJSScript: _fbPermissionCancelJS];
    }

    [_fbPermissionSuccessJS release]; _fbPermissionSuccessJS = nil;
    [_fbPermissionCancelJS  release]; _fbPermissionCancelJS  = nil;
}

-(void) socNetFBPermissionDialogDidFailWithError:(NSError*) error {
    [_fbPermissionSuccessJS release]; _fbPermissionSuccessJS = nil;
    [_fbPermissionCancelJS  release]; _fbPermissionCancelJS  = nil;

    [self callSetErrorMessage: [error localizedDescription]];
}

@end
