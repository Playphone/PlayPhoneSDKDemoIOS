//
//  MNDirect.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/24/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNUserProfileView.h"

@class MNAchievementsProvider;
@class MNClientRobotsProvider;
@class MNGameCookiesProvider;
@class MNMyHiScoresProvider;
@class MNPlayerListProvider;
@class MNScoreProgressProvider;
@class MNVItemsProvider;
@class MNVShopProvider;

/**
 * @brief MultiNet "Direct" delegate protocol [Simple].
 *
 * By implementing methods of MNDirectDelegate protocol, the delegate can respond to
 * most important MultiNet events.
 */
@protocol MNDirectDelegate<NSObject>
@optional

/**
 * Asks the delegate to start game.
 * @param params parameters for game to be started
 * @see  MNGameParams
 */
-(void) mnDirectDoStartGameWithParams:(MNGameParams*) params;

/**
 * Asks the delegate to finish game (on server event).
 */
-(void) mnDirectDoFinishGame;

/**
 * Asks the delegate to cancel game (on server event).
 */
-(void) mnDirectDoCancelGame;

/**
 * Tells delegate that user clicked on "Go back" button in MultiNet view.
 */
-(void) mnDirectViewDoGoBack;

/**
 * Tells the delegate that game message has been received.
 * @param message received message
 * @param sender message sender (may be nil if message has been sended by server)
 */
-(void) mnDirectDidReceiveGameMessage:(NSString*) message from:(MNUserInfo*) sender;

/**
 * Tells the delegate that MultiNet session status has been changed.
 * @param newStatus new status
 */
-(void) mnDirectSessionStatusChangedTo:(NSUInteger) newStatus;

/**
 * Tells the delegate that some error occurred
 * @param error error information
 * @see MNErrorInfo
 */
-(void) mnDirectErrorOccurred:(MNErrorInfo*) error;

/**
 * Tells the delegate that MultiNet session has been initialized and it is safe to call its methods.
 * For example, plugins initialization can be placed in this method.
 * @param session initialized MNSession object
 */
-(void) mnDirectSessionReady:(MNSession*) session;

@end

/**
 * @brief MultiNet "Direct" API interface [Simple].
 *
 * MNDirect interface provides minimal set of methods required to enable MultiNet
 * functionality in application.
 */
@interface MNDirect : NSObject {
}

/**
 * Initialize MultiNet session and MultiNet view
 * @param gameId game id
 * @param gameSecret game secret
 * @param delegate MNDirect events delegate, delegate is not retained
 * @return YES if initialization succeeded and NO if initialization failed
 */
+(BOOL) prepareSessionWithGameId:(NSInteger) gameId gameSecret:(NSString*) gameSecret andDelegate:(id<MNDirectDelegate>) delegate;

/**
 * Initialize MultiNet session and MultiNet view
 * @param gameId game id
 * @param gameSecret game secret
 * @param frame frame rectangle for the MultiNet view
 * @param delegate MNDirect events delegate, delegate is not retained
 * @return YES if initialization succeeded and NO if initialization failed
 */
+(BOOL) prepareSessionWithGameId:(NSInteger) gameId gameSecret:(NSString*) gameSecret frame:(CGRect) frame andDelegate:(id<MNDirectDelegate>) delegate;

/**
 * Create game secret string from components
 * @param secret1 first component of game secret
 * @param secret2 second component of game secret
 * @param secret3 third component of game secret
 * @param secret4 fourth component of game secret
 * @return game secret string
 */
+(NSString*) makeGameSecretByComponents:(unsigned int) secret1
                                secret2:(unsigned int) secret2
                                secret3:(unsigned int) secret3
                                secret4:(unsigned int) secret4;

/**
 * Terminate MultiNet session and release all acquired resources
 */
+(void) shutdownSession;

/**
 * Check MultiNet server connection status.
 * @return YES if user is connected to MultiNet server and NO otherwise.
 */
+(BOOL) isOnline;

/**
 * Get user login status.
 * @return YES if user is logged in and NO otherwise.
 */
+(BOOL) isUserLoggedIn;

/**
 * Get status of MultiNet session.
 * @return one of the MN_OFFLINE, MN_CONNECTING, MN_LOGGEDIN, MN_IN_GAME_WAIT,
 * MN_IN_GAME_START, MN_IN_GAME_PLAY, MN_IN_GAME_END.
 */
+(NSInteger) getSessionStatus;

/**
 * Set default game settings id
 * @param gameSetId game settings id
 */
+(void) setDefaultGameSetId:(NSInteger) gameSetId;

/**
 * Get default games settings id
 * @return default game settings id
 */
+(NSInteger) getDefaultGameSetId;

/**
 * Send game score to MultiNet server
 * @param score game score
 */
+(void) postGameScore:(long long) score;

/**
 * Schedule sending game score to MultiNet server.
 * Score will be posted as soon as player login to MultiNet.
 * @param score game score
 */
+(void) postGameScorePending:(long long) score;

/**
 * Cancel game on user request (for example "quit" button pressed)
 */

+(void) cancelGame;

/**
 * Send application custom "beacon". Beacons are used for application actions usage statistic.
 * @param actionName name of the action
 * @param beaconData "beacon" data
 * @note Under construction
 */
+(void) sendAppBeacon:(NSString*) actionName beaconData:(NSString*) beaconData;

/**
 * Send command to application
 * @param name command name
 * @param param command parameter
 */
+(void) execAppCommand:(NSString*) name withParam:(NSString*) param;

/**
 * Send game message to room.
 * @param message a message to be sent
 */
+(void) sendGameMessage:(NSString*) message;

/**
 * Asks to handle URL request if it belongs to MultiNet framework
 * @param url URL to be handled
 * @return YES if url has been handled and NO otherwise
 */
+(BOOL) handleOpenURL:(NSURL*) url;

/**
 * Get MultiNet session object instance
 * @return MultiNet session object instance
 */
+(MNSession*) getSession;

/**
 * Get MultiNet view instance
 * @return MultiNet view instance
 */
+(MNUserProfileView*) getView;

/**
 * Get achievements provider instance
 * @return MNAchievementsProvider object instance
 */
+(MNAchievementsProvider*)  achievementsProvider;

/**
 * Get client robots provider instance
 * @return MNClientRobotsProvider object instance
 */
+(MNClientRobotsProvider*)  clientRobotsProvider;

/**
 * Get game cookies provider instance
 * @return MNGameCookiesProvider object instance
 */
+(MNGameCookiesProvider*)   gameCookiesProvider;

/**
 * Get hi-scores provider instance
 * @return MNMyHiScoresProvider object instance
 */
+(MNMyHiScoresProvider*)    myHiScoresProvider;

/**
 * Get player list provider instance
 * @return MNPlayerListProvider object instance
 */
+(MNPlayerListProvider*)    playerListProvider;

/**
 * Get score progress provider instance
 * @return MNScoreProgressProvider object instance
 */
+(MNScoreProgressProvider*) scoreProgressProvider;

/**
 * Get virtual items provider instance
 * @return MNVItemsProvider object instance
 */
+(MNVItemsProvider*) vItemsProvider;

/**
 * Get virtual shop provider instance
 * @return MNVShopProvider object instance
 */
+(MNVShopProvider*) vShopProvider;

@end
