//
//  MNSession.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/20/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <sys/time.h>
#import <time.h>
#import <limits.h>

#import <Availability.h>

#import "external/SmartFox/Header/INFSmartFoxiPhoneClient.h"
#import "external/SmartFox/Header/Handlers/INFSmartFoxSFSEvent.h"
#import "external/SmartFox/Header/Data/INFSmartFoxRoom.h"
#import "external/SmartFox/Header/Data/INFSmartFoxUser.h"

#import "MNTools.h"
#import "MNSocNetSessionFB.h"
#import "MNNetworkStatus.h"
#import "MNMessageCodes.h"
#import "MNUserCredentials.h"
#import "MNOfflineScores.h"
#import "MNLauncherTools.h"
#import "MNTrackingSystem.h"
#import "MNGameVocabulary.h"
#import "MNSession.h"
#import "MNSessionInternal.h"

#define MNSessionFallASleepDelay (60.0 * 60.0 * 10.0)

#define MNSessionOfflineModeDisabled (YES)

static NSString* MNGameZoneNameFormat = @"Game_%d";

static NSString* MNSmartFoxExtCmdParamsKey = @"dataObj";
static NSString* MNSmartFoxExtCmdParamCmd = @"_cmd";
static NSString* MNGameMessageEscapeStr = @"~";
static NSString* MNPluginMessagePluginNameTermStr = @"^";
static NSString* MNSmartFoxExtCmdError = @"MN_error";

static NSString* MNMultiNetSmartFoxExtName = @"MultiNetExtension";
static NSString* MNSmartFoxExtCmdJoinBuddyRoom = @"joinBuddyRoom";
static NSString* MNSmartFoxExtCmdJoinRandomRoom = @"joinRandomRoom";
static NSString* MNSmartFoxExtCmdFinishGameInRoom = @"finishGameInRoom";
static NSString* MNSmartFoxExtCmdFinishGamePlain = @"finishGamePlain";
static NSString* MNSmartFoxExtCmdCreateBuddyRoom = @"createBuddyRoom";
static NSString* MNSmartFoxExtCmdStartBuddyRoomGame = @"startBuddyRoomGame";
static NSString* MNSmartFoxExtCmdStopRoomGame = @"stopRoomGame";
static NSString* MNSmartFoxExtCmdJoinRoomInvitation = @"joinRoomInvitation";
static NSString* MNSmartFoxExtCmdCurrGameResults = @"currGameResults";
static NSString* MNSmartFoxExtCmdLeaveRoom = @"leaveRoom";
static NSString* MNSmartFoxExtCmdSetUserStatus = @"setUserStatus";
static NSString* MNSmartFoxExtCmdSendGameMessage = @"sendRGM";
static NSString* MNSmartFoxExtCmdSendGameMessageRawPrefix = @"~MNRGM";
static NSString* MNSmartFoxExtCmdSendGameMessageRawPrefix2 = @"~~MNRGM";
static NSString* MNSmartFoxExtCmdInitRoomUserInfo = @"initRoomUserInfo";

static NSString* MNSmartFoxExtCmdSendPluginMessage = @"sendRPM";
static NSString* MNSmartFoxExtCmdSendPluginMessageRawPrefix = @"~MNRPM";
static NSString* MNSmartFoxExtCmdSendPluginMessageRawPrefix2 = @"~~MNRPM";

static NSString* MNSmartFoxExtCmdParamGameSetId = @"MN_gameset_id";

static NSString* MNSmartFoxExtCmdJoinBuddyRoomParamRoomSFId = @"MN_room_sfid";
static NSString* MNSmartFoxExtCmdFinishParamScore = @"MN_out_score";
static NSString* MNSmartFoxExtCmdFinishParamOutTime = @"MN_out_time";
static NSString* MNSmartFoxExtCmdFinishParamScorePostLinkId = @"MN_game_scorepostlink_id";
static NSString* MNSmartFoxExtCmdCreateBuddyRoomParamRoomName = @"MN_room_name";
static NSString* MNSmartFoxExtCmdCreateBuddyRoomParamToUserIdList = @"MN_to_user_id_list";
static NSString* MNSmartFoxExtCmdCreateBuddyRoomParamToUserSFIdList = @"MN_to_user_sfid_list";
static NSString* MNSmartFoxExtCmdCreateBuddyRoomParamMessText = @"MN_mess_text";

static NSString* MNSmartFoxExtRspCurrGameResultsParamUserIdList = @"MN_play_user_id_list";
static NSString* MNSmartFoxExtRspCurrGameResultsParamUserSFIdList = @"MN_play_user_sfid_list";
static NSString* MNSmartFoxExtRspCurrGameResultsParamUserPlaceList = @"MN_play_user_place_list";
static NSString* MNSmartFoxExtRspCurrGameResultsParamUserScoreList = @"MN_play_user_score_list";
static NSString* MNSmartFoxExtRspCurrGameResultsParamResultIsFinal = @"MN_play_result_is_final";
static NSString* MNSmartFoxExtRspCurrGameResultsParamGameId = @"MN_game_id";
static NSString* MNSmartFoxExtRspCurrGameResultsParamGameSetId = @"MN_gameset_id";
static NSString* MNSmartFoxExtRspCurrGameResultsParamPlayRoundNumber = @"MN_play_round_number";

static NSString* MNSmartFoxExtCmdJoinRoomInvitationParamFromUserSFId = @"MN_from_user_sfid";
static NSString* MNSmartFoxExtCmdJoinRoomInvitationParamFromUserName = @"MN_from_user_name";
static NSString* MNSmartFoxExtCmdJoinRoomInvitationParamRoomSFId = @"MN_room_sfid";
static NSString* MNSmartFoxExtCmdJoinRoomInvitationParamRoomName = @"MN_room_name";
static NSString* MNSmartFoxExtCmdJoinRoomInvitationParamRoomGameId = @"MN_room_game_id";
static NSString* MNSmartFoxExtCmdJoinRoomInvitationParamRoomGameSetId = @"MN_room_gameset_id";
static NSString* MNSmartFoxExtCmdJoinRoomInvitationParamMessText = @"MN_mess_text";

static NSString* MNSmartFoxExtCmdSetUserStatusParamUserStatus = @"MN_user_status";

static NSString* MNSmartFoxExtCmdSendGameMessageParamMessage = @"MN_mess_text";
static NSString* MNSmartFoxExtCmdSendPluginMessageParamMessage = @"MN_mess_text";

static NSString* MNSmartFoxExtCmdErrorParamCall = @"MN_call";
static NSString* MNSmartFoxExtCmdErrorParamErrorMessage = @"MN_err_msg";

static NSString* MNGameRoomVarNameGameStatus = @"MN_game_status";
static NSString* MNGameRoomVarNameGameSetId = @"MN_gameset_id";
static NSString* MNGameRoomVarNameGameSetParam = @"MN_gameset_param";
static NSString* MNGameRoomVarNameGameStartCountdown = @"MN_gamestart_countdown";
static NSString* MNGameRoomVarNameGameSeed = @"MN_game_seed";

static NSString* MNGameUserVarNameUserStatus = @"MN_user_status";

static NSString* MNGameSetPlayParamVarNamePrefix = @"MN_gameset_play_param_";

static NSString* MNLoginModelLoginPlusPasswordString = @"L";
static NSString* MNLoginModelIdPlusPasswordHashString = @"I";
static NSString* MNLoginModelGuestString = @"G";
static NSString* MNLoginModelAuthSignString = @"A";

static NSString* MNLoginModelGuestUserLogin = @"*";

static NSString* MNVarStorageShortFileName = @"mn_vars.dat";

static NSString* MNPersistentVarUserSingleUserMaskFormat = @"user.%lld.*";
static NSString* MNPersistentVarUserAllUsersMask = @"user.*";

static NSString* MNAppCommandSetAppPropertyPrefix = @"set";
static NSString* MNAppPropertyVarPathFormat       = @"prop.%@";

/* a class extension to declare private methods */
@interface MNSession ()
/* MNSmartFoxFacadeDelegate methods */
-(void) onPreLoginSucceeded:(MNUserId) userId
                   userName:(NSString*) userName
                    userSID:(NSString*) sid
                lobbyRoomId:(NSInteger) lobbyRoomId
               userAuthSign:(NSString*) userAuthSign;
-(void) onLoginSucceeded;
-(void) onLoginFailed:(NSString*) error;
-(void) onConnectionLost;
-(void) mnConfigLoadStarted;
-(void) mnConfigDidLoad;
-(void) mnConfigLoadDidFailWithError:(NSString*) error;

/* MNSocNetFBDelegate methods */
-(void) socNetFBLoginOk:(MNSocNetSessionFB*) session;
-(void) socNetFBLoginCanceled;
-(void) socNetFBLoginFailed;
-(void) socNetFBLoggedOut;

/* MNOfflinePackDelegate methods */
-(void) mnOfflinePackStartPageReadyAtUrl:(NSString*) url;
-(void) mnOfflinePackIsUnavailableBecauseOfError:(NSString*) error;

/* internal/private methods */
-(void) notifyLoginFailed:(NSString*) error;
-(void) notifyDevUsersInfoChanged;
-(void) notifyErrorOccurred:(NSInteger) actionCode withMessage:(NSString*) errorMessage;
-(void) setNewStatus:(NSUInteger) newStatus;
-(void) startGameWithParamsFromActiveRoom;

-(void) sendMultiNetXtMessage:(NSString*) cmd withParams:(NSDictionary*) params;

-(BOOL) isInGameRoom;

-(void) logoutFromSocNets;

-(id) getUserVariable:(NSString*) name;
-(BOOL) getUserVariable:(NSString*) name asInteger:(NSInteger*) value;
-(BOOL) getRoomUserStatusVariable:(NSInteger*) userStatus;

/* application state change notifications */
-(void) appWillResignActive: (NSNotification*) notification;
-(void) appDidBecomeActive: (NSNotification*) notification;
-(void) appWillTerminate: (NSNotification*) notification;
#ifdef __IPHONE_4_0
-(void) appDidEnterBackground: (NSNotification*) notification;
-(void) appWillEnterForeground: (NSNotification*) notification;
#endif

-(void) fallASleep;
-(void) wakeUp;

-(NSString*) stringWithVarStorageFileName;
-(void) varStorageSave;

@end

static NSString* MNStringReplaceBarWithSpace (NSString* str) {
    return [str stringByReplacingOccurrencesOfString: @"|" withString: @" "];
}

static NSString* MNStringReplaceCommaWithDash (NSString* str) {
    return [str stringByReplacingOccurrencesOfString: @"," withString: @"-"];
}

static NSString* MNGetStructuredDeviceInfoString (void) {
    UIDevice* device;
    NSTimeZone* timeZone;

    device = [UIDevice currentDevice];
    timeZone = [NSTimeZone localTimeZone];

    return [NSString stringWithFormat: @"%@|%@|%@|%@|{%d+%@+%@}",
                                       MNStringReplaceBarWithSpace([device model]),
                                       MNStringReplaceBarWithSpace([device systemName]),
                                       MNStringReplaceBarWithSpace([device systemVersion]),
                                       MNStringReplaceBarWithSpace([[NSLocale currentLocale] localeIdentifier]),
                                       [timeZone secondsFromGMT],
                                       MNStringReplaceBarWithSpace([timeZone abbreviation]),
                                       MNStringReplaceBarWithSpace([timeZone name])];
}

static NSString* MNStructuredPasswordStringFromParams (NSString* launchId, NSString* loginModel, NSString* gameSecret, NSString* passwordHash, BOOL userDevSetHome) {
    NSString* appVersionInternal = MNGetAppVersionInternal();
    NSString* appVersionExternal = MNGetAppVersionExternal();

    if (appVersionInternal == nil) {
        appVersionInternal = @"";
    }

    if (appVersionExternal == nil) {
        appVersionExternal = @"";
    }

    NSString* appInfo = [NSString stringWithFormat: @"%@|%@|%@",
                         launchId,
                         MNStringReplaceBarWithSpace(appVersionInternal),
                         MNStringReplaceBarWithSpace(appVersionExternal)];

    return [NSString stringWithFormat: @"%@,%@,%@,%@,%d,%@,%@,%@,%@",
                                       MNClientAPIVersion,loginModel,passwordHash,gameSecret,MNDeviceTypeiPhoneiPod,
                                       MNGetDeviceIdMD5(),userDevSetHome ? @"1" : @"0",
                                       MNStringReplaceCommaWithDash(MNGetStructuredDeviceInfoString()),
                                       MNStringReplaceCommaWithDash(appInfo)];
}

static NSString* MNSessionGetNewGuestPassword () {
    struct timeval currentTime;

    gettimeofday(&currentTime,NULL);

    NSString* plainPass = [NSString stringWithFormat: @"%@%ld%ld%u%u",
                           [[UIDevice currentDevice] uniqueIdentifier],
                           (long)currentTime.tv_sec,
                           (long)currentTime.tv_usec,
                           (unsigned int)arc4random(),
                           (unsigned int)arc4random()];

    return MNStringGetMD5String(plainPass);
}

static NSString* MNSessionCalcLaunchId () {
    struct timeval currentTime;

    gettimeofday(&currentTime,NULL);

    NSString* launchId = [NSString stringWithFormat: @"%@:%lld:%ld%ld:%u",
                          [[UIDevice currentDevice] uniqueIdentifier],
                          (long long)time(NULL),
                          (long)currentTime.tv_sec,
                          (long)currentTime.tv_usec,
                          (unsigned int)arc4random()];

    return MNStringGetMD5String(launchId);
}

static NSInteger MNDeviceOSVersionGetMajor (void) {
    NSInteger majorVersion;
    NSString* versionString   = [[UIDevice currentDevice] systemVersion];
    NSRange   majorPointRange = [versionString rangeOfString: @"."];

    if (majorPointRange.location != NSNotFound) {
        versionString = [versionString substringToIndex: majorPointRange.location];
    }

    if (!MNStringScanInteger(&majorVersion,versionString)) {
        majorVersion = 0;
    }

    return majorVersion;
}

static BOOL MNDeviceOSVersionIs4OrHigher (void) {
    return MNDeviceOSVersionGetMajor() >= 4;
}


@implementation MNSession

@synthesize smartFoxDelegate;
@synthesize autoReconnectOnWakeEnabled = _autoReconnectOnWakeEnabled;
@synthesize disconnectOnSleepDelay = _disconnectOnSleepDelay;

-(id) initWithGameId:(NSInteger) gameId andGameSecret:(NSString*) gameSecret {
    self = [super init];

    if (self != nil) {
        _delegates = [[MNDelegateArray alloc] init];
        _gameId = gameId;
        _gameSecret = [gameSecret copy];
        _status = MN_OFFLINE;
        _defaultGameSetId = 0;
        _pendingGameResult = nil;

        NSURLRequest* configRequest = nil;
        NSString*     configUrl     = MNGetMultiNetConfigURL();

        if (configUrl != nil) {
            NSDictionary* configRequestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSString stringWithFormat: @"%d",gameId],
                                                 @"game_id",
                                                 [NSString stringWithFormat: @"%d",MNDeviceTypeiPhoneiPod],
                                                 @"dev_type",
                                                 MNClientAPIVersion,
                                                 @"client_ver",
                                                 [[NSLocale currentLocale] localeIdentifier],
                                                 @"client_locale",
                                                 nil];

            configRequest = MNGetURLRequestWithPostMethod([NSURL URLWithString: configUrl],configRequestParams);
        }

        smartFoxFacade = [[MNSmartFoxFacade alloc] initWithConfigRequest: configRequest];
        smartFoxFacade.delegate = self;
        smartFoxFacade.smartFoxDelegate = self;

        _lobbyRoomIdIsSet = NO;
        _lobbyRoomId = MNLobbyRoomIdUndefined;
        
        _roomExtraInfoReceived = NO;

        socNetSessionFB = [[MNSocNetSessionFB alloc] initWithDelegate: self];

        _offlinePack = [[MNOfflinePack alloc] initOfflinePackWithGameId: gameId andDelegate: self];

//        pingTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector: @selector(pingTimerFired:) userInfo: nil repeats: YES];

        reloginRequired = NO;
        _autoReconnectOnWakeEnabled = YES;
        _disconnectOnSleepDelay = MNSessionFallASleepDelay;

        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appWillResignActive:) name: UIApplicationWillResignActiveNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appDidBecomeActive:) name: UIApplicationDidBecomeActiveNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appWillTerminate:) name: UIApplicationWillTerminateNotification object: nil];

#ifdef __IPHONE_4_0
        if (MNDeviceOSVersionIs4OrHigher()) {
            [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appDidEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appWillEnterForeground:) name: UIApplicationWillEnterForegroundNotification object: nil];
        }
#endif

        varStorage = [[MNVarStorage alloc] initWithContentsOfFile: [self stringWithVarStorageFileName]];

        _webBaseUrl = nil;

        _handledURL = nil;
        _trackingSystem = nil;

        _launchTime = time(NULL);
        _launchId   = [MNSessionCalcLaunchId() retain];
        _shutdownTracked = NO;

        _inForeground              = YES;
        _foregroundSwitchCount     = 1;
        _foregroundLastStartTime   = _launchTime;
        _foregroundAccumulatedTime = 0;

        _gameVocabulary = [[MNGameVocabulary alloc] initWithSession: self];
    }

    return self;
}
/*
-(void) pingTimerFired: (NSTimer*) theTimer {
    if (smartFoxFacade.smartFox.isConnected) {
        [self sendMultiNetXtMessage: @"pingNoReply" withParams: [NSDictionary dictionaryWithObjectsAndKeys: nil]];
    }
}
*/
-(void) logoutFromSocNets {
    [socNetSessionFB logout];
}

-(void) dealloc {
    smartFoxFacade.delegate         = nil;
    smartFoxFacade.smartFoxDelegate = nil;

    [_gameVocabulary release];

    if (!_shutdownTracked) {
        [[self getTrackingSystem] trackShutdownForSession: self];
        _shutdownTracked = YES;
    }

    [_handledURL release];
/*
    [pingTimer invalidate];
*/
    [_webBaseUrl release];

    [_offlinePack release];
    [self varStorageSave];
    [varStorage release];

    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(fallASleep) object: nil];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(wakeUp) object: nil];

    [[NSNotificationCenter defaultCenter] removeObserver: self];
//    [self logoutFromSocNets];
    [_pendingGameResult release];
    [socNetSessionFB release];
    [_userName release];
    [_userSId release];
    [smartFoxFacade release];
    [_delegates release];
    [_gameSecret release];
    [_launchId release];
    [_trackingSystem release];

    [super dealloc];
}

-(void) handleGoForegroundEvent {
    if (_inForeground) {
        return;
    }

    _inForeground            = YES;
    _foregroundLastStartTime = time(NULL);
    _foregroundSwitchCount++;

    [[self getTrackingSystem] trackEnterForegroundForSession: self];
}

-(void) handleGoBackgroundEvent {
    if (!_inForeground) {
        return;
    }

    _inForeground               = NO;
    _foregroundAccumulatedTime += time(NULL) - _foregroundLastStartTime;

    [[self getTrackingSystem] trackEnterBackgroundForSession: self];
}

-(void) appWillResignActive: (NSNotification*) notification {
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(wakeUp) object: nil];

    if (!reloginRequired) {
        [self performSelector: @selector(fallASleep) withObject: nil afterDelay: _disconnectOnSleepDelay];
    }

    [self handleGoBackgroundEvent];
}

-(void) appDidBecomeActive: (NSNotification*) notification {
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(fallASleep) object: nil];

    [self handleGoForegroundEvent];

    [self wakeUp];
}

#ifdef __IPHONE_4_0
-(void) appDidEnterBackground: (NSNotification*) notification {
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(fallASleep) object: nil];

    [self varStorageSave];
    [self handleGoBackgroundEvent];

    [self fallASleep];
}

-(void) appWillEnterForeground: (NSNotification*) notification {
    [self handleGoForegroundEvent];
}
#endif

-(void) appWillTerminate: (NSNotification*) notification {
    if (!_shutdownTracked) {
        [[self getTrackingSystem] trackShutdownForSession: self];
        _shutdownTracked = YES;
    }

    [self varStorageSave];
}

-(void) fallASleep {
    if (_status != MN_OFFLINE) {
        [self logout];

        reloginRequired = _autoReconnectOnWakeEnabled;
    }
}

-(void) wakeUp {
    if (_status == MN_OFFLINE && reloginRequired) {
        [self setNewStatus: MN_CONNECTING];

        reloginRequired = NO;
        [smartFoxFacade restoreConnection];
    }
}

-(void) addDelegate:(id<MNSessionDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNSessionDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

-(INFSmartFoxiPhoneClient*) getSmartFox {
    return smartFoxFacade.smartFox;
}

-(BOOL) autoReconnectOnNetErrorsEnabled {
    return smartFoxFacade.reconnectOnNetErrors;
}

-(void) setAutoReconnectOnNetErrorsEnabled:(BOOL)newValue {
    smartFoxFacade.reconnectOnNetErrors = newValue;
}

-(BOOL) loginWithLogin:(NSString*) userLogin andStructuredPassword:(NSString*) structuredPassword {
    if (_status != MN_OFFLINE) {
        if (MNSessionOfflineModeDisabled) {
            [self logout];
        }
        else {
            [smartFoxFacade logout];
        }
    }

    reloginRequired = NO;

    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(fallASleep) object: nil];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(wakeUp) object: nil];

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionLoginInitiated)]) {
            [delegate mnSessionLoginInitiated];
        }
    }

    [_delegates endCall];

    NSString* configURL = MNGetMultiNetConfigURL();

    if (configURL != nil) {
        NSString* zone = [[NSString alloc] initWithFormat: MNGameZoneNameFormat, _gameId];

        [self setNewStatus: MN_CONNECTING];

        [smartFoxFacade loginAs: userLogin withPassword: structuredPassword toZone: zone];

        [zone release];

        return YES;
    }
    else {
        [self performSelector: @selector(notifyLoginFailed:) withObject: MNLocalizedString(@"MultiNet configuration file loading failed - application is not configured properly",MNMessageCodeMultiNetConfigFileBrokenError) afterDelay: 0];

        return NO;
    }
}

-(BOOL) loginSynchronousWithUserLogin:(NSString*) userLogin password:(NSString*) userPassword saveCredentials:(BOOL) saveCredentials {
    synchronousCallCompleted = NO;

    if ([self loginWithUserLogin: userLogin password: userPassword saveCredentials: saveCredentials]) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        BOOL done = NO;

        while (!done) {
            if (![runLoop runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]]) {
                done = YES;
            }
            else if (synchronousCallCompleted) {
                done = YES;
            }
        }

        return _status != MN_OFFLINE;
    }
    else {
        return NO;
    }
}

-(BOOL) loginWithUserLogin:(NSString*) userLogin password:(NSString*) userPassword saveCredentials:(BOOL) saveCredentials {
    return [self loginWithLogin: userLogin
                 andStructuredPassword:  MNStructuredPasswordStringFromParams
                                          (_launchId,MNLoginModelLoginPlusPasswordString,_gameSecret,MNStringGetMD5String(userPassword),saveCredentials)];
}

-(BOOL) loginWithUserId:(MNUserId) userId passwordHash:(NSString*) userPasswordHash saveCredentials:(BOOL) saveCredentials {
    return [self loginWithLogin: [NSString stringWithFormat: @"%lld", userId]
                 andStructuredPassword:  MNStructuredPasswordStringFromParams
                                          (_launchId,MNLoginModelIdPlusPasswordHashString,_gameSecret,userPasswordHash,saveCredentials)];
}

-(BOOL) loginWithDeviceCredentials {
    return [self loginWithLogin: MNLoginModelGuestUserLogin
                 andStructuredPassword:  MNStructuredPasswordStringFromParams(_launchId,MNLoginModelGuestString,_gameSecret,MNSessionGetNewGuestPassword(),YES)];
}

-(BOOL) loginWithUserId:(MNUserId) userId authSign:(NSString*) authSign {
    return [self loginWithLogin: [NSString stringWithFormat: @"%lld", userId]
                 andStructuredPassword:  MNStructuredPasswordStringFromParams(_launchId,MNLoginModelAuthSignString,_gameSecret,authSign,YES)];
}

-(void) registerLoginOfflineWithUserId:(MNUserId) userId userName:(NSString*) userName andAuthSign:(NSString*) authSign {
    _userId = userId;

    [_userName release]; _userName = [userName retain];
    [_userSId release]; _userSId = nil;

    _lobbyRoomIdIsSet = NO;
    _lobbyRoomId = MNLobbyRoomIdUndefined;

    MNUserCredentialsUpdateUser(varStorage,userId,userName,authSign,[NSDate date],nil);
    [self varStorageSave];

    [self notifyDevUsersInfoChanged];

    [_delegates beginCall];
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionUserChangedTo:)]) {
            [delegate mnSessionUserChangedTo: userId];
        }
    }
    [_delegates endCall];
}

-(BOOL) loginOfflineWithUserId:(MNUserId) userId authSign:(NSString*) authSign {
    if (_status != MN_OFFLINE) {
        [self performSelector: @selector(notifyLoginFailed:) withObject: MNLocalizedString(@"Cannot login offline while connected to server",MNMessageCodeOfflineCannotLoginOfflineWhileConnectedToServerError) afterDelay: 0];

        return NO;
    }
		
    MNUserCredentials* credentials = MNUserCredentialsGetByUserId(varStorage,userId);

    if (![credentials.userAuthSign isEqualToString: authSign]) {
        [self performSelector: @selector(notifyLoginFailed:) withObject: MNLocalizedString(@"Invalid login or password",MNMessageCodeOfflineInvalidAuthSignError) afterDelay: 0];

        return NO;
    }

    [self registerLoginOfflineWithUserId: userId userName: credentials.userName andAuthSign: authSign];

    return YES;
}

-(BOOL) signupOffline {
    if (_status != MN_OFFLINE) {
        [self performSelector: @selector(notifyLoginFailed:) withObject: MNLocalizedString(@"Cannot login offline while connected to server",MNMessageCodeOfflineCannotLoginOfflineWhileConnectedToServerError) afterDelay: 0];
        return NO;
    }

    time_t currentTime = time(NULL);

    if (currentTime == (time_t)-1) {
        currentTime = INT_MAX;
    }

    MNUserId userId = -currentTime;

    MNUserCredentials* userCredentials = MNUserCredentialsGetByUserId(varStorage,userId);

    while (userCredentials != nil) {
        userId++;
        userCredentials = MNUserCredentialsGetByUserId(varStorage,userId);
    }

    [self registerLoginOfflineWithUserId: userId
                                userName: [NSString stringWithFormat: @"Guest_%lld",(long long)currentTime]
                             andAuthSign: [NSString stringWithFormat: @"TMP_%lld%lld",(long long)currentTime,(long long)userId]];

    return YES;
}

-(BOOL) loginAuto {
    MNUserCredentials* lastUserCredentials = MNUserCredentialsGetMostRecentlyLoggedUserCredentials(varStorage);

    if (lastUserCredentials != nil) {
        return [self loginWithUserId: lastUserCredentials.userId authSign: lastUserCredentials.userAuthSign];
    }
    else {
        return [self loginWithDeviceCredentials];
    }
}

-(void) logout {
    [self logoutAndWipeUserCredentialsByMode: MN_CREDENTIALS_WIPE_NONE];
}

-(void) logoutAndWipeUserCredentialsByMode:(NSInteger) wipeMode {
    if      (wipeMode == MN_CREDENTIALS_WIPE_ALL) {
        MNUserCredentialsWipeAll(varStorage);

        [varStorage removeVariablesByMask: MNPersistentVarUserAllUsersMask];
    }
    else if (wipeMode == MN_CREDENTIALS_WIPE_USER) {
        if ([self isUserLoggedIn]) {
            MNUserCredentialsWipeByUserId(varStorage,_userId);

            [varStorage removeVariablesByMask: [NSString stringWithFormat: MNPersistentVarUserSingleUserMaskFormat, _userId]];
        }
    }

    [self notifyDevUsersInfoChanged];

    if (wipeMode != MN_CREDENTIALS_WIPE_NONE) {
        if ([socNetSessionFB isConnected]) {
            [socNetSessionFB logout];
        }
    }

    reloginRequired = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(fallASleep) object: nil];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(wakeUp) object: nil];

    [_userSId release]; _userSId = nil;

    _lobbyRoomIdIsSet = NO;
    _lobbyRoomId = MNLobbyRoomIdUndefined;

    if (_status != MN_OFFLINE) {
        [smartFoxFacade logout];
        [self setNewStatus: MN_OFFLINE];
    }

    if (_userId != MNUserIdUndefined) {
        _userId = MNUserIdUndefined;
        [_userName release]; _userName = nil;

        [_delegates beginCall];
        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionUserChangedTo:)]) {
                [delegate mnSessionUserChangedTo: _userId];
            }
        }
        [_delegates endCall];
    }
}

-(BOOL) isReLoginPossible {
    return [smartFoxFacade haveLoginInfo];
}

-(void) reLogin {
    reloginRequired = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(fallASleep) object: nil];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(wakeUp) object: nil];

    if ([self isReLoginPossible]) {
        [smartFoxFacade relogin];
    }
}

-(BOOL) isOnline {
    return _status != MN_OFFLINE && _status != MN_CONNECTING;
}

-(BOOL) isUserLoggedIn {
    return _userId != MNUserIdUndefined;
}

-(NSInteger) getGameId {
    return _gameId;
}

-(NSInteger) getStatus {
    return _status;
}

-(BOOL) isInGameRoom {
    return _status == MN_IN_GAME_WAIT || _status == MN_IN_GAME_START ||
           _status == MN_IN_GAME_PLAY || _status == MN_IN_GAME_END;
}

-(NSString*) getMyUserName {
    if ([self isUserLoggedIn]) {
        return _userName;
    }
    else {
        return nil;
    }
}

/*
//*TODO:*
-(NSString*) getMyHiScore {
    return nil;
}

//*TODO:*
-(NSString*) getMyAvatarUrl {
    return nil;
}
*/

-(MNUserId) getMyUserId {
    if ([self isUserLoggedIn]) {
        return _userId;
    }
    else {
        return MNUserIdUndefined;
    }
}

-(NSInteger) getMyUserSFId {
    if ([smartFoxFacade isLoggedIn]) {
        return smartFoxFacade.smartFox.myUserId;
    }
    else {
        return MNSmartFoxUserIdUndefined;
    }
}

-(NSString*) getMySId {
    if (_status != MN_OFFLINE) {
        return _userSId;
    }
    else {
        return nil;
    }
}

-(MNUserInfo*) getMyUserInfo {
    if ([self isUserLoggedIn]) {
        return [[[MNUserInfo alloc] initWithUserId: _userId userSFId: [self getMyUserSFId] userName: _userName webBaseUrl: _webBaseUrl] autorelease];
    }
    else {
        return nil;
    }
}

-(NSInteger) getCurrentRoomId {
    if ([smartFoxFacade isLoggedIn]) {
        return smartFoxFacade.smartFox.activeRoomId;
    }
    else {
        return MNSmartFoxRoomIdUndefined;
    }
}

-(NSArray*) getRoomUserList {
    NSMutableArray *userList = nil;

    if ([self isOnline]) {
        INFSmartFoxRoom *room = [smartFoxFacade.smartFox getRoom: [smartFoxFacade.smartFox activeRoomId]];
        NSMutableDictionary *userDict = [room getUserList];
        userList = [[[NSMutableArray alloc] initWithCapacity: [userDict count]] autorelease];

        for (id userSFId in userDict) {
            INFSmartFoxUser* user = [userDict objectForKey: userSFId];

            NSString* structuredName = [user getName];
            NSString* plainUserName;
            MNUserId  userId;

            if (!MNParseMNUserNameToComponents(&userId,&plainUserName,structuredName)) {
                plainUserName = structuredName;
                userId        = MNUserIdUndefined;
            }

            [userList addObject: [[[MNUserInfo alloc] initWithUserId: userId userSFId: [user getId] userName: plainUserName webBaseUrl: _webBaseUrl] autorelease]];
        }
    }
    else {
        NSLog(@"warning: getRoomUserList called while user is not logged in");

        userList = [[[NSMutableArray alloc] initWithCapacity: 0] autorelease];
    }

    return userList;
}

-(MNUserInfo*) getUserInfoBySFId:(NSInteger) sfId {
    if (![self isOnline]) {
        return nil;
    }

    INFSmartFoxRoom *room = [smartFoxFacade.smartFox getRoom: [smartFoxFacade.smartFox activeRoomId]];
    INFSmartFoxUser* user = [room getUser: [NSNumber numberWithInteger: sfId]];

    if (user == nil) {
        return nil;
    }

    NSString* plainUserName;
    MNUserId  userId;

    if (!MNParseMNUserNameToComponents(&userId,&plainUserName,[user getName])) {
        return nil;
    }

    return [[[MNUserInfo alloc] initWithUserId: userId userSFId: sfId userName: plainUserName webBaseUrl: _webBaseUrl] autorelease];
}

-(void) sendAppBeacon:(NSString*) actionName beaconData:(NSString*) beaconData {
    [[self getTrackingSystem] sendBeacon: actionName data: beaconData andSession: self];
}

-(void) sendPrivateMessage:(NSString*) message to: (NSInteger) userSFId {
    if ([self isOnline]) {
        [smartFoxFacade.smartFox sendPrivateMessage: message recipientId: userSFId roomId: smartFoxFacade.smartFox.activeRoomId];
    }
}

-(void) sendChatMessage:(NSString*) message {
    if ([self isOnline]) {
        [smartFoxFacade.smartFox sendPublicMessage: message roomId: smartFoxFacade.smartFox.activeRoomId];
    }
}

-(void) sendMultiNetXtMessage:(NSString*) cmd withParams:(NSDictionary*) params {
    [smartFoxFacade.smartFox sendXtMessage: MNMultiNetSmartFoxExtName
                             cmd: cmd
                             paramObj: params
                             type: smartFoxFacade.smartFox.INFSMARTFOXCLIENT_XTMSG_TYPE_XML
                             roomId: smartFoxFacade.smartFox.activeRoomId];
}

-(void) sendGameMessage:(NSString*) message {
    if ([self isInGameRoom]) {
        /* FIXME: current version of SmartFox "eats" first character of message in "RAW" mode, so we prepend */
        /* '~' character to prevent first character of game message to be "eaten"                          */
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSString stringWithFormat: @"~%@~%@",MNSmartFoxExtCmdSendGameMessageRawPrefix,MNStringEscapeSimple(message,smartFoxFacade.smartFox.rawProtocolSeparator,MNGameMessageEscapeStr)],
                                MNSmartFoxExtCmdSendGameMessageParamMessage,
                                nil];

        [smartFoxFacade.smartFox sendXtMessage: MNMultiNetSmartFoxExtName
                                 cmd: MNSmartFoxExtCmdSendGameMessage
                                 paramObj: params
                                 type: smartFoxFacade.smartFox.INFSMARTFOXCLIENT_XTMSG_TYPE_STR
                                 roomId: smartFoxFacade.smartFox.activeRoomId];

        [params release];
    }
}

-(void) sendPlugin:(NSString*) pluginName message:(NSString*) message {
    if ([self isOnline]) {
        NSString* escapedPluginName =
         MNStringEscapeCharSimple(MNStringEscapeSimple
                                   (pluginName,
                                    smartFoxFacade.smartFox.rawProtocolSeparator,
                                    MNGameMessageEscapeStr),
                                  MNPluginMessagePluginNameTermStr,
                                  MNGameMessageEscapeStr);

        NSString* escapedMessage =
         MNStringEscapeCharSimple(MNStringEscapeSimple
                                   (message,
                                    smartFoxFacade.smartFox.rawProtocolSeparator,
                                    MNGameMessageEscapeStr),
                                  MNPluginMessagePluginNameTermStr,
                                  MNGameMessageEscapeStr);

        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSString stringWithFormat: @"~%@~%@%@%@",
                                  MNSmartFoxExtCmdSendPluginMessageRawPrefix,
                                  escapedPluginName,
                                  MNPluginMessagePluginNameTermStr,
                                  escapedMessage],
                                MNSmartFoxExtCmdSendPluginMessageParamMessage,
                                nil];

        [smartFoxFacade.smartFox sendXtMessage: MNMultiNetSmartFoxExtName
                                 cmd: MNSmartFoxExtCmdSendPluginMessage
                                 paramObj: params
                                 type: smartFoxFacade.smartFox.INFSMARTFOXCLIENT_XTMSG_TYPE_STR
                                 roomId: smartFoxFacade.smartFox.activeRoomId];

        [params release];
    }
}

-(void) reqJoinBuddyRoom:(NSInteger) roomSFId {
    if ([self isOnline]) {
        NSString* roomSFIdParam = MNStringCreateFromInteger(roomSFId);
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys: roomSFIdParam, MNSmartFoxExtCmdJoinBuddyRoomParamRoomSFId, nil];

        [roomSFIdParam release];

        [self sendMultiNetXtMessage: MNSmartFoxExtCmdJoinBuddyRoom withParams: params];

        [params release];
    }
}

-(void) sendJoinRoomInvitationResponse:(MNJoinRoomInvitationParams*) invitationParams accept:(BOOL) accept {
    if ([self isOnline]) {
        if (accept) {
            [self reqJoinBuddyRoom: invitationParams.roomSFId];
        }
        else {
            [self sendPrivateMessage: [NSString stringWithFormat: @"\tInvite reject for room:%d",invitationParams.roomSFId]
                                                              to: invitationParams.fromUserSFId];
        }
    }
}

-(void) reqJoinRandomRoom:(NSString*) gameSetId {
    if ([self isOnline]) {
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys: gameSetId, MNSmartFoxExtCmdParamGameSetId, nil];

        [self sendMultiNetXtMessage: MNSmartFoxExtCmdJoinRandomRoom withParams: params];

        [params release];
    }
}

-(void) reqCreateBuddyRoom:(MNBuddyRoomParams*) buddyRoomParams {
    if ([self isOnline]) {
        NSString* gameSetIdParam = MNStringCreateFromInteger(buddyRoomParams.gameSetId);
        NSString* inviteText = buddyRoomParams.inviteText;

        /*FIXME: smartFox SDK beta2 have a bug with sending/receiving empty strings */
        /* sometimes it sends a value which is parsed as nil and cause an error to be raised inside */
        /* smartFox object deserialization code (it tries to insert nil into NSDictionary). */
        /* So we use single space instead of empty invite message */

        if ([inviteText length] == 0) {
            inviteText = @" ";
        }

        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 buddyRoomParams.roomName, MNSmartFoxExtCmdCreateBuddyRoomParamRoomName,
                                 gameSetIdParam, MNSmartFoxExtCmdParamGameSetId,
                                 buddyRoomParams.toUserIdList, MNSmartFoxExtCmdCreateBuddyRoomParamToUserIdList,
                                 buddyRoomParams.toUserSFIdList, MNSmartFoxExtCmdCreateBuddyRoomParamToUserSFIdList,
                                 inviteText, MNSmartFoxExtCmdCreateBuddyRoomParamMessText,
                                 nil];

        [gameSetIdParam release];

        [self sendMultiNetXtMessage: MNSmartFoxExtCmdCreateBuddyRoom withParams: params];

        [params release];
    }
}

-(void) reqStartBuddyRoomGame {
    if (_status == MN_IN_GAME_WAIT) {
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys: nil];

        [self sendMultiNetXtMessage: MNSmartFoxExtCmdStartBuddyRoomGame withParams: params];

        [params release];
    }
    else {
        NSString* errorMessage = MNLocalizedString(@"Room not ready",MNMessageCodeRoomIsNotReadyToStartAGameError);

        [self notifyErrorOccurred: MNErrorInfoActionCodeStartBuddyRoomGame withMessage: errorMessage];
    }
}

-(void) reqStopRoomGame {
    if (_status == MN_IN_GAME_PLAY) {
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys: nil];

        [self sendMultiNetXtMessage: MNSmartFoxExtCmdStopRoomGame withParams: params];

        [params release];
    }
}

-(void) reqCurrentGameResults {
    if ([self isInGameRoom]) {
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys: nil];

        [self sendMultiNetXtMessage: MNSmartFoxExtCmdCurrGameResults withParams: params];

        [params release];
    }
}

-(void) reqSetUserStatus:(NSInteger) userStatus {
    if ([self isInGameRoom]) {
        if (userStatus == MN_USER_PLAYER || userStatus == MN_USER_CHATER) {
            NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSString stringWithFormat: @"%d", userStatus], MNSmartFoxExtCmdSetUserStatusParamUserStatus,
                                    nil];

            [self sendMultiNetXtMessage: MNSmartFoxExtCmdSetUserStatus withParams: params];

            [params release];
        }
        else {
            NSString* errorMessage = MNLocalizedString(@"invalid player status value",MNMessageCodeInvalidPlayerStatusValueError);

            [self notifyErrorOccurred: MNErrorInfoActionCodeSetUserStatus withMessage: errorMessage];
        }
    }
}

-(void) startGameWithParams:(MNGameParams*) gameParams {
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionDoStartGameWithParams:)]) {
            [delegate mnSessionDoStartGameWithParams: gameParams];
        }
    }

    [_delegates endCall];
}

-(void) finishGameWithResult:(MNGameResult*) gameResult {
    if (_status == MN_OFFLINE || _status == MN_CONNECTING) {
        if (_userId != MNUserIdUndefined) {
            MNOfflineScoreSaveScore(varStorage,_userId,gameResult.gameSetId,gameResult.score);
            [self varStorageSave];
        }
    }
    else {
        BOOL inRoom = NO;

        if (_status == MN_IN_GAME_PLAY || _status == MN_IN_GAME_END) {
            if (_userStatusValid && _userStatus == MN_USER_PLAYER) {
                inRoom = YES;
            }
        }

        if (inRoom) {
            NSString* score = MNStringCreateFromLongLong(gameResult.score);

            NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    score, MNSmartFoxExtCmdFinishParamScore,
                                    @"-1", MNSmartFoxExtCmdFinishParamOutTime,
                                    nil];

            [score release];

            [self sendMultiNetXtMessage: MNSmartFoxExtCmdFinishGameInRoom withParams: params];

            [params release];
        }
        else {
            NSString* score = MNStringCreateFromLongLong(gameResult.score);
            NSString* gameSetId = MNStringCreateFromInteger(gameResult.gameSetId);

            id scorePostLinkId;

            if (gameResult.scorePostLinkId == nil) {
                scorePostLinkId = [NSNull null];
            }
            else {
                scorePostLinkId = gameResult.scorePostLinkId;
            }

            NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    score, MNSmartFoxExtCmdFinishParamScore,
                                    @"-1", MNSmartFoxExtCmdFinishParamOutTime,
                                    scorePostLinkId, MNSmartFoxExtCmdFinishParamScorePostLinkId,
                                    gameSetId, MNSmartFoxExtCmdParamGameSetId,
                                    nil];

            [gameSetId release];
            [score release];

            [self sendMultiNetXtMessage: MNSmartFoxExtCmdFinishGamePlain withParams: params];

            [params release];
        }
    }

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionGameFinishedWithResult:)]) {
            [delegate mnSessionGameFinishedWithResult: gameResult];
        }
    }

    [_delegates endCall];
}

-(void) leaveRoom {
    if ([self isInGameRoom]) {
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys: nil];

        [self sendMultiNetXtMessage: MNSmartFoxExtCmdLeaveRoom withParams: params];

        [params release];
    }
}

-(void) execAppCommand:(NSString*) name withParam:(NSString*) param {
	if ([name hasPrefix: MNAppCommandSetAppPropertyPrefix]) {
		NSString* varName = [[NSString alloc] initWithFormat: MNAppPropertyVarPathFormat,
							 [name substringFromIndex: [MNAppCommandSetAppPropertyPrefix length]]];

		if (param != nil) {
			[varStorage setValue: param forVariable: varName];
		}
		else {
			[varStorage removeVariablesByMask: varName];
		}

		[varName release];
        [self varStorageSave];
	}

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionExecAppCommandReceived:withParam:)]) {
            [delegate mnSessionExecAppCommandReceived: name withParam: param];
        }
    }

    [_delegates endCall];
}

-(void) execUICommand:(NSString*) name withParam:(NSString*) param {
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionExecUICommandReceived:withParam:)]) {
            [delegate mnSessionExecUICommandReceived: name withParam: param];
        }
    }

    [_delegates endCall];
}

-(void) processWebEvent:(NSString*) name withParam:(NSString*) param andCallbackId:(NSString*) callbackId {
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionWebEventReceived:withParam:andCallbackId:)]) {
            [delegate mnSessionWebEventReceived: name withParam: param andCallbackId: callbackId];
        }
    }

    [_delegates endCall];
}

-(void) postSysEvent:(NSString*) name withParam:(NSString*) param andCallbackId:(NSString*) callbackId {
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionSysEventReceived:withParam:andCallbackId:)]) {
            [delegate mnSessionSysEventReceived: name withParam: param andCallbackId: callbackId];
        }
    }

    [_delegates endCall];
}

-(BOOL) preprocessAppHostCall:(MNAppHostCallInfo*) appHostCallInfo {
    BOOL      result  = NO;
    NSString* cmdName = appHostCallInfo.commandName;

    // exclude some low-level commands
    if ([cmdName isEqualToString: MNAppHostCallCommandVarSave]         ||
        [cmdName isEqualToString: MNAppHostCallCommandVarsClear]       ||
        [cmdName isEqualToString: MNAppHostCallCommandVarsGet]         ||
        [cmdName isEqualToString: MNAppHostCallCommandSetHostParam]    ||
        [cmdName isEqualToString: MNAppHostCallCommandSendHttpRequest] ||
        [cmdName isEqualToString: MNAppHostCallCommandAddSourceDomain] ||
        [cmdName isEqualToString: MNAppHostCallCommandRemoveSourceDomain]) {
        return NO;
    }

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionAppHostCallReceived:)]) {
            result = result || [delegate mnSessionAppHostCallReceived: appHostCallInfo];
        }
    }

    [_delegates endCall];

    return result;
}

-(BOOL) handleOpenURL:(NSURL*) url {
    if (MNLauncherIsLauncherURL(url,_gameId)) {
        [_handledURL release]; _handledURL = [url retain];

        [_delegates beginCall];

        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionHandleOpenURL:)]) {
                [delegate mnSessionHandleOpenURL: url];
            }
        }

        [_delegates endCall];

        return YES;
    }
    else {
        return [socNetSessionFB handleOpenURL: url];
    }
}

-(NSURL*) getHandledURL {
    return _handledURL;
}

-(id) getUserVariable:(NSString*) name {
    INFSmartFoxUser* myUserInfo = [[smartFoxFacade.smartFox getActiveRoom] getUser: [NSNumber numberWithInteger: smartFoxFacade.smartFox.myUserId]];

    return [myUserInfo getVariable: name];
}

-(BOOL) getUserVariable:(NSString*) name asInteger:(NSInteger*) value {
    id varValue = [self getUserVariable: name];

    if ([varValue isKindOfClass: [NSNumber class]]) {
        *value = [(NSNumber*)varValue integerValue];

        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL) getRoomUserStatusVariable:(NSInteger*) userStatus {
    return [self getUserVariable: MNGameUserVarNameUserStatus asInteger: userStatus];
}

-(NSInteger) getRoomUserStatus {
    if ([self isOnline] && _userStatusValid) {
        return _userStatus;
    }
    else {
        return MN_USER_STATUS_UNDEFINED;
    }
}

-(NSInteger) getRoomGameSetId {
    NSInteger gameSetId = 0;

    if ([self isInGameRoom]) {
        INFSmartFoxRoom* activeRoom = [smartFoxFacade.smartFox getActiveRoom];

        id gameSetIdVar = [activeRoom getVariable: MNGameRoomVarNameGameSetId];

        if ([gameSetIdVar isKindOfClass: [NSNumber class]]) {
            gameSetId = [(NSNumber*)gameSetIdVar integerValue];
        }
    }

    return gameSetId;
}

-(void) schedulePostScoreOnLogin:(MNGameResult*) gameResult {
    [_pendingGameResult release];

    _pendingGameResult = [gameResult retain];
}

-(void) cancelPostScoreOnLogin {
    [_pendingGameResult release];

    _pendingGameResult = nil;
}

-(void) cancelGameWithParams:(MNGameParams*) gameParams {
    NSInteger userStatus;

    if ([self isInGameRoom] && [self getRoomUserStatusVariable: &userStatus]) {
        if (userStatus == MN_USER_PLAYER) {
            [self reqSetUserStatus: MN_USER_CHATER];
        }
    }
}

-(void) setDefaultGameSetId:(NSInteger) gameSetId {
    _defaultGameSetId = gameSetId;

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionDefaultGameSetIdChangedTo:)]) {
            [delegate mnSessionDefaultGameSetIdChangedTo: gameSetId];
        }
    }

    [_delegates endCall];
}

-(NSInteger) getDefaultGameSetId {
    return _defaultGameSetId;
}

/* MNSmartFoxFacadeDelegate protocol */

-(void) onPreLoginSucceeded:(MNUserId) userId
                   userName:(NSString*) userName
                    userSID:(NSString*) sid
                lobbyRoomId:(NSInteger) lobbyRoomId
               userAuthSign:(NSString*) userAuthSign {
    BOOL userChanged = _userId != userId;

    synchronousCallCompleted = YES;
    _userId = userId;

    MNUserId tempUserId;

    [_userName release];

    if (MNParseMNUserNameToComponents(&tempUserId,&_userName,userName)) {
        [_userName retain];
    }
    else {
        _userName = [[NSString alloc] initWithString: userName];
    }

    [_userSId release];
    _userSId = [[NSString alloc] initWithString: sid];

    if (lobbyRoomId != MNLobbyRoomIdUndefined) {
        _lobbyRoomId = lobbyRoomId;
        _lobbyRoomIdIsSet = YES;
    }
    else {
        _lobbyRoomIdIsSet = NO;
        _lobbyRoomId = MNLobbyRoomIdUndefined;
    }

    if (userAuthSign != nil) {
        if (![userAuthSign isEqualToString: @""]) {
            if ([[smartFoxFacade getLoginInfoLogin] isEqualToString: MNLoginModelGuestUserLogin]) {
                [smartFoxFacade updateLoginInfoWithLogin: [NSString stringWithFormat: @"%lld", userId]
                                             andPassword: MNStructuredPasswordStringFromParams(_launchId,MNLoginModelAuthSignString,_gameSecret,userAuthSign,YES)];
            }

            MNUserCredentialsUpdateUser(varStorage,userId,_userName,userAuthSign,[NSDate date],nil);
            [self varStorageSave];

            [self notifyDevUsersInfoChanged];
        }
    }

    if (userChanged) {
        [_delegates beginCall];
        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionUserChangedTo:)]) {
                [delegate mnSessionUserChangedTo: userId];
            }
        }
        [_delegates endCall];
    }
}

-(void) onLoginSucceeded {
//    [self setNewStatus: MN_LOGGEDIN];
}

-(void) onLoginFailed:(NSString*) error {
    [self setNewStatus: MN_OFFLINE];
    synchronousCallCompleted = YES;

    [self performSelector: @selector(notifyLoginFailed:) withObject: error afterDelay: 0];
}

-(void) mnConfigLoadStarted {
    [_delegates beginCall];
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionConfigLoadStarted)]) {
            [delegate mnSessionConfigLoadStarted];
        }
    }
    [_delegates endCall];
}

-(void) mnConfigDidLoad {
    MNConfigData* configData = smartFoxFacade->configData;
    MNTrackingSystem* trackingSystem = [self getTrackingSystem];

    if (configData.launchTrackerUrl != nil) {
        [trackingSystem trackLaunchWithUrlTemplate: configData.launchTrackerUrl forSession: self];
    }

    if (configData.shutdownTrackerUrl != nil) {
        [trackingSystem setShutdownUrlTemplate: configData.shutdownTrackerUrl forSession: self];
    }

    if (configData.beaconTrackerUrl != nil) {
        [trackingSystem setBeaconUrlTemplate: configData.beaconTrackerUrl forSession: self];
    }

    if (configData.enterForegroundTrackerUrl != nil) {
        [trackingSystem setEnterForegroundUrlTemplate: configData.enterForegroundTrackerUrl];
    }

    if (configData.enterBackgroundTrackerUrl != nil) {
        [trackingSystem setEnterBackgroundUrlTemplate: configData.enterBackgroundTrackerUrl];
    }

    [_webBaseUrl release];

    _webBaseUrl = [smartFoxFacade->configData.webServerURL copy];

    if (MNSessionOfflineModeDisabled || [_offlinePack isPackUnavailable]) {
        [_delegates beginCall];

        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionWebFrontURLReady:)]) {
                [delegate mnSessionWebFrontURLReady: _webBaseUrl];
            }
        }

        [_delegates endCall];
    }

    if (!MNSessionOfflineModeDisabled) {
        [_offlinePack setWebServerUrl: _webBaseUrl];
    }

    [socNetSessionFB setFBAppId: smartFoxFacade->configData.facebookAppId];

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionConfigLoaded)]) {
            [delegate mnSessionConfigLoaded];
        }
    }
    
    [_delegates endCall];
}

-(void) mnConfigLoadDidFailWithError:(NSString*) error {
    [self notifyErrorOccurred: MNErrorInfoActionCodeLoadConfig withMessage: error];
}

-(NSString*) getWebServerURL {
    if ([smartFoxFacade->configData isLoaded]) {
        return smartFoxFacade->configData.webServerURL;
    }
    else {
        [smartFoxFacade loadConfig];

        return nil;
    }
}

-(NSString*) getWebFrontURL {
    if (MNSessionOfflineModeDisabled || [_offlinePack isPackUnavailable]) {
        return [self getWebServerURL];
    }

    NSString* startPageURL = [_offlinePack getStartPageUrl];

    if (![smartFoxFacade->configData isLoaded]) {
        [smartFoxFacade loadConfig];
    }

    return startPageURL;
}

-(void) onConnectionLost {
    synchronousCallCompleted = YES;

    [_userSId release]; _userSId = nil;

    _lobbyRoomIdIsSet = NO;
    _lobbyRoomId = MNLobbyRoomIdUndefined;

    if (_status != MN_OFFLINE) {
        [self setNewStatus: MN_OFFLINE];
    }

    if (MNSessionOfflineModeDisabled) {
        if (_userId != MNUserIdUndefined) {
            _userId = MNUserIdUndefined;
            [_userName release]; _userName = nil;

            [_delegates beginCall];
            for (id delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(mnSessionUserChangedTo:)]) {
                    [delegate mnSessionUserChangedTo: _userId];
                }
            }
            [_delegates endCall];
        }
    }
}

/* INFSmartFoxISFSEvents protocol */

-(void) onUserEnterRoom: (INFSmartFoxSFSEvent*) evt {
    INFSmartFoxUser* user = [evt.params objectForKey: @"user"];
    MNUserInfo* userInfo = nil;

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionRoomUserJoin:)]) {
            if (userInfo == nil) {
                NSString* structuredName = [user getName];

                NSString* userName;
                MNUserId  userId;

                if (!MNParseMNUserNameToComponents(&userId,&userName,structuredName)) {
                    userName = structuredName;
                    userId   = MNUserIdUndefined;
                }

                userInfo = [[MNUserInfo alloc] initWithUserId: userId
                                               userSFId: [user getId]
                                               userName: userName
                                               webBaseUrl: _webBaseUrl];
            }

            [delegate mnSessionRoomUserJoin: userInfo];
        }
    }

    [_delegates endCall];

    if (userInfo != nil) {
        [userInfo release];
    }

    if (smartFoxDelegate != nil) {
        if ([smartFoxDelegate respondsToSelector: @selector(onUserEnterRoom:)]) {
            [smartFoxDelegate onUserEnterRoom: evt];
        }
    }
}

-(void) onUserLeaveRoom: (INFSmartFoxSFSEvent*) evt {
    MNUserInfo* userInfo = nil;

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionRoomUserLeave:)]) {
            if (userInfo == nil) {
				NSString* structuredName = [evt.params objectForKey: @"userName"];
				NSInteger userSFId = [(NSNumber*)[evt.params objectForKey:@"userId"] integerValue];

                NSString* plainName;
                MNUserId  userId;

                if (!MNParseMNUserNameToComponents(&userId,&plainName,structuredName)) {
                    plainName = structuredName;
                    userId    = MNUserIdUndefined;
                }

                userInfo = [[MNUserInfo alloc] initWithUserId: userId
                                               userSFId: userSFId
                                               userName: plainName
                                               webBaseUrl: _webBaseUrl];
            }

            [delegate mnSessionRoomUserLeave: userInfo];
        }
    }

    [_delegates endCall];

    if (userInfo != nil) {
        [userInfo release];
    }

    if (smartFoxDelegate != nil) {
        if ([smartFoxDelegate respondsToSelector: @selector(onUserLeaveRoom:)]) {
            [smartFoxDelegate onUserLeaveRoom: evt];
        }
    }
}

-(void) onPrivateMessage: (INFSmartFoxSFSEvent*) evt {
    NSInteger senderSFId = [(NSNumber*)[evt.params objectForKey:@"userId"] integerValue];

    if (senderSFId != smartFoxFacade.smartFox.myUserId) {
        MNChatMessage* chatMessage = nil;

        [_delegates beginCall];

        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionChatPrivateMessageReceived:)]) {
                if (chatMessage == nil) {
                    NSString* message = (NSString*)[evt.params objectForKey:@"message"];
                    NSString* structuredName = nil;
                    INFSmartFoxUser* sfUserInfo = (INFSmartFoxUser*)[evt.params objectForKey:@"sender"];

                    if (sfUserInfo != nil) {
                        structuredName = [sfUserInfo getName];
                    }

                    NSString* plainName;
                    MNUserId  userId;

                    if (!MNParseMNUserNameToComponents(&userId,&plainName,structuredName)) {
                        plainName = structuredName;
                        userId    = MNUserIdUndefined;
                    }

                    MNUserInfo* senderInfo = [[MNUserInfo alloc] initWithUserId: userId
                                                                 userSFId: senderSFId
                                                                 userName: plainName
                                                                 webBaseUrl: _webBaseUrl];

                    if (message == nil) {
                        message = @"";
                    }

                    chatMessage = [[MNChatMessage alloc] initWithPrivateMessage: message sender: senderInfo];

                    [senderInfo release];
                }

                [delegate mnSessionChatPrivateMessageReceived:chatMessage];
            }
        }

        [_delegates endCall];

        [chatMessage release];
    }

    if (smartFoxDelegate != nil) {
        if ([smartFoxDelegate respondsToSelector: @selector(onPrivateMessage:)]) {
            [smartFoxDelegate onPrivateMessage: evt];
        }
    }
}

-(void) onPublicMessage: (INFSmartFoxSFSEvent*) evt {
    MNChatMessage* chatMessage = nil;

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionChatPublicMessageReceived:)]) {
            if (chatMessage == nil) {
                NSString* message = (NSString*)[evt.params objectForKey:@"message"];
                NSString* structuredName = nil;
                NSInteger userSFId = MNSmartFoxUserIdUndefined;
                INFSmartFoxUser* sfUserInfo = (INFSmartFoxUser*)[evt.params objectForKey:@"sender"];

                if (sfUserInfo != nil) {
                    structuredName = [sfUserInfo getName];
                    userSFId = [sfUserInfo getId];
                }

                if (message == nil) {
                    message = @"";
                }

                NSString* plainName;
                MNUserId  userId;

                if (!MNParseMNUserNameToComponents(&userId,&plainName,structuredName)) {
                    plainName = structuredName;
                    userId    = MNUserIdUndefined;
                }

                MNUserInfo* senderInfo = [[MNUserInfo alloc] initWithUserId: userId
                                                             userSFId: userSFId
                                                             userName: plainName
                                                             webBaseUrl: _webBaseUrl];

                if (message == nil) {
                    message = @"";
                }

                chatMessage = [[MNChatMessage alloc] initWithPublicMessage: message sender: senderInfo];

                [senderInfo release];
            }

            [delegate mnSessionChatPublicMessageReceived:chatMessage];
        }
    }

    [_delegates endCall];

    [chatMessage release];

    if (smartFoxDelegate != nil) {
        if ([smartFoxDelegate respondsToSelector: @selector(onPublicMessage:)]) {
            [smartFoxDelegate onPublicMessage: evt];
        }
    }
}

-(void) onJoinRoom: (INFSmartFoxSFSEvent*) evt {
    BOOL needStartGame = NO;
    INFSmartFoxRoom* room = (INFSmartFoxRoom*)[evt.params objectForKey:@"room"];
    BOOL userStatusValidOld = _userStatusValid;
    NSInteger userStatusOld = _userStatus;

    _roomExtraInfoReceived = NO;
    _userStatusValid       = NO;

    if (_status == MN_LOGGEDIN && _lobbyRoomIdIsSet && [room getId] != _lobbyRoomId) {
        _userStatusValid = [self getRoomUserStatusVariable: &_userStatus];

        id gameStateValue = [room getVariable: MNGameRoomVarNameGameStatus];

        if (gameStateValue != nil && [gameStateValue isKindOfClass: [NSNumber class]]) {
            NSUInteger newStatus = [((NSNumber*)gameStateValue) integerValue];

            if (MNSessionIsStatusValid(newStatus)) {
                [self setNewStatus: newStatus];

                if (newStatus == MN_IN_GAME_PLAY) {
                    if (_userStatusValid && _userStatus == MN_USER_PLAYER && _roomExtraInfoReceived) {
                        needStartGame = YES;
                    }
                }
            }
        }
    }
    else if (_lobbyRoomIdIsSet && [room getId] == _lobbyRoomId) {
        [self setNewStatus: MN_LOGGEDIN];

        if (_pendingGameResult != nil) {
            [self finishGameWithResult: _pendingGameResult];

            [_pendingGameResult release];

            _pendingGameResult = nil;
        }
    }

    if (smartFoxDelegate != nil) {
        if ([smartFoxDelegate respondsToSelector: @selector(onJoinRoom:)]) {
            [smartFoxDelegate onJoinRoom: evt];
        }
    }

    if (_userStatusValid != userStatusValidOld || _userStatus != userStatusOld) {
        [_delegates beginCall];

        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionRoomUserStatusChangedTo:)]) {
                [delegate mnSessionRoomUserStatusChangedTo: (_userStatusValid ? _userStatus : MN_USER_STATUS_UNDEFINED)];
            }
        }

        [_delegates endCall];
    }

    if (needStartGame) {
        [self startGameWithParamsFromActiveRoom];
    }
}

-(void) processSmartFoxExtCmdCurrGameResultsResponse: (NSDictionary*) params {
    NSString* userIdListParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamUserIdList);
    NSString* userSFIdListParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamUserSFIdList);
    NSString* userPlaceListParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamUserPlaceList);
    NSString* userScoreListParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamUserScoreList);
    NSString* resultIsFinalParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamResultIsFinal);
    NSString* gameIdParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamGameId);
    NSString* gameSetIdParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamGameSetId);
    NSString* playRoundNumberParam = MNDictionaryStringForKey(params,MNSmartFoxExtRspCurrGameResultsParamPlayRoundNumber);

    NSInteger resultIsFinal;
    NSInteger gameId;
    NSInteger gameSetId;
    long long playRoundNumber;

    BOOL ok = YES;

    if (userIdListParam == nil || userSFIdListParam == nil || userPlaceListParam == nil ||
        userScoreListParam == nil || resultIsFinalParam == nil || gameIdParam == nil ||
        gameSetIdParam == nil || playRoundNumberParam == nil) {
        ok = NO;

        NSLog(@"some of currGameResults MultiNet extension response parameters are not set");
    }

    if (ok) {
        ok = MNStringScanInteger(&resultIsFinal,resultIsFinalParam);

        if (ok) {
            ok = MNStringScanInteger(&gameId,gameIdParam);
        }

        if (ok) {
            ok = MNStringScanInteger(&gameSetId,gameSetIdParam);
        }

        if (ok) {
            ok = MNStringScanLongLong(&playRoundNumber,playRoundNumberParam);
        }

        if (!ok) {
            NSLog(@"some of currGameResults MultiNet extension response parameters have invalid numeric values");
        }
    }

    if (ok) {
        MNCurrGameResults* gameResults = nil;

        [_delegates beginCall];

        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionCurrGameResultsReceived:)]) {
                if (gameResults == nil && ok) {
                    gameResults = [[MNCurrGameResults alloc] initWithGameId: gameId
                                                             gameSetId: gameSetId
                                                             finalResult: resultIsFinal != 0 ? YES : NO
                                                             playRoundNumber: playRoundNumber];

                    NSArray* userIdArray = MNCopyLongLongArrayFromCSVString(userIdListParam);
                    NSArray* userSFIdArray = MNCopyIntegerArrayFromCSVString(userSFIdListParam);
                    NSArray* placeArray = MNCopyIntegerArrayFromCSVString(userPlaceListParam);
                    NSArray* scoreArray = MNCopyLongLongArrayFromCSVString(userScoreListParam);
                    NSUInteger userCount;

                    if (userIdArray == nil || userSFIdArray == nil || placeArray == nil || scoreArray == nil) {
                        ok = NO;

                        NSLog(@"invalid format in currGameResults MultiNet extension response");
                    }

                    if (ok) {
                        userCount = [userIdArray count];

                        if (userCount != [userSFIdArray count] ||
                            userCount != [placeArray count] ||
                            userCount != [scoreArray count]) {
                            ok = NO;

                            NSLog(@"inconsistent count of entries in currGameResults MultiNet extension response array parameters");
                        }
                    }

                    if (ok) {
                        INFSmartFoxRoom* sfRoom = [smartFoxFacade.smartFox getRoom: smartFoxFacade.smartFox.activeRoomId];

                        NSMutableArray* userInfoArray = [[NSMutableArray alloc] initWithCapacity: userCount];

                        for (NSUInteger index = 0; index < userCount; index++) {
                            NSInteger userSFId = [[userSFIdArray objectAtIndex: index] integerValue];
                            NSNumber *userSFIdNumber = [[NSNumber alloc] initWithInteger: userSFId];

                            INFSmartFoxUser* sfUser = [sfRoom getUser: userSFIdNumber];

                            [userSFIdNumber release];

                            NSString* structuredName = [sfUser getName];
                            MNUserId  tempUserId;
                            NSString* plainName;

                            if (!MNParseMNUserNameToComponents(&tempUserId,&plainName,structuredName)) {
                                plainName = structuredName;
                            }

                            MNUserInfo* userInfo = [[MNUserInfo alloc] initWithUserId: [[userIdArray objectAtIndex: index] longLongValue]
                                                                       userSFId: userSFId
                                                                       userName: plainName
                                                                       webBaseUrl: _webBaseUrl];

                            [userInfoArray addObject: userInfo];

                            [userInfo release];
                        }

                        gameResults.userInfoList = userInfoArray;

                        [userInfoArray release];
                    }

                    if (ok) {
                        gameResults.userPlaceList = placeArray;
                        gameResults.userScoreList = scoreArray;
                    }
                    else {
                        [gameResults release];

                        gameResults = nil;
                    }

                    [userIdArray release];
                    [userSFIdArray release];
                    [placeArray release];
                    [scoreArray release];
                }

                if (ok) {
                    [delegate mnSessionCurrGameResultsReceived: gameResults];
                }
            }
        }

        [_delegates endCall];

        if (gameResults != nil) {
            [gameResults release];
        }
    }
}

-(void) processSmartFoxExtCmdJoinRoomInvitationResponse: (NSDictionary*) params {
    NSString* fromUserSFIdParam = MNDictionaryStringForKey(params,MNSmartFoxExtCmdJoinRoomInvitationParamFromUserSFId);
    NSString* fromUserNameParam = MNDictionaryStringForKey(params,MNSmartFoxExtCmdJoinRoomInvitationParamFromUserName);
    NSString* roomSFIdParam =  MNDictionaryStringForKey(params,MNSmartFoxExtCmdJoinRoomInvitationParamRoomSFId);
    NSString* roomNameParam =  MNDictionaryStringForKey(params,MNSmartFoxExtCmdJoinRoomInvitationParamRoomName);
    NSString* roomGameIdParam = MNDictionaryStringForKey(params,MNSmartFoxExtCmdJoinRoomInvitationParamRoomGameId);
    NSString* roomGameSetIdParam = MNDictionaryStringForKey(params,MNSmartFoxExtCmdJoinRoomInvitationParamRoomGameSetId);
    NSString* messTextParam = MNDictionaryStringForKey(params,MNSmartFoxExtCmdJoinRoomInvitationParamMessText);

    NSInteger fromUserSFId;
    NSInteger roomSFId;
    NSInteger roomGameId;
    NSInteger roomGameSetId;

    BOOL ok = YES;
    
    if (fromUserSFIdParam == nil || fromUserNameParam == nil ||
        roomSFIdParam == nil || roomNameParam == nil ||
        roomGameIdParam == nil || roomGameSetIdParam == nil ||
        messTextParam == nil) {
        ok = NO;

        NSLog(@"some of joinRoomInvitation MultiNet extension request parameters are not set or invalid");
    }

    if (ok) {
        ok = MNStringScanInteger(&fromUserSFId,fromUserSFIdParam);

        if (ok) {
            ok = MNStringScanInteger(&roomSFId,roomSFIdParam);
        }

        if (ok) {
            ok = MNStringScanInteger(&roomGameId,roomGameIdParam);
        }

        if (ok) {
            ok = MNStringScanInteger(&roomGameSetId,roomGameSetIdParam);
        }

        if (!ok) {
            NSLog(@"some of joinRoomInvitation MultiNet extension request parameters have invalid numeric values");
        }
    }

    if (ok) {
        MNJoinRoomInvitationParams* joinRoomInvitationParams = [[MNJoinRoomInvitationParams alloc] init];

        joinRoomInvitationParams.fromUserSFId = fromUserSFId;
        joinRoomInvitationParams.fromUserName = fromUserNameParam;
        joinRoomInvitationParams.roomSFId = roomSFId;
        joinRoomInvitationParams.roomName = roomNameParam;
        joinRoomInvitationParams.roomGameId = roomGameId;
        joinRoomInvitationParams.roomGameSetId = roomGameSetId;
        joinRoomInvitationParams.inviteText = messTextParam;

        [_delegates beginCall];

        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionJoinRoomInvitationReceived:)]) {
                [delegate mnSessionJoinRoomInvitationReceived: joinRoomInvitationParams];
            }
        }

        [_delegates endCall];

        [joinRoomInvitationParams release];
    }
}

-(void) processSmartFoxExtCmdInitRoomUserInfo: (NSDictionary*) params {
    _roomExtraInfoReceived = YES;

    if (_userStatusValid && _userStatus == MN_USER_PLAYER && _status == MN_IN_GAME_PLAY) {
        [self startGameWithParamsFromActiveRoom];
    }
}

static NSString* parseFormattedMessage (NSInteger* userSFId, NSString* formattedMessage) {
    NSString* message = nil;

    *userSFId = MNSmartFoxUserIdUndefined;

    if ([formattedMessage hasPrefix: @"^"]) {
        NSRange idLimitCharRange = [formattedMessage rangeOfString: @"~"];

        if (idLimitCharRange.location != NSNotFound) {
            if (MNStringScanInteger(userSFId,[formattedMessage substringWithRange: NSMakeRange(1,idLimitCharRange.location - 1)])) {
                message = [formattedMessage substringFromIndex: idLimitCharRange.location + idLimitCharRange.length];
            }
        }
    }
    else {
        if ([formattedMessage hasPrefix: @"~"]) {
            message = [formattedMessage substringFromIndex: 1];
        }
    }

    return message;
}

-(void) onExtensionResponse: (INFSmartFoxSFSEvent*) evt {
    id dataObj = [evt.params objectForKey: MNSmartFoxExtCmdParamsKey];

    if (![dataObj isKindOfClass: [NSDictionary class]]) {
        if ([dataObj isKindOfClass: [NSString class]]) {
            NSString* strParam = (NSString*)dataObj;
            BOOL isGameMessage = NO;
            BOOL isPluginMessage = NO;
            NSString* message = nil;
            NSInteger senderSFId;

            if ([strParam hasPrefix: MNSmartFoxExtCmdSendGameMessageRawPrefix]) {
                message = parseFormattedMessage(&senderSFId,[strParam substringFromIndex: [MNSmartFoxExtCmdSendGameMessageRawPrefix length]]);

                isGameMessage = message != nil;
            }
            else if ([strParam hasPrefix: MNSmartFoxExtCmdSendGameMessageRawPrefix2]) {
                message = parseFormattedMessage(&senderSFId,[strParam substringFromIndex: [MNSmartFoxExtCmdSendGameMessageRawPrefix2 length]]);

                isGameMessage = message != nil;
            }
            else if ([strParam hasPrefix: MNSmartFoxExtCmdSendPluginMessageRawPrefix]) {
                message = parseFormattedMessage(&senderSFId,[strParam substringFromIndex: [MNSmartFoxExtCmdSendPluginMessageRawPrefix length]]);

                isPluginMessage = message != nil;
            }
            else if ([strParam hasPrefix: MNSmartFoxExtCmdSendPluginMessageRawPrefix2]) {
                message = parseFormattedMessage(&senderSFId,[strParam substringFromIndex: [MNSmartFoxExtCmdSendPluginMessageRawPrefix2 length]]);

                isPluginMessage = message != nil;
            }

            MNUserInfo* senderInfo = nil;

            if (isGameMessage || isPluginMessage) {
                if (senderSFId != MNSmartFoxUserIdUndefined) {

                    NSString* structuredName = [smartFoxFacade getUserNameBySFId: senderSFId];
                    MNUserId  userId;
                    NSString* plainName;

                    if (!MNParseMNUserNameToComponents(&userId,&plainName,structuredName)) {
                        userId    = MNUserIdUndefined;
                        plainName = structuredName;
                    }

                    senderInfo = [[[MNUserInfo alloc] initWithUserId: userId
                                                      userSFId: senderSFId
                                                      userName: plainName
                                                      webBaseUrl: _webBaseUrl] autorelease];
                }
            }

            if (isGameMessage) {
                message = MNStringUnEscapeSimple
                           (message,
                            smartFoxFacade.smartFox.rawProtocolSeparator,
                            MNGameMessageEscapeStr);

                [_delegates beginCall];

                for (id delegate in _delegates) {
                    if ([delegate respondsToSelector: @selector(mnSessionGameMessageReceived:from:)]) {
                        [delegate mnSessionGameMessageReceived: message from: senderInfo];
                    }
                }

                [_delegates endCall];
            }
            else if (isPluginMessage) {
                NSRange termCharRange = [message rangeOfString: MNPluginMessagePluginNameTermStr];

                if (termCharRange.location != NSNotFound) {
                    NSString* pluginName = [message substringToIndex: termCharRange.location];
                    NSString* messageText = [message substringFromIndex: termCharRange.location + termCharRange.length];

                    pluginName = MNStringUnEscapeSimple
                                  (MNStringUnEscapeCharSimple
                                    (pluginName,MNPluginMessagePluginNameTermStr,MNGameMessageEscapeStr),
                                   smartFoxFacade.smartFox.rawProtocolSeparator,
                                   MNGameMessageEscapeStr);

                    messageText = MNStringUnEscapeSimple
                                   (MNStringUnEscapeCharSimple
                                     (messageText,MNPluginMessagePluginNameTermStr,MNGameMessageEscapeStr),
                                    smartFoxFacade.smartFox.rawProtocolSeparator,
                                    MNGameMessageEscapeStr);

                    [_delegates beginCall];

                    for (id delegate in _delegates) {
                        if ([delegate respondsToSelector: @selector(mnSessionPlugin:messageReceived:from:)]) {
                            [delegate mnSessionPlugin: pluginName messageReceived: messageText from: senderInfo];
                        }
                    }

                    [_delegates endCall];
                }
            }
        }

        if ([smartFoxDelegate respondsToSelector: @selector(onExtensionResponse:)]) {
            [smartFoxDelegate onExtensionResponse: evt];
        }

        return;
    }

    NSDictionary *params = (NSDictionary*)dataObj;
    NSString* cmd = [params objectForKey: MNSmartFoxExtCmdParamCmd];

    if ([cmd isEqualToString: MNSmartFoxExtCmdError]) {
        NSString* errorCall = (NSString*)[params objectForKey: MNSmartFoxExtCmdErrorParamCall];

        if (errorCall != nil) {
            BOOL callHandler = YES;
            NSInteger actionCode;

            if ([errorCall isEqualToString: MNSmartFoxExtCmdJoinRandomRoom] ||
                [errorCall isEqualToString: MNSmartFoxExtCmdJoinBuddyRoom]) {
                actionCode = MNErrorInfoActionCodeJoinGameRoom;
            }
            else if ([errorCall isEqualToString: MNSmartFoxExtCmdFinishGameInRoom] ||
                     [errorCall isEqualToString: MNSmartFoxExtCmdFinishGamePlain]) {
                actionCode = MNErrorInfoActionCodePostGameResult;
            }
            else if ([errorCall isEqualToString: MNSmartFoxExtCmdCreateBuddyRoom]) {
                actionCode = MNErrorInfoActionCodeCreateBuddyRoom;
            }
            else if ([errorCall isEqualToString: MNSmartFoxExtCmdLeaveRoom]) {
                actionCode = MNErrorInfoActionCodeLeaveRoom;
            }
            else if ([errorCall isEqualToString: MNSmartFoxExtCmdStartBuddyRoomGame]) {
                actionCode = MNErrorInfoActionCodeStartBuddyRoomGame;
            }
            else if ([errorCall isEqualToString: MNSmartFoxExtCmdSetUserStatus]) {
                actionCode = MNErrorInfoActionCodeSetUserStatus;
            }
            else if ([errorCall isEqualToString: MNSmartFoxExtCmdStopRoomGame]) {
                actionCode = MNErrorInfoActionCodeStopRoomGame;
            }
            else {
                callHandler = NO;
            }

            if (callHandler) {
                NSString* errorMessage = (NSString*)[params objectForKey: MNSmartFoxExtCmdErrorParamErrorMessage];

                [self notifyErrorOccurred: actionCode withMessage: errorMessage];
            }
        }
    }
    else if ([cmd isEqualToString: MNSmartFoxExtCmdJoinRoomInvitation]) {
        [self processSmartFoxExtCmdJoinRoomInvitationResponse: params];
    }
    else if ([cmd isEqualToString: MNSmartFoxExtCmdCurrGameResults]) {
        [self processSmartFoxExtCmdCurrGameResultsResponse: params];
    }
    else if ([cmd isEqualToString: MNSmartFoxExtCmdInitRoomUserInfo]) {
        [self processSmartFoxExtCmdInitRoomUserInfo: params];
    }
    
    if ([smartFoxDelegate respondsToSelector: @selector(onExtensionResponse:)]) {
        [smartFoxDelegate onExtensionResponse: evt];
    }
}

-(void) startGameWithParamsFromActiveRoom {
    INFSmartFoxRoom* activeRoom = [smartFoxFacade.smartFox getActiveRoom];

    id gameSetIdVar = [activeRoom getVariable: MNGameRoomVarNameGameSetId];
    id gameSetParamVar = [activeRoom getVariable: MNGameRoomVarNameGameSetParam];
    id gameSeedVar = [activeRoom getVariable: MNGameRoomVarNameGameSeed];

    if (gameSetIdVar != nil && gameSetParamVar != nil && gameSeedVar != nil) {
        if ([gameSetIdVar isKindOfClass: [NSNumber class]] &&
            [gameSetParamVar isKindOfClass: [NSString class]] &&
            [gameSeedVar isKindOfClass: [NSNumber class]]) {
            MNGameParams* gameParams = [[MNGameParams alloc] initWithGameSetId: [(NSNumber*)gameSetIdVar integerValue]
                                                             gameSetParams:(NSString*) gameSetParamVar
                                                             scorePostLinkId: @""
                                                             gameSeed: [(NSNumber*)gameSeedVar integerValue]
                                                             playModel: MN_PLAYMODEL_MULTIPLAY];

            NSDictionary* roomVariables = [activeRoom getVariables];

            NSInteger gameSetPlayParamNamePrefixLen = [MNGameSetPlayParamVarNamePrefix length];

            for (id keyObject in roomVariables) {
                if ([keyObject isKindOfClass: [NSString class]]) {
                    NSString* name = (NSString*)keyObject;

                    if ([name hasPrefix: MNGameSetPlayParamVarNamePrefix]) {
                        id valueObj = [roomVariables objectForKey: keyObject];

                        if ([valueObj isKindOfClass: [NSString class]]) {
                            [gameParams addGameSetPlayParam: [name substringFromIndex: gameSetPlayParamNamePrefixLen] value: valueObj];
                        }
                    }
                }
            }

            [self startGameWithParams: gameParams];

            [gameParams release];
        }
        else {
            NSLog(@"gameSetId, gameSetParam or gameSeed room variable(s) have invalid type during game start");
        }
    }
    else {
        NSLog(@"gameSetId, gameSetParam or gameSeed room variable(s) not set during game start");
    }
 }

-(void) onRoomVariablesUpdate: (INFSmartFoxSFSEvent*) evt {
    if ([self isInGameRoom]) {
        NSArray* updatedVars = [[evt.params objectForKey: @"changedVars"] allObjects];
        NSUInteger index;
        NSUInteger count = [updatedVars count];
        BOOL needStartGame = NO;
        BOOL needFinishGame = NO;
        BOOL needCancelGame = NO;

        for (index = 0; index < count; index++) {
            NSString* varName = [updatedVars objectAtIndex: index];

            if ([varName isEqualToString: MNGameRoomVarNameGameStatus]) {
                NSNumber* newStatusValue = [[smartFoxFacade.smartFox getActiveRoom] getVariable: MNGameRoomVarNameGameStatus];
                NSUInteger newStatus = [newStatusValue integerValue];

                if (_userStatusValid && _userStatus == MN_USER_PLAYER) {
                    if (newStatus == MN_IN_GAME_PLAY && _roomExtraInfoReceived) {
                        needStartGame = YES;
                    }
                    else if (newStatus == MN_IN_GAME_END) {
                        needFinishGame = YES;
                    }
                    else if (_status == MN_IN_GAME_PLAY && newStatus == MN_IN_GAME_WAIT) {
                        needCancelGame = YES;
                    }
                }

                if (MNSessionIsStatusValid(newStatus)) {
                    [self setNewStatus: newStatus];
                }
                else {
                    NSLog(@"warning: invalid status in room variable have been ignored");
                }
            }
            else if ([varName isEqualToString: MNGameRoomVarNameGameStartCountdown]) {
                NSNumber* secondsLeftValue = [[smartFoxFacade.smartFox getActiveRoom] getVariable: MNGameRoomVarNameGameStartCountdown];

                if (secondsLeftValue != nil) {
                    NSInteger secondsLeft = [secondsLeftValue integerValue];

                    [_delegates beginCall];

                    for (id delegate in _delegates) {
                        if ([delegate respondsToSelector: @selector(mnSessionGameStartCountdownTick:)]) {
                            [delegate mnSessionGameStartCountdownTick: secondsLeft];
                        }
                    }

                    [_delegates endCall];
                }
            }
        }

        if      (needStartGame) {
            [self startGameWithParamsFromActiveRoom];
        }
        else if (needFinishGame) {
            [_delegates beginCall];

            for (id delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(mnSessionDoFinishGame)]) {
                    [delegate mnSessionDoFinishGame];
                }
            }

            [_delegates endCall];
        }
        else if (needCancelGame) {
            [_delegates beginCall];

            for (id delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(mnSessionDoCancelGame)]) {
                    [delegate mnSessionDoCancelGame];
                }
            }

            [_delegates endCall];
        }
    }

    if ([smartFoxDelegate respondsToSelector: @selector(onRoomVariablesUpdate:)]) {
        [smartFoxDelegate onRoomVariablesUpdate: evt];
    }
}

-(void) onUserVariablesUpdate: (INFSmartFoxSFSEvent*) evt {
    INFSmartFoxUser* userInfo = [evt.params objectForKey: @"user"];

    if ([userInfo getId] == smartFoxFacade.smartFox.myUserId) {
        NSSet* updatedVars = [evt.params objectForKey: @"changedVars"];

        if ([updatedVars containsObject: MNGameUserVarNameUserStatus]) {
            BOOL userStatusValidOld = _userStatusValid;
            NSInteger userStatusOld = _userStatus;

            NSInteger newUserStatus;

            if ([self getRoomUserStatusVariable: &newUserStatus]) {
                if (_status == MN_IN_GAME_PLAY) {
                    if (_userStatusValid) {
                        if (_userStatus == MN_USER_CHATER && newUserStatus == MN_USER_PLAYER && _roomExtraInfoReceived) {
                            [self startGameWithParamsFromActiveRoom];
                        }
                        else if (_userStatus == MN_USER_PLAYER && newUserStatus == MN_USER_CHATER) {
                            [_delegates beginCall];

                            for (id delegate in _delegates) {
                                if ([delegate respondsToSelector: @selector(mnSessionDoCancelGame)]) {
                                    [delegate mnSessionDoCancelGame];
                                }
                            }

                            [_delegates endCall];
                        }
                    }
                }

                _userStatusValid = YES;
                _userStatus = newUserStatus;
            }
            else {
                _userStatusValid = NO;
            }

            if (_userStatusValid != userStatusValidOld || _userStatus != userStatusOld) {
                [_delegates beginCall];

                for (id delegate in _delegates) {
                    if ([delegate respondsToSelector: @selector(mnSessionRoomUserStatusChangedTo:)]) {
                        [delegate mnSessionRoomUserStatusChangedTo: (_userStatusValid ? _userStatus : MN_USER_STATUS_UNDEFINED)];
                    }
                }

                [_delegates endCall];
            }
        }
    }

    if ([smartFoxDelegate respondsToSelector: @selector(onUserVariablesUpdate:)]) {
        [smartFoxDelegate onUserVariablesUpdate: evt];
    }
}

#define MNSessionDefineSmartFoxDelegateMethod(name)                    \
-(void) name: (INFSmartFoxSFSEvent*) evt {                             \
    if (smartFoxDelegate != nil) {                                     \
        if ([smartFoxDelegate respondsToSelector: @selector(name:)]) { \
            [smartFoxDelegate name: evt];                              \
        }                                                              \
    }                                                                  \
}

MNSessionDefineSmartFoxDelegateMethod(onAdminMessage)
MNSessionDefineSmartFoxDelegateMethod(onBuddyList)
MNSessionDefineSmartFoxDelegateMethod(onBuddyListError)
MNSessionDefineSmartFoxDelegateMethod(onBuddyListUpdate)
MNSessionDefineSmartFoxDelegateMethod(onBuddyPermissionRequest)
MNSessionDefineSmartFoxDelegateMethod(onBuddyRoom)
MNSessionDefineSmartFoxDelegateMethod(onConfigLoadFailure)
MNSessionDefineSmartFoxDelegateMethod(onConfigLoadSuccess)
MNSessionDefineSmartFoxDelegateMethod(onConnection)
MNSessionDefineSmartFoxDelegateMethod(onConnectionLost)
MNSessionDefineSmartFoxDelegateMethod(onCreateRoomError)
MNSessionDefineSmartFoxDelegateMethod(onDebugMessage)
MNSessionDefineSmartFoxDelegateMethod(onJoinRoomError)
MNSessionDefineSmartFoxDelegateMethod(onLogin)
MNSessionDefineSmartFoxDelegateMethod(onLogout)
MNSessionDefineSmartFoxDelegateMethod(onModMessage)
MNSessionDefineSmartFoxDelegateMethod(onObjectReceived)
MNSessionDefineSmartFoxDelegateMethod(onRandomKey)
MNSessionDefineSmartFoxDelegateMethod(onRoomAdded)
MNSessionDefineSmartFoxDelegateMethod(onRoomDeleted)
MNSessionDefineSmartFoxDelegateMethod(onRoomLeft)
MNSessionDefineSmartFoxDelegateMethod(onRoomListUpdate)
MNSessionDefineSmartFoxDelegateMethod(onRoundTripResponse)
MNSessionDefineSmartFoxDelegateMethod(onSpectatorSwitched)
MNSessionDefineSmartFoxDelegateMethod(onUserCountChange)

#undef MNSessionDefineSmartFoxDelegateMethod

-(void) notifyLoginFailed:(NSString*) error {
    [self notifyErrorOccurred: MNErrorInfoActionCodeLogin withMessage: error];
}

-(void) notifyErrorOccurred:(NSInteger) actionCode withMessage:(NSString*) errorMessage {
    MNErrorInfo* errorInfo = nil;

    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionErrorOccurred:)]) {
            if (errorInfo == nil) {
                errorInfo = [[MNErrorInfo alloc] initWithActionCode: actionCode andErrorMessage: errorMessage];
            }

            [delegate mnSessionErrorOccurred: errorInfo];
        }
    }

    [_delegates endCall];

    [errorInfo release];
}

-(void) notifyDevUsersInfoChanged {
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionDevUsersInfoChanged)]) {
            [delegate mnSessionDevUsersInfoChanged];
        }
    }

    [_delegates endCall];
}

-(void) setNewStatus:(NSUInteger) newStatus {
    if (newStatus == _status) {
        return;
    }

    NSUInteger oldStatus = _status;

    _status = newStatus;
    
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionStatusChangedTo:from:)]) {
            [delegate mnSessionStatusChangedTo: _status from: oldStatus];
        }
    }

    [_delegates endCall];
/*
    if (newStatus == MN_OFFLINE) {
        [self logoutFromSocNets];
    }
*/
}

-(BOOL) socNetFBConnectWithDelegate:(id<MNSessionSocNetFBDelegate>) delegate permissions:(NSArray*) permissions andError:(NSString**) error {
    BOOL ok = YES;

    if (_status != MN_OFFLINE && _status != MN_LOGGEDIN) {
        ok = NO;

        if (error != NULL) {
            *error = [NSString stringWithString: MNLocalizedString(@"You must not be in the gameplay to use Facebook connect",MNMessageCodeYouMustNotBeInGamePlayToUseFacebookConnectError)];
        }
    }

    if (ok) {
        socNetSessionFBDelegate = delegate;

        ok = [socNetSessionFB connectWithPermissions: permissions andFillErrorMessage: error];
    }

    if (!ok) {
        socNetSessionFBDelegate = nil;
    }

    return ok;
}

-(BOOL) socNetFBConnectWithDelegate:(id<MNSessionSocNetFBDelegate>) delegate andError:(NSString**) error {
    return [self socNetFBConnectWithDelegate: delegate permissions: nil andError: error];
}

-(BOOL) socNetFBResumeWithDelegate:(id<MNSessionSocNetFBDelegate>) delegate andError:(NSString**) error {
    BOOL ok = YES;

    if (_status != MN_OFFLINE && _status != MN_LOGGEDIN) {
        ok = NO;

        if (error != NULL) {
            *error = [NSString stringWithString: MNLocalizedString(@"You must not be in the gameplay to use Facebook connect",MNMessageCodeYouMustNotBeInGamePlayToUseFacebookConnectError)];
        }
    }

    if (ok) {
        socNetSessionFBDelegate = delegate;

        ok = [socNetSessionFB resumeAndFillErrorMessage: error];
    }

    if (!ok) {
        socNetSessionFBDelegate = nil;
    }

    return ok;
}

-(void) socNetFBLogout {
    [socNetSessionFB logout];
}

-(MNSocNetSessionFB*) getSocNetSessionFB {
    return socNetSessionFB;
}

-(Facebook*) getFBConnect {
    return [socNetSessionFB getFacebook];
}

-(void) socNetFBLoginOk:(MNSocNetSessionFB*) session {
    [socNetSessionFBDelegate socNetFBLoginOk: session];

    socNetSessionFBDelegate = nil;
}

-(void) socNetFBLoginCanceled {
    [socNetSessionFBDelegate socNetFBLoginCancelled];

    socNetSessionFBDelegate = nil;
}

-(void) socNetFBLoginFailed {
    [socNetSessionFBDelegate socNetFBLoginFailed: MNLocalizedString(@"Cannot connect to Facebook",MNMessageCodeFacebookLoginError)];

    socNetSessionFBDelegate = nil;
}

-(void) socNetFBLoggedOut {
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionSocNetLoggedOut:)]) {
            [delegate mnSessionSocNetLoggedOut: MNSocNetIdFaceBook];
        }
    }

    [_delegates endCall];
}

-(NSString*) stringWithVarStorageFileName {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];
    NSString* fileName = [documentsDirectory stringByAppendingPathComponent: MNVarStorageShortFileName];

    return fileName;
}

-(BOOL) varStorageSetValue:(NSString*) value forVariable:(NSString*) name {
    [varStorage setValue: value forVariable: name];
    [self notifyDevUsersInfoChanged];
    [self varStorageSave];

    return YES;
}

-(NSString*) varStorageGetValueForVariable:(NSString*) name {
    return [varStorage getValueForVariable: name];
}

-(NSDictionary*) varStorageGetValuesByMasks:(NSArray*) masks {
    return [varStorage dictionaryWithVariablesByMasks: masks];
}

-(BOOL) varStorageRemoveVariablesByMask:(NSString*) mask {
    [varStorage removeVariablesByMask: mask];
    [self notifyDevUsersInfoChanged];
    [self varStorageSave];

    return YES;
}

-(BOOL) varStorageRemoveVariablesByMasks:(NSArray*) masks {
    [varStorage removeVariablesByMasks: masks];
    [self notifyDevUsersInfoChanged];
    [self varStorageSave];

    return YES;
}

-(MNVarStorage*) getVarStorage {
    return varStorage;
}

-(MNGameVocabulary*) getGameVocabulary {
    return _gameVocabulary;
}

-(void) varStorageSave {
    [varStorage writeToFile: [self stringWithVarStorageFileName]];
}

-(void) mnOfflinePackStartPageReadyAtUrl:(NSString*) url {
    [_delegates beginCall];

    for (id delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnSessionWebFrontURLReady:)]) {
            [delegate mnSessionWebFrontURLReady: url];
        }
    }

    [_delegates endCall];
}

-(void) mnOfflinePackIsUnavailableBecauseOfError:(NSString*) error {
    if (_webBaseUrl != nil) {
        [_delegates beginCall];

        for (id delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnSessionWebFrontURLReady:)]) {
                [delegate mnSessionWebFrontURLReady: _webBaseUrl];
            }
        }

        [_delegates endCall];
    }
}

@end
