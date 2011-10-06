//
//  MNSmartFoxFacade.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/20/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "external/SmartFox/Header/INFSmartFoxiPhoneClient.h"
#import "external/SmartFox/Header/Handlers/INFSmartFoxSFSEvent.h"
#import "external/SmartFox/Header/Data/INFSmartFoxUser.h"
#import "external/SmartFox/Header/Data/INFSmartFoxRoom.h"

#import "MNTools.h"
#import "MNNetworkStatus.h"
#import "MNMessageCodes.h"
#import "MNSmartFoxFacade.h"

static NSString* MNSmartFoxExtCmdLogOk = @"MN_logOK";
static NSString* MNSmartFoxExtCmdLogErr = @"MN_logKO";
static NSString* MNSmartFoxExtCmdInitUserInfo = @"initUserInfo";

static NSString* MNSmartFoxExtCmdLogOkParamUserId   = @"MN_user_id";
static NSString* MNSmartFoxExtCmdLogOkParamUserSFId = @"MN_user_sfid";
static NSString* MNSmartFoxExtCmdLogOkParamUserName = @"MN_user_name";
static NSString* MNSmartFoxExtCmdLogOkParamUserSId  = @"MN_user_sid";
static NSString* MNSmartFoxExtCmdLogOkParamLobbyRoomId = @"MN_lobby_room_sfid";
static NSString* MNSmartFoxExtCmdLogOkParamUserAuthSign = @"MN_user_auth_sign";

enum {
    MN_SF_STATE_DISCONNECTED = 0,
    MN_SF_STATE_LOADING_CONFIG,
    MN_SF_STATE_CONNECTING,
    MN_SF_STATE_CONNECTED,
    MN_SF_STATE_LOGGED_IN
};

static BOOL sfReadParamSuccess (NSDictionary *params) {
    return [(NSNumber*)[params objectForKey:@"success"] boolValue];
}

static NSString* sfReadParamError (NSDictionary *params) {
    return (NSString*)[params objectForKey:@"error"];
}

/* a class extension to declare private methods */
@interface MNSmartFoxFacade()
/* INFSmartFoxISFSEvents protocol methods */

-(void) onConnection: (INFSmartFoxSFSEvent*) evt;
-(void) onLogin: (INFSmartFoxSFSEvent*) evt;
-(void) onConnectionLost: (INFSmartFoxSFSEvent*) evt;
-(void) onExtensionResponse: (INFSmartFoxSFSEvent*) evt;

/* MNConfigDataDelegate protocol methods */
-(void) mnConfigDataLoaded:(MNConfigData*) configData;
-(void) mnConfigDataLoadDidFailWithError:(NSString*) error;

/* private methods */

-(void) onExtLoginOk: (NSDictionary*) params;
-(void) handleLoginFailedCondition:(NSString*) error;
-(void) handleReconnectFailedCondition;
-(void) loginWithStoredLoginInfo;

@end

@interface MNSmartFoxFacadeLoginInfo: NSObject {
    @private

    NSString* _userLogin;
    NSString* _userPassword;
    NSString* _zone;
}

@property (nonatomic,retain) NSString* userLogin;
@property (nonatomic,retain) NSString* userPassword;
@property (nonatomic,retain) NSString* zone;

-(id)   init;
-(void) dealloc;

@end

@interface MNSmartFoxFacadeSessionInfo: NSObject {
    @private

    MNUserId  _userId;
    NSString* _userName;
    NSString* _sid;
    NSInteger _lobbyRoomId;
    NSString* _userAuthSign;
}

@property (nonatomic,assign) MNUserId  userId;
@property (nonatomic,retain) NSString* userName;
@property (nonatomic,retain) NSString* sid;
@property (nonatomic,assign) NSInteger lobbyRoomId;
@property (nonatomic,retain) NSString* userAuthSign;

-(id)   init;
-(void) dealloc;

@end


#define MNSmartFoxFacadeConnectActivityStateInactive       (0)
#define MNSmartFoxFacadeConnectActivityStateWaitForNetwork (1)
#define MNSmartFoxFacadeConnectActivityStateWaitForConnect (2)

#define MNSmartFoxFacadeConnectActivityNetStatusCheckMaxCount (60)
#define MNSmartFoxFacadeConnectActivityNetStatusCheckInterval (5.0f)
#define MNSmartFoxFacadeConnectActivityLoginRetryMaxCount     (5)
#define MNSmartFoxFacadeConnectActivityLoginRetryInterval     (5.0f)

/*
 How reconnect works...

 First step: waiting for network availability by checking for network status
 each NetworkStatusCheckInterval seconds. If NetworkStatusCheckMaxCount checks done
 and network is not available, connect activity stops.

 Second step (if network is available): trying to login. If login was not successful,
 wait for LoginRetryInterval and go to first step.

 If second step failed LoginRetryMaxCount times, connect activity stops.
*/

@interface MNSmartFoxFacadeConnectActivity : NSObject {
    @private

    NSInteger _state;
    NSInteger _netCheckCount;
    NSInteger _loginRetryCount;
    MNSmartFoxFacade* _smartFoxFacade;
}

-(id) initWithSmartFoxFacade:(MNSmartFoxFacade*) smartFoxFacade;
-(void) dealloc;

-(void) start;
-(void) cancel;

-(void) connectionEstablished;
-(void) connectionFailed;

-(BOOL) isWaitingForConnect;

@end

/* private methods */
@interface MNSmartFoxFacadeConnectActivity()

-(void) checkNetwork;
-(void) tryConnect;

@end


@implementation  MNSmartFoxFacadeConnectActivity

-(id) initWithSmartFoxFacade:(MNSmartFoxFacade*) smartFoxFacade {
    self = [super init];

    if (self != nil) {
        _state = MNSmartFoxFacadeConnectActivityStateInactive;
        _netCheckCount = 0;
        _loginRetryCount = 0;

        _smartFoxFacade = smartFoxFacade;
    }

    return self;
}

-(void) dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(checkNetwork) object: nil];

    [super dealloc];
}

-(void) start {
    if (_state == MNSmartFoxFacadeConnectActivityStateInactive) {
        _state = MNSmartFoxFacadeConnectActivityStateWaitForNetwork;
        _netCheckCount = 0;
        _loginRetryCount = 0;

        [self checkNetwork];
    }
}

-(void) cancel {
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(checkNetwork) object: nil];

    _state = MNSmartFoxFacadeConnectActivityStateInactive;
}

-(void) checkNetwork {
    if (_state == MNSmartFoxFacadeConnectActivityStateWaitForNetwork) {
        _netCheckCount++;

        if ([MNNetworkStatus haveInternetConnection]) {
            _state = MNSmartFoxFacadeConnectActivityStateWaitForConnect;

            [self tryConnect];
        }
        else {
            if (_netCheckCount < MNSmartFoxFacadeConnectActivityNetStatusCheckMaxCount) {
                    [self performSelector: @selector(checkNetwork) withObject: nil afterDelay: MNSmartFoxFacadeConnectActivityNetStatusCheckInterval];
            }
            else {
                [self cancel];

                [_smartFoxFacade handleReconnectFailedCondition];
            }
        }
    }
}

-(void) tryConnect {
    _loginRetryCount++;
    [_smartFoxFacade loginWithStoredLoginInfo];
}

-(void) connectionEstablished {
    [self cancel];
}

-(void) connectionFailed {
    if (_state == MNSmartFoxFacadeConnectActivityStateWaitForConnect) {
        if (_loginRetryCount < MNSmartFoxFacadeConnectActivityLoginRetryMaxCount) {
                _state = MNSmartFoxFacadeConnectActivityStateWaitForNetwork;
                _netCheckCount = 0;

                [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(checkNetwork) object: nil];
                [self performSelector: @selector(checkNetwork) withObject: nil afterDelay: MNSmartFoxFacadeConnectActivityLoginRetryInterval];
        }
        else {
            [self cancel];

            [_smartFoxFacade handleReconnectFailedCondition];
        }
    }
    else {
        [self cancel]; /* concurrent activity detected, cancel activity */
    }
}

-(BOOL) isWaitingForConnect {
    return _state == MNSmartFoxFacadeConnectActivityStateWaitForConnect && _loginRetryCount < MNSmartFoxFacadeConnectActivityLoginRetryMaxCount;
}

@end


@implementation MNSmartFoxFacadeLoginInfo

@synthesize userLogin    = _userLogin;
@synthesize userPassword = _userPassword;
@synthesize zone         = _zone;

-(id) init {
    self = [super init];

    return self;
}

-(void) dealloc {
    [_zone release];
    [_userPassword release];
    [_userLogin release];
    [super dealloc];
}

@end


@implementation MNSmartFoxFacadeSessionInfo

@synthesize userId       = _userId;
@synthesize userName     = _userName;
@synthesize sid          = _sid;
@synthesize lobbyRoomId  = _lobbyRoomId;
@synthesize userAuthSign = _userAuthSign;

-(id) init {
    self = [super init];

    return self;
}

-(void) dealloc {
    [_userName release];
    [_sid release];
    [_userAuthSign release];

    [super dealloc];
}

@end


@implementation MNSmartFoxFacade

@synthesize smartFox;
@synthesize delegate;
@synthesize smartFoxDelegate;
@synthesize reconnectOnNetErrors;

-(id) initWithConfigRequest:(NSURLRequest*) configRequest {
    self = [super init];

    if (self != nil) {
        self.smartFox = [INFSmartFoxiPhoneClient iPhoneClient: NO delegate: self];

        configData = [[MNConfigData alloc] initWithConfigRequest: configRequest];

        state = MN_SF_STATE_DISCONNECTED;
        loginOnConfigLoaded = NO;

        loginInfo = [[MNSmartFoxFacadeLoginInfo alloc] init];
        connectActivity = [[MNSmartFoxFacadeConnectActivity alloc] initWithSmartFoxFacade: self];

        reconnectOnNetErrors = YES;
    }

    return self;
}

-(void) dealloc {
    [sessionInfo release];
    [configData release];
    [connectActivity release];
    [loginInfo release];
    [smartFox release];
    [super dealloc];
}

-(BOOL) haveLoginInfo {
    return loginInfo.userLogin != nil;
}

-(BOOL) isLoggedIn {
    return state == MN_SF_STATE_LOGGED_IN;
}

-(NSString*) getLoginInfoLogin {
    return loginInfo.userLogin;
}

-(void) updateLoginInfoWithLogin:(NSString*) login andPassword:(NSString*) password {
    loginInfo.userLogin    = login;
    loginInfo.userPassword = password;
}

-(void) loadConfig {
    if (state == MN_SF_STATE_DISCONNECTED) {
        state = MN_SF_STATE_LOADING_CONFIG;

        [delegate mnConfigLoadStarted];

        [configData loadWithDelegate: self];
    }
}

-(void) loginWithStoredLoginAndConfigInfo {
    state = MN_SF_STATE_CONNECTING;

    [smartFox->_blueBoxIpAddress release];
    smartFox->_blueBoxIpAddress = [configData.blueBoxAddr copy];
    smartFox->_blueBoxPort = configData.blueBoxPort;
    smartFox->_smartConnect = configData.smartConnect;
    [smartFox connect: configData.smartFoxAddr port: configData.smartFoxPort];
}

-(void) loginWithStoredLoginInfo {
    if (state != MN_SF_STATE_LOADING_CONFIG) {
        state = MN_SF_STATE_DISCONNECTED;
    }

    if (smartFox.isConnected) {
        [smartFox disconnect];
    }

    if ([configData isLoaded]) {
        [self loginWithStoredLoginAndConfigInfo];
    }
    else {
        loginOnConfigLoaded = YES;

        if (state != MN_SF_STATE_LOADING_CONFIG) {
            state = MN_SF_STATE_LOADING_CONFIG;

            [delegate mnConfigLoadStarted];

            [configData loadWithDelegate: self];
        }
    }
}

-(void) loginAs:(NSString*) userLogin withPassword:(NSString*) userPassword
        toZone:(NSString*) zone {
    [connectActivity cancel];

    if (smartFox.isConnected) {
        [smartFox disconnect];
    }

    loginInfo.zone = zone;
    loginInfo.userLogin = userLogin;
    loginInfo.userPassword = userPassword;

    [self loginWithStoredLoginInfo];
}

-(void) logout {
    [connectActivity cancel];

    if (state == MN_SF_STATE_LOGGED_IN) {
        [smartFox logout];
    }

    if (state != MN_SF_STATE_DISCONNECTED) {
        [smartFox disconnect];
    }

    state = MN_SF_STATE_DISCONNECTED;

    [configData clear];
}

-(void) relogin {
    [connectActivity cancel];

    [self loginWithStoredLoginInfo];
}

-(void) restoreConnection {
    if (!smartFox.isConnected) {
        [connectActivity start];
    }
}

-(NSString*) getUserNameBySFId:(NSInteger) userSFId {
    if (!smartFox.isConnected) {
        return nil;
    }

    INFSmartFoxUser* user = [[smartFox getActiveRoom] getUser: [NSNumber numberWithInteger: userSFId]];

    if (user == nil) {
        return nil;
    }

    return [user getName];
}

-(void) mnConfigDataLoaded:(MNConfigData*) configData {
    if (loginOnConfigLoaded) {
        loginOnConfigLoaded = NO;

        [self loginWithStoredLoginAndConfigInfo];
    }

    [delegate mnConfigDidLoad];
}

-(void) mnConfigDataLoadDidFailWithError:(NSString*) error {
    if ([connectActivity isWaitingForConnect]) {
        state = MN_SF_STATE_DISCONNECTED;

        [connectActivity connectionFailed];
    }
    else {
        if (loginOnConfigLoaded) {
            loginOnConfigLoaded = NO;

            [self handleLoginFailedCondition: error];
        }
        else {
            state = MN_SF_STATE_DISCONNECTED;
        }

        [delegate mnConfigLoadDidFailWithError: error];
    }
}

-(void) onConnectionLost: (INFSmartFoxSFSEvent*) evt {
    if (state != MN_SF_STATE_DISCONNECTED) {
        state = MN_SF_STATE_DISCONNECTED;

        if (self.delegate != nil) {
            [self.delegate onConnectionLost];
        }
    }
    else {
        NSLog(@"warning: smartFox onConnectionLost: called in disconnected state");
    }

    if ([smartFoxDelegate respondsToSelector: @selector(onConnectionLost:)]) {
        [smartFoxDelegate onConnectionLost: evt];
    }
}

-(void) onConnection: (INFSmartFoxSFSEvent*) evt {
    if (state == MN_SF_STATE_CONNECTING) {
        if (sfReadParamSuccess(evt.params)) {
            [connectActivity connectionEstablished];

            state = MN_SF_STATE_CONNECTED;
            [smartFox login: loginInfo.zone name: loginInfo.userLogin pass: loginInfo.userPassword];
        }
        else {
            [sessionInfo release]; sessionInfo = nil;

            state = MN_SF_STATE_DISCONNECTED;

            if (![connectActivity isWaitingForConnect]) {
                if (self.delegate != nil) {
                    [self.delegate onLoginFailed: sfReadParamError(evt.params)];
                }
            }

            [connectActivity connectionFailed];
        }
    }
    else {
        if (state != MN_SF_STATE_DISCONNECTED) {
            [sessionInfo release]; sessionInfo = nil;

            /* current version of SmartFox SDK sends onConnection message if */
            /* network error occured                                         */
            if (self.reconnectOnNetErrors) {
                [self logout];
                [connectActivity start];
            }
        }
    }

    if ([smartFoxDelegate respondsToSelector: @selector(onConnection:)]) {
        [smartFoxDelegate onConnection: evt];
    }
}

-(void) onLogin: (INFSmartFoxSFSEvent*) evt {
    if (state == MN_SF_STATE_CONNECTED) {
        if (sfReadParamSuccess(evt.params)) {
            if (sessionInfo == nil) {
                sessionInfo = [[MNSmartFoxFacadeSessionInfo alloc] init];
            }
            else {
                NSLog(@"warning: sessionInfo is not nil in MNSmartFoxFacade");
            }

            if (sessionInfo != nil) {
                sessionInfo.userId       = MNUserIdUndefined;
                sessionInfo.userName     = (NSString*)[evt.params objectForKey:@"name"];
                sessionInfo.sid          = nil;
                sessionInfo.lobbyRoomId  = MNLobbyRoomIdUndefined;
                sessionInfo.userAuthSign = nil;
            }
            else {
                [self handleLoginFailedCondition: MNLocalizedString(@"out of memory",MNMessageCodeOutOfMemoryError)];
            }
        }
        else {
            [self handleLoginFailedCondition: sfReadParamError(evt.params)];
        }
    }
    else {
        NSLog(@"warning: unexpected smartFox onLogin: call");
    }

    if ([smartFoxDelegate respondsToSelector: @selector(onLogin:)]) {
        [smartFoxDelegate onLogin: evt];
    }
}

-(void) onExtLoginOk: (NSDictionary*) params {
    NSString *receivedId          = MNDictionaryStringForKey(params,MNSmartFoxExtCmdLogOkParamUserId);
    NSString *receivedSFId        = MNDictionaryStringForKey(params,MNSmartFoxExtCmdLogOkParamUserSFId);
    NSString *receivedName        = MNDictionaryStringForKey(params,MNSmartFoxExtCmdLogOkParamUserName);
    NSString *receivedSId         = MNDictionaryStringForKey(params,MNSmartFoxExtCmdLogOkParamUserSId);
    NSString *receivedLobbyRoomId = MNDictionaryStringForKey(params,MNSmartFoxExtCmdLogOkParamLobbyRoomId);
    NSString *userAuthSign        = MNDictionaryStringForKey(params,MNSmartFoxExtCmdLogOkParamUserAuthSign);
    MNUserId userId;
    NSInteger lobbyRoomId;

    if (receivedId == nil || receivedSFId == nil || receivedName == nil || receivedSId == nil || receivedLobbyRoomId == nil) {
        [self handleLoginFailedCondition: MNLocalizedString(@"login extension error - required parameters not set",MNMessageCodeLoginExtensionRequiredParametersNotSetError)];
    }
    else {
        NSInteger userSFId;

        if (sessionInfo == nil) {
            sessionInfo = [[MNSmartFoxFacadeSessionInfo alloc] init];
        }
        else {
            NSLog(@"warning: sessionInfo is not nil in MNSmartFoxFacade");
        }

        if (sessionInfo != nil) {
            if (MNStringScanLongLong(&userId,receivedId) &&
                MNStringScanInteger(&userSFId,receivedSFId) &&
                MNStringScanInteger(&lobbyRoomId,receivedLobbyRoomId)) {

                smartFox.amIModerator = NO;
                smartFox.myUserId = userSFId;
                smartFox.myUserName = receivedName;
                smartFox.playerId = -1;

                sessionInfo.userId       = userId;
                sessionInfo.userName     = receivedName;
                sessionInfo.sid          = receivedSId;
                sessionInfo.lobbyRoomId  = lobbyRoomId;
                sessionInfo.userAuthSign = userAuthSign;

                [self.delegate onPreLoginSucceeded: sessionInfo.userId
                                          userName: sessionInfo.userName
                                           userSID: sessionInfo.sid
                                       lobbyRoomId: sessionInfo.lobbyRoomId
                                      userAuthSign: sessionInfo.userAuthSign];

                [smartFox joinRoom: [NSNumber numberWithInteger: lobbyRoomId] pword: nil isSpectator: NO dontLeave: NO oldRoom: -1];
            }
            else {
                [sessionInfo release]; sessionInfo = nil;

                [self handleLoginFailedCondition: MNLocalizedString(@"login extension error - invalid user_id or lobby_room_sfid received",MNMessageCodeLoginExtensionInvalidUserIdOrLobbyRoomSFIdReceivedError)];
            }
        }
        else {
            [self handleLoginFailedCondition: MNLocalizedString(@"out of memory",MNMessageCodeOutOfMemoryError)];
        }
    }
}

-(void) onExtInitUserInfo {
    if (sessionInfo != nil) {
        state = MN_SF_STATE_LOGGED_IN;

        [self.delegate onLoginSucceeded];

        [sessionInfo release]; sessionInfo = nil;
    }
    else {
        NSLog(@"warning: initUserInfo message arrived but session info is empty");
    }
}

-(void) onExtensionResponse: (INFSmartFoxSFSEvent*) evt {
    if (state == MN_SF_STATE_CONNECTED) {
        if ([[evt.params objectForKey: @"type"] isEqualToString: smartFox.INFSMARTFOXCLIENT_XTMSG_TYPE_XML]) {
            NSDictionary *params = [evt.params objectForKey: @"dataObj"];
            NSString* cmd = [params objectForKey: @"_cmd"];

            if ([cmd isEqualToString: MNSmartFoxExtCmdLogOk]) {
                [self onExtLoginOk: params];
            }
            else if ([cmd isEqualToString: MNSmartFoxExtCmdLogErr]) {
                [self handleLoginFailedCondition: (NSString*)[params objectForKey: @"MN_err_msg"]];
            }
            else if ([cmd isEqualToString: MNSmartFoxExtCmdInitUserInfo]) {
                [self onExtInitUserInfo];
            }
            else {
                NSLog(@"warning: unexpected extension response during login process");
            }
        }
    }

    if ([smartFoxDelegate respondsToSelector: @selector(onExtensionResponse:)]) {
        [smartFoxDelegate onExtensionResponse: evt];
    }
}

#define MNSmartFoxFacadeDefineSmartFoxDelegateMethod(name)             \
-(void) name: (INFSmartFoxSFSEvent*) evt {                             \
    if (smartFoxDelegate != nil) {                                     \
        if ([smartFoxDelegate respondsToSelector: @selector(name:)]) { \
            [smartFoxDelegate name: evt];                              \
        }                                                              \
    }                                                                  \
}

MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onAdminMessage)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onBuddyList)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onBuddyListError)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onBuddyListUpdate)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onBuddyPermissionRequest)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onBuddyRoom)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onConfigLoadFailure)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onConfigLoadSuccess)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onCreateRoomError)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onDebugMessage)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onJoinRoom)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onJoinRoomError)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onLogout)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onModMessage)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onObjectReceived)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onPrivateMessage)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onPublicMessage)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onRandomKey)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onRoomListUpdate)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onRoomAdded)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onRoomDeleted)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onRoomLeft)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onRoomVariablesUpdate)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onRoundTripResponse)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onSpectatorSwitched)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onUserCountChange)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onUserEnterRoom)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onUserLeaveRoom)
MNSmartFoxFacadeDefineSmartFoxDelegateMethod(onUserVariablesUpdate)

#undef MNSmartFoxFacadeDefineSmartFoxDelegateMethod

-(void) handleLoginFailedCondition:(NSString*) error {
    state = MN_SF_STATE_DISCONNECTED;
    [configData clear];

    if (delegate != nil) {
        [delegate onLoginFailed: error];
    }

    [smartFox disconnect];
}

-(void) handleReconnectFailedCondition {
    [self handleLoginFailedCondition: MNLocalizedString(@"Connection to server is not available",MNMessageCodeReconnectFailedError)];
}

@end
