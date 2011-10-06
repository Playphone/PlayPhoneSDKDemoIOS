//
//  MNSession.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/20/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <time.h>

#import "external/SmartFox/Header/INFSmartFoxiPhoneClient.h"

#import "MNCommon.h"
#import "MNSmartFoxFacade.h"
#import "MNChatMessage.h"
#import "MNGameParams.h"
#import "MNGameResult.h"
#import "MNUserInfo.h"
#import "MNBuddyRoomParams.h"
#import "MNJoinRoomInvitationParams.h"
#import "MNCurrGameResults.h"
#import "MNSocNetSessionFB.h"
#import "MNErrorInfo.h"
#import "MNVarStorage.h"
#import "MNOfflinePack.h"
#import "MNDelegateArray.h"
#import "MNAppHostCallInfo.h"

@class Facebook;
@class MNTrackingSystem;
@class MNGameVocabulary;

@protocol MNSessionDelegate;
@protocol MNSessionSocNetFBDelegate;

/**
 * @brief MultiNet framework session.
 *
 * This class is responsible for all interactions with MultiNet server.
 */
@interface MNSession : NSObject<MNSmartFoxFacadeDelegate,INFSmartFoxISFSEvents,MNSocNetFBDelegate,MNOfflinePackDelegate> {
@private

MNDelegateArray* _delegates;
NSInteger _gameId;
NSString* _gameSecret;
NSUInteger _status;
BOOL _userStatusValid; /* set to NO on joining room and set to YES on user status variable update notification received */
NSInteger _userStatus;
BOOL _roomExtraInfoReceived;
NSInteger _defaultGameSetId;
MNGameResult* _pendingGameResult;

MNUserId _userId;
NSString* _userName;
NSString* _userSId;

NSURL* _handledURL;

MNSmartFoxFacade *smartFoxFacade;

id<INFSmartFoxISFSEvents> smartFoxDelegate;

MNTrackingSystem* _trackingSystem; // use getTrackingSystem to access tracking system (it is created "on demand")

BOOL _lobbyRoomIdIsSet;
NSInteger _lobbyRoomId;

BOOL synchronousCallCompleted;

/* social networks - related vars */
MNSocNetSessionFB* socNetSessionFB;
id<MNSessionSocNetFBDelegate> socNetSessionFBDelegate;

/* ping timer */

/*NSTimer* pingTimer; */

BOOL reloginRequired;
BOOL _autoReconnectOnWakeEnabled;
NSUInteger _disconnectOnSleepDelay;

MNOfflinePack* _offlinePack;

MNVarStorage* varStorage;
NSString* _webBaseUrl;

time_t    _launchTime;
NSString* _launchId;
BOOL      _shutdownTracked;

BOOL         _inForeground;
unsigned int _foregroundSwitchCount;
time_t       _foregroundLastStartTime;
time_t       _foregroundAccumulatedTime;

MNGameVocabulary* _gameVocabulary;
}

/**
 * The smartFox delegate. All smartFox events are sent to smartFoxDelegate.
 */
@property (nonatomic,retain) id<INFSmartFoxISFSEvents> smartFoxDelegate;

/**
 * Boolean flag indicating if connection to server should be re-established after
 * device woke up.
 */
@property (nonatomic,assign) BOOL autoReconnectOnWakeEnabled;

/**
 * The number of seconds client will wait after application became inactive to disconnect from server.
 */
@property (nonatomic,assign) NSUInteger disconnectOnSleepDelay;

/**
 * Boolean flag indicating if connection to server should be re-established after
 * network errors occured.
 */
@property (nonatomic,assign) BOOL autoReconnectOnNetErrorsEnabled;

/**
 * Initializes and returns a newlly allocated MultiNet session object with specified game id.
 * @param gameId a game id
 * @param game (application) secret
 * @return An initialized object or nil if the object couldn't be created.
 */
-(id) initWithGameId:(NSInteger) gameId andGameSecret:(NSString*) gameSecret;
/**
 * Destroys MultiNet session object and releases all acquired resources.
 */
-(void) dealloc;

/**
 * Login to MultiNet server using user login and password (synchronous). Control is not returned to caller
 * until user will be logged in or some error occurs.
 * @param userLogin user login
 * @param userPassword user password
 * @param saveCredentials boolean flag that specifies if user credentials must be stored
 * @return YES if login procedure completed successfully and NO if some error occured.
 */
-(BOOL) loginSynchronousWithUserLogin:(NSString*) userLogin password:(NSString*) userPassword saveCredentials:(BOOL) saveCredentials;
/**
 * Login to MultiNet server using user login and password (asynchronous). mnSessionStatusChangedTo:from: message will be sent to
 * delegates in case of successfull login. In case of login failure mnSessionLoginFailed: will be sent to delegates.
 * @param userLogin user login
 * @param userPassword user password
 * @param saveCredentials boolean flag that specifies if user credentials must be stored
 * @return YES if login procedure started successfully and NO if some error occured.
 */
-(BOOL) loginWithUserLogin:(NSString*) userLogin password:(NSString*) userPassword saveCredentials:(BOOL) saveCredentials;
/**
 * Login to MultiNet server using MultiNet user id and password hash(asynchronous). mnSessionStatusChangedTo:from: message will be sent to
 * delegates in case of successfull login. In case of login failure mnSessionLoginFailed: will be sent to delegates.
 * @param userId MultiNet user id
 * @param userPassword md5-hash of user password
 * @param saveCredentials boolean flag that specifies if user credentials must be stored
 * @return YES if login procedure started successfully and NO if some error occured.
 */
-(BOOL) loginWithUserId:(MNUserId) userId passwordHash:(NSString*) userPasswordHash saveCredentials:(BOOL) saveCredentials;
/**
 * Login to MultiNet server using unique device identifier(asynchronous). mnSessionStatusChangedTo:from: message will be sent to
 * delegates in case of successfull login. In case of login failure mnSessionLoginFailed: will be sent to delegates.
 * @return YES if login procedure started successfully and NO if some error occured.
 */
-(BOOL) loginWithDeviceCredentials;
/**
 * Login to MultiNet server using authentication sign(asynchronous). mnSessionStatusChangedTo:from: message will be sent to
 * delegates in case of successfull login. In case of login failure mnSessionLoginFailed: will be sent to delegates.
 * @param userId MultiNet user id
 * @param authSign authentication sign
 * @return YES if login procedure started successfully and NO if some error occured.
 */
-(BOOL) loginWithUserId:(MNUserId) userId authSign:(NSString*) authSign;

/**
 * Login to MultiNet (offline) using authentication sign(asynchronous). mnSessionUserChangedTo: message will be sent to
 * delegates in case of successfull login. In case of login failure mnSessionLoginFailed: will be sent to delegates.
 * @param userId MultiNet user id
 * @param authSign authentication sign
 * @return YES if login procedure started successfully and NO if some error occured.
 */
-(BOOL) loginOfflineWithUserId:(MNUserId) userId authSign:(NSString*) authSign;

/**
 * Signup to MultiNet (offline). mnSessionUserChangedTo: message will be sent to
 * delegates in case of successfull signup/login.
 * @return YES if signup procedure started successfully and NO if some error occured.
 */
-(BOOL) signupOffline;

/**
 * Login to MultiNet server using last used user account, or as a guest if there is no stored login info. mnSessionStatusChangedTo:from: message will be sent to
 * delegates in case of successfull login. In case of login failure mnSessionLoginFailed: will be sent to delegates.
 * @return YES if login procedure started successfully and NO if some error occured.
 */
-(BOOL) loginAuto;

/**
 * Check if relogin possible (it is possible if one of the login... methods was called previously).
 * @return YES if relogin possible and NO otherwise.
 */
-(BOOL) isReLoginPossible;
/**
 * Login to MultiNet server using parameters previously passed to login... method
 */
-(void) reLogin;
/**
 * Terminate MultiNet session
 */
-(void) logout;

/**
 * Terminate MultiNet session and (optionaly) remove stored user credentials
 * @param wipeMode mode of saved credentials removal (one of the MN_CREDENTIALS_WIPE_NONE, MN_CREDENTIALS_WIPE_USER or MN_CREDENTIALS_WIPE_ALL)
 */
-(void) logoutAndWipeUserCredentialsByMode:(NSInteger) wipeMode;

/**
 * Check MultiNet server connection status.
 * @return YES if user is connected to MultiNet server and NO otherwise.
 */
-(BOOL) isOnline;

/**
 * Get user login status.
 * @return YES if user is logged in and NO otherwise.
 */
-(BOOL) isUserLoggedIn;

/**
 * Get current session game id.
 * @return game id.
 */
-(NSInteger) getGameId;
/**
 * Get status of MultiNet session.
 * @return one of the MN_OFFLINE, MN_CONNECTING, MN_LOGGEDIN, MN_IN_GAME_WAIT,
 * MN_IN_GAME_START, MN_IN_GAME_PLAY, MN_IN_GAME_END.
 */
-(NSInteger) getStatus;
/**
 * Get user name.
 * @return user name if user is logged in and nil otherwise.
 */
-(NSString*) getMyUserName;

/**
 * Get MultiNet user id.
 * @return MultiNet user id if user is logged in and MNUserIdUndefined otherwise.
 */
-(MNUserId) getMyUserId;

/**
 * Get SmartFox user id.
 * @return SmartFox user id if user is logged in and MNSmartFoxUserIdUndefined otherwise.
 */
-(NSInteger) getMyUserSFId;

/**
 * Get user information
 * @return MNUserInfo instance containing information about current user or nil if user is not logged in.
 */
-(MNUserInfo*) getMyUserInfo;

/**
 * Get list of users in current room.
 * @return array of MNUserInfo instances describing users located in the same room with current user. Empty array
 * is returned if user is not logged in.
 */
-(NSArray*) getRoomUserList;

/**
 * Get information on user by user's SmartFox id
 * @param  sfid SmartFox user id
 * @return MNUserInfo object or nil if there is no such user in current room
 */
-(MNUserInfo*) getUserInfoBySFId:(NSInteger) sfId;

/**
 * Get user status in game room.
 * @return one of the MN_USER_PLAYER, MN_USER_CHATER or MN_USER_STATUS_UNDEFINED
 */
-(NSInteger) getRoomUserStatus;

/**
 * Get current session id.
 * @return current session id or nil if user is not logged in.
 */
-(NSString*) getMySId;
/**
 * Get current room smartFox id.
 * @return current room smartFox id (the same as smartFoxFacade.smartFox.activeRoomId)
 */
-(NSInteger) getCurrentRoomId;

/**
 * Get current room game settings id.
 * @return game settings id of current game room, zero if not in game room, or game settings id is not set
 */
-(NSInteger) getRoomGameSetId;

/**
 * Send application custom "beacon". Beacons are used for application actions usage statistic.
 * @param actionName name of the action
 * @param beaconData "beacon" data
 * @note Under construction
 */
-(void) sendAppBeacon:(NSString*) actionName beaconData:(NSString*) beaconData;

/**
 * Send private message.
 * @param message a message text to be sent
 * @param userSFId receiver smartFox user id
 */
-(void) sendPrivateMessage:(NSString*) message to: (NSInteger) userSFId;
/**
 * Send public message.
 * @param message a message text to be sent
 */
-(void) sendChatMessage:(NSString*) message;
/**
 * Send game message to room
 * @param message a message to be sent
 */
-(void) sendGameMessage:(NSString*) message;
/**
 * Send plugin message
 * @param pluginName plugin name
 * @param message a message to be sent
 */
-(void) sendPlugin:(NSString*) pluginName message:(NSString*) message;

/**
 * Join buddy room. mnSessionStatusChangedTo:from: message will be sent to delegates
 * if user successfully joined the room, mnSessionGameRoomJoinFailed: will be sent if
 * join failed.
 * @param roomSFId a smartFox room id to join to
 * @deprecated This method is deprecated. sendJoinRoomInvitationResponse:accept: should be used instead.
 */
-(void) reqJoinBuddyRoom:(NSInteger) roomSFId;

/**
 * Send a response to "join room" invitation.
 * @param invitationParams an invitation parameters.
 * @param accept YES if invitation should be accepted, NO if invitation should be rejected
 */
-(void) sendJoinRoomInvitationResponse:(MNJoinRoomInvitationParams*) invitationParams accept:(BOOL) accept;

/**
 * Join random room with choosen gameset id. mnSessionStatusChangedTo:from: message will be sent to delegates
 * if user successfully joined the room, mnSessionGameRoomJoinFailed: will be sent if
 * join failed.
 * @param gameSetId a gameset id
 */
-(void) reqJoinRandomRoom:(NSString*) gameSetId;
/**
 * Create game room and send invitation to buddies to join the game. mnSessionStatusChangedTo:from:
 * message will be sent to delegates if room have been created successfully, mnSessionCreateBuddyRoomFailed:
 * will be send if some error occured.
 * @param buddyRoomParams parameters of room to be created, invitation text and buddy list
 * invitations must be sent to.
 * @sa MNBuddyRoomParams.
 */
-(void) reqCreateBuddyRoom:(MNBuddyRoomParams*) buddyRoomParams;
/**
 * Start game in previously created buddy room.
 */
-(void) reqStartBuddyRoomGame;

/**
 * Request server to stop the game.
 */
-(void) reqStopRoomGame;

/**
 * Receive updated game results from MultiNet server (asynchronous). mnSessionCurrGameResultsReceived:
 * message will be sent to delegates then results will be received.
 */
-(void) reqCurrentGameResults;

/**
 * Set user status.
 * @param userStatus new user status (must be MN_USER_PLAYER or _MN_USER_CHATER).
 * mnSessionErrorOccurred: message will be sent to delegates if some error
 * occured.
 */
-(void) reqSetUserStatus:(NSInteger) userStatus;

/**
 * Send mnSessionDoStartGameWithParams: message to delegates. It is the responsibility of one of the delegates
 * to start game logic.
 * @param gameParams the parameters of game to be started
 * @see MNGameParams
 */
-(void) startGameWithParams:(MNGameParams*) gameParams;

/**
 * Send finished game score to MultiNet server. mnSessionFinishGamePostFailed: message
 * will be sent to delegates if score sending failed.
 * @param gameResult MNGameResuls object to be sent to server
 * @see MNGameResult
 */
-(void) finishGameWithResult:(MNGameResult*) gameResult;

/**
 * Schedule sending game score to MultiNet server.
 * Score will be posted as soon as player login to MultiNet. Sending game
 * score can be canceled using cancelPostScoreOnLogin method.
 * @param gameResult MNGameResuls object to be sent to server
 * @see MNGameResult
 */
-(void) schedulePostScoreOnLogin:(MNGameResult*) gameResult;

/**
 * Cancel scheduled game score sending.
 */
-(void) cancelPostScoreOnLogin;

/**
 * Cancel game on user request (for example "quit" button pressed)
 * @param gameParams the parameters of game been canceled
 * @see MNGameParams
 */
-(void) cancelGameWithParams:(MNGameParams*) gameParams;

/**
 * Set default game settings id
 * @param gameSetId game settings id
 */
-(void) setDefaultGameSetId:(NSInteger) gameSetId;

/**
 * Get default games settings id
 * @return default game settings id
 */
-(NSInteger) getDefaultGameSetId;

/**
 * Leave current room
 */
-(void) leaveRoom;

/**
 * Send command to application
 * @param name command name
 * @param param command parameter
 */
-(void) execAppCommand:(NSString*) name withParam:(NSString*) param;

/**
 * Send command to application (initiated by UI or some other external subsystem)
 * @param name command name
 * @param param command parameter
 */
-(void) execUICommand:(NSString*) name withParam:(NSString*) param;

/**
 * Processes web event
 * @param name event name
 * @param param event-specific parameter
 * @param callbackId request identifier (optional)
 */
-(void) processWebEvent:(NSString*) name withParam:(NSString*) param andCallbackId:(NSString*) callbackId;

/**
 * Posts system event
 * @param name event name
 * @param param event-specific parameter
 * @param callbackId request identifier (optional)
 */
-(void) postSysEvent:(NSString*) name withParam:(NSString*) param andCallbackId:(NSString*) callbackId;

/**
 * Notifies delegates that apphost call has been received and allows to override default apphost call processing
 * @return YES if delegate processed a call and default handling should not be called, NO - if delegate
 * did not process a call
 */
-(BOOL) preprocessAppHostCall:(MNAppHostCallInfo*) appHostCallInfo;

/**
 * Asks to handle URL request if it belongs to MultiNet framework
 * @param url URL to be handled
 * @return YES if url has been handled and NO otherwise
 */
-(BOOL) handleOpenURL:(NSURL*) url;

/**
 * Get URL which is handled by MultiNet framework
 * @return URL which is handled or nil if application does not handle URL or URL does not belong to MultiNet framework
 */
-(NSURL*) getHandledURL;

-(BOOL) socNetFBConnectWithDelegate:(id<MNSessionSocNetFBDelegate>) delegate andError:(NSString**) error;
-(BOOL) socNetFBConnectWithDelegate:(id<MNSessionSocNetFBDelegate>) delegate permissions:(NSArray*) permissions andError:(NSString**) error;
-(BOOL) socNetFBResumeWithDelegate:(id<MNSessionSocNetFBDelegate>) delegate andError:(NSString**) error;
-(void) socNetFBLogout;
-(MNSocNetSessionFB*) getSocNetSessionFB;

/**
 * Get facebook object instance
 * Usage of returned object is restricted. Consult documentation for further information. In particular,
 * authorize:delegate: and logout: calls are not allowed.
 * @return facebook object instance
 */
-(Facebook*) getFBConnect;

-(BOOL) varStorageSetValue:(NSString*) value forVariable:(NSString*) name;
-(NSString*) varStorageGetValueForVariable:(NSString*) name;
-(NSDictionary*) varStorageGetValuesByMasks:(NSArray*) masks;
-(BOOL) varStorageRemoveVariablesByMask:(NSString*) mask;
-(BOOL) varStorageRemoveVariablesByMasks:(NSArray*) masks;
-(MNVarStorage*) getVarStorage;

-(NSString*) getWebServerURL;
-(NSString*) getWebFrontURL;

/**
 * Get game vocabulary object
 * @return game vocabulary object instance
 */
-(MNGameVocabulary*) getGameVocabulary;

/**
 * Adds delegate
 * @param delegate an object conforming to MNSessionDelegate protocol
 */
-(void) addDelegate:(id<MNSessionDelegate>) delegate;
/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNSessionDelegate>) delegate;

/**
 * Get underlying smartFox client object instance
 * @return instance of smartFox client object
 */
-(INFSmartFoxiPhoneClient*) getSmartFox;
@end

/**
 * @brief MultiNet session delegate protocol.
 *
 * By implementing methods of MNSessionDelegate protocol, the delegate can respond to
 * MultiNet session events such as MultiNet session state changes, presence of incoming chat messages and others.
 */
@protocol MNSessionDelegate<NSObject>
@optional

/**
 * Tells the delegate that MultiNet session status has been changed.
 * @param newStatus new status
 * @param oldStatus previous status
 */
-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus;

/**
 * Tells the delegate that logged user has been changed.
 * @param userId user id of new user
 */
-(void) mnSessionUserChangedTo:(MNUserId) userId;

/**
 * Tells the delegate that login procedure has been started.
 */
-(void) mnSessionLoginInitiated; /* used by UserProfileView to show activity indicator */

/**
 * Asks the delegate to start game.
 * @param params parameters for game to be started
 */
-(void) mnSessionDoStartGameWithParams:(MNGameParams*) params;

/**
 * Asks the delegate to finish game (on server event).
 */
-(void) mnSessionDoFinishGame;

/**
 * Asks the delegate to cancel game (on server event).
 */
-(void) mnSessionDoCancelGame;

/**
 * Tells delegate that player finished game.
 * @param gameResult MNGameResuls object containing player result
 * @see MNGameResult
 */
-(void) mnSessionGameFinishedWithResult:(MNGameResult*) gameResult;

/**
 * Tells the delegate that user join current room.
 * @param userInfo joined user data
 * @see MNUserInfo
 */
-(void) mnSessionRoomUserJoin:(MNUserInfo*) userInfo;

/**
 * Tells the delegate that user left current room.
 * @param userInfo user data
 * @see MNUserInfo
 */
-(void) mnSessionRoomUserLeave:(MNUserInfo*) userInfo;

/**
 * Tells the delegate that private message has been received.
 * @param chatMessage received message data
 * @see MNChatMessage
 */
-(void) mnSessionChatPrivateMessageReceived:(MNChatMessage*) chatMessage;

/**
 * Tells the delegate that public message has been received.
 * @param chatMessage received message data
 * @see MNChatMessage
 */
-(void) mnSessionChatPublicMessageReceived:(MNChatMessage*) chatMessage;

/**
 * Tells the delegate that game message has been received.
 * @param message received message
 * @param sender message sender (may be nil if message has been sended by server)
 */
-(void) mnSessionGameMessageReceived:(NSString*) message from:(MNUserInfo*) sender;

/**
 * Tells the delegate that plugin message has been received.
 * @param pluginName plugin name
 * @param message received message
 * @param sender message sender (may be nil if message has been sended by server)
 */
-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender;

/**
 * Tells the delegate that invitation to join game room has been received.
 * @param params invitation data
 * @see MNJoinRoomInvitationParams
 */
-(void) mnSessionJoinRoomInvitationReceived:(MNJoinRoomInvitationParams*) params;

/**
 * Tells the delegate how many seconds left to game start.
 * @param secondsLeft seconds to game start
 */
-(void) mnSessionGameStartCountdownTick:(NSInteger) secondsLeft;

/**
 * Tells the delegate that new/updated game results have been received.
 * @param gameResults received game results
 * @see MNCurrGameResults
 */
-(void) mnSessionCurrGameResultsReceived:(MNCurrGameResults*) gameResults;

/**
 * Tells the delegate that some error occurred
 * @param error error information
 * @see MNErrorInfo
 */
-(void) mnSessionErrorOccurred:(MNErrorInfo*) error;

/**
 * Tells the delegate that user status has been changed.
 * @param newStatus new status
 */
-(void) mnSessionRoomUserStatusChangedTo:(NSInteger) newStatus;

/**
 * Tells the delegate that connection with social network has been terminated.
 * @param socNetId social network identifier
 */
-(void) mnSessionSocNetLoggedOut:(NSInteger) socNetId;

/**
 * Tells the delegate that device users info changed
 */
-(void) mnSessionDevUsersInfoChanged;

/**
 * Tells the delegate that default game settings id has been changed
 * @param gameSetId new default game settings id
 */
-(void) mnSessionDefaultGameSetIdChangedTo:(NSInteger)gameSetId;

/**
 * Tells the delegate that MultiNet configuration loading has been started
 */
-(void) mnSessionConfigLoadStarted;

/**
 * Tells the delegate that MultiNet configuration has been loaded
 */
-(void) mnSessionConfigLoaded;

/**
 * Tells the delegate that WebFront URL can be used
 */
-(void) mnSessionWebFrontURLReady:(NSString*) url;

/**
 * Tells the delegate that MNSession's execAppCommand:withParam: method has been called
 * @param cmdName command name
 * @param cmdParam command parameter
 */
-(void) mnSessionExecAppCommandReceived:(NSString*) cmdName withParam:(NSString*) cmdParam;

/**
 * Tells the delegate that MNSession's execUICommand:withParam: method has been called
 * @param cmdName command name
 * @param cmdParam command parameter
 */
-(void) mnSessionExecUICommandReceived:(NSString*) cmdName withParam:(NSString*) cmdParam;

/**
 * Tells the delegate that MNSession's processWebEvent:withParam:andCallbackId method has been called
 * @param eventName event name
 * @param eventParam event parameter
 * @param callbackId request identifier
 */
-(void) mnSessionWebEventReceived:(NSString*) eventName withParam:(NSString*) eventParam andCallbackId:(NSString*) callbackId;

/**
 * Tells the delegate that MNSession's postSysEvent:withParam:andCallbackId method has been called
 * @param eventName event name
 * @param eventParam event parameter
 * @param callbackId request identifier
 */
-(void) mnSessionSysEventReceived:(NSString*) eventName withParam:(NSString*) eventParam andCallbackId:(NSString*) callbackId;

/**
 * Tells the delegate that "apphost" call received and allows to override default handling
 * @return YES if delegate processed a call and default handling should not be called, NO - if delegate
 * did not process a call
 */
-(BOOL) mnSessionAppHostCallReceived:(MNAppHostCallInfo*) appHostCallInfo;

/**
 * Tells the delegate that application was asked to open URL which belongs to MultiNet framework
 * @param url URL to be handled
 */
-(void) mnSessionHandleOpenURL:(NSURL*) url;

@end

@protocol MNSessionSocNetFBDelegate<NSObject>
-(void) socNetFBLoginOk:(MNSocNetSessionFB*) session;
-(void) socNetFBLoginFailed:(NSString*) error;
-(void) socNetFBLoginCancelled;
@end
