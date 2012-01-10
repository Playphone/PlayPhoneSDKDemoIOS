//
//  MNWSProvider.h
//  MultiNet client
//
//  Copyright 2012 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNWSRequest.h"
#import "MNWSAnyGameItem.h"
#import "MNWSAnyUserItem.h"
#import "MNWSCurrentUserInfo.h"
#import "MNWSCurrUserSubscriptionStatus.h"
#import "MNWSSessionSignedClientToken.h"
#import "MNWSSystemGameNetStats.h"

@interface MNWSInfoRequest : NSObject {
@private
}
@end


@interface MNWSInfoRequestResult : NSObject {
@private
    BOOL      _failed;
    NSString* _errorMessage;
}

-(BOOL)      hadError;
-(NSString*) getErrorMessage;

@end

@interface MNWSInfoRequestResultAnyGame : MNWSInfoRequestResult {
@private
    MNWSAnyGameItem* _data;
}

-(MNWSAnyGameItem*) getDataEntry;

@end


@protocol MNWSInfoRequestAnyGameDelegate<NSObject>
-(void) mnWSInfoRequestAnyGameCompleted:(MNWSInfoRequestResultAnyGame*) result;
@end


@interface MNWSInfoRequestAnyGame : MNWSInfoRequest {
@private
    NSInteger                          _gameId;
    id<MNWSInfoRequestAnyGameDelegate> _delegate;
    NSString*                          _blockName;
}

+(id) mnWSInfoRequestAnyGameWithGameId:(NSInteger) gameId andDelegate:(id<MNWSInfoRequestAnyGameDelegate>) delegate;
-(id) initWSInfoRequestAnyGameWithGameId:(NSInteger) gameId andDelegate:(id<MNWSInfoRequestAnyGameDelegate>) delegate;

@end


@interface MNWSInfoRequestResultAnyUser : MNWSInfoRequestResult {
@private
    MNWSAnyUserItem* _data;
}

-(MNWSAnyUserItem*) getDataEntry;

@end


@protocol MNWSInfoRequestAnyUserDelegate<NSObject>
-(void) mnWSInfoRequestAnyUserCompleted:(MNWSInfoRequestResultAnyUser*) result;
@end


@interface MNWSInfoRequestAnyUser : MNWSInfoRequest {
@private
    MNUserId                           _userId;
    id<MNWSInfoRequestAnyUserDelegate> _delegate;
    NSString*                          _blockName;
}

+(id) mnWSInfoRequestAnyUserWithUserId:(MNUserId) userId andDelegate:(id<MNWSInfoRequestAnyUserDelegate>) delegate;
-(id) initWSInfoRequestAnyUserWithUserId:(MNUserId) userId andDelegate:(id<MNWSInfoRequestAnyUserDelegate>) delegate;

@end


@interface MNWSInfoRequestResultAnyUserGameCookies : MNWSInfoRequestResult {
@private
    NSArray* _data;
}

-(NSArray*) getDataEntry;

@end

@protocol MNWSInfoRequestAnyUserGameCookiesDelegate<NSObject>
-(void) mnWSInfoRequestAnyUserGameCookiesCompleted:(MNWSInfoRequestResultAnyUserGameCookies*) result;
@end

@interface MNWSInfoRequestAnyUserGameCookies : MNWSInfoRequest {
@private
    NSArray*                                      _userIdList;
    NSArray*                                      _cookieKeyList;
    id<MNWSInfoRequestAnyUserGameCookiesDelegate> _delegate;
    NSString*                                     _blockName;
}

+(id) mnWSInfoRequestAnyUserGameCookiesWithUserIdList:(NSArray*) userIdList
                                        cookieKeyList:(NSArray*) cookieKeyList
                                          andDelegate:(id<MNWSInfoRequestAnyUserGameCookiesDelegate>) delegate;
-(id) initWSInfoRequestAnyUserGameCookiesWithUserIdList:(NSArray*) userIdList
                                          cookieKeyList:(NSArray*) cookieKeyList
                                            andDelegate:(id<MNWSInfoRequestAnyUserGameCookiesDelegate>) delegate;

@end


@interface MNWSInfoRequestResultCurrGameRoomList : MNWSInfoRequestResult {
@private
    NSArray* _data;
}

-(NSArray*) getDataEntry;

@end

@protocol MNWSInfoRequestCurrGameRoomListDelegate<NSObject>
-(void) mnWSInfoRequestCurrGameRoomListCompleted:(MNWSInfoRequestResultCurrGameRoomList*) result;
@end

@interface MNWSInfoRequestCurrGameRoomList : MNWSInfoRequest {
@private
    id<MNWSInfoRequestCurrGameRoomListDelegate> _delegate;
    NSString*                                   _blockName;
}

+(id) mnWSInfoRequestCurrGameRoomListWithDelegate:(id<MNWSInfoRequestCurrGameRoomListDelegate>) delegate;
-(id) initWSInfoRequestCurrGameRoomListWithDelegate:(id<MNWSInfoRequestCurrGameRoomListDelegate>) delegate;

@end


@interface MNWSInfoRequestResultCurrGameRoomUserList : MNWSInfoRequestResult {
@private
    NSArray* _data;
}

-(NSArray*) getDataEntry;

@end

@protocol MNWSInfoRequestCurrGameRoomUserListDelegate<NSObject>
-(void) mnWSInfoRequestCurrGameRoomUserListCompleted:(MNWSInfoRequestResultCurrGameRoomUserList*) result;
@end

@interface MNWSInfoRequestCurrGameRoomUserList : MNWSInfoRequest {
@private
    NSInteger                                       _roomSFId;
    id<MNWSInfoRequestCurrGameRoomUserListDelegate> _delegate;
    NSString*                                       _blockName;
}

+(id) mnWSInfoRequestCurrGameRoomUserListWithRoomSFId:(NSInteger) roomSFId
                                          andDelegate:(id<MNWSInfoRequestCurrGameRoomUserListDelegate>) delegate;
-(id) initWSInfoRequestCurrGameRoomUserListWithRoomSFId:(NSInteger) roomSFId andDelegate:(id<MNWSInfoRequestCurrGameRoomUserListDelegate>) delegate;

@end


@interface MNWSInfoRequestResultCurrUserBuddyList : MNWSInfoRequestResult {
@private
    NSArray* _data;
}

-(NSArray*) getDataEntry;

@end

@protocol MNWSInfoRequestCurrUserBuddyListDelegate<NSObject>
-(void) mnWSInfoRequestCurrUserBuddyListCompleted:(MNWSInfoRequestResultCurrUserBuddyList*) result;
@end

@interface MNWSInfoRequestCurrUserBuddyList : MNWSInfoRequest {
@private
    id<MNWSInfoRequestCurrUserBuddyListDelegate> _delegate;
    NSString*                                    _blockName;
}

+(id) mnWSInfoRequestCurrUserBuddyListWithDelegate:(id<MNWSInfoRequestCurrUserBuddyListDelegate>) delegate;
-(id) initWSInfoRequestCurrUserBuddyListWithDelegate:(id<MNWSInfoRequestCurrUserBuddyListDelegate>) delegate;

@end


@interface MNWSInfoRequestResultCurrUserSubscriptionStatus : MNWSInfoRequestResult {
@private
    MNWSCurrUserSubscriptionStatus* _data;
}

-(MNWSCurrUserSubscriptionStatus*) getDataEntry;

@end

@protocol MNWSInfoRequestCurrUserSubscriptionStatusDelegate<NSObject>
-(void) mnWSInfoRequestCurrUserSubscriptionStatusCompleted:(MNWSInfoRequestResultCurrUserSubscriptionStatus*) result;
@end

@interface MNWSInfoRequestCurrUserSubscriptionStatus : MNWSInfoRequest {
@private
    NSInteger                                             _socNetId;
    id<MNWSInfoRequestCurrUserSubscriptionStatusDelegate> _delegate;
    NSString*                                             _blockName;
}

+(id) mnWSInfoRequestCurrUserSubscriptionStatusWithDelegate:(id<MNWSInfoRequestCurrUserSubscriptionStatusDelegate>) delegate;
-(id) initWSInfoRequestCurrUserSubscriptionStatusWithDelegate:(id<MNWSInfoRequestCurrUserSubscriptionStatusDelegate>) delegate;

@end


@interface MNWSInfoRequestResultCurrentUserInfo : MNWSInfoRequestResult {
@private
    MNWSCurrentUserInfo* _data;
}

-(MNWSCurrentUserInfo*) getDataEntry;

@end

@protocol MNWSInfoRequestCurrentUserInfoDelegate<NSObject>
-(void) mnWSInfoRequestCurrentUserInfoCompleted:(MNWSInfoRequestResultCurrentUserInfo*) result;
@end

@interface MNWSInfoRequestCurrentUserInfo : MNWSInfoRequest {
@private
    id<MNWSInfoRequestCurrentUserInfoDelegate> _delegate;
    NSString*                                  _blockName;
}

+(id) mnWSInfoRequestCurrentUserInfoWithDelegate:(id<MNWSInfoRequestCurrentUserInfoDelegate>) delegate;
-(id) initWSInfoRequestCurrentUserInfoWithDelegate:(id<MNWSInfoRequestCurrentUserInfoDelegate>) delegate;

@end


@interface MNWSInfoRequestResultSessionSignedClientToken : MNWSInfoRequestResult {
@private
    MNWSSessionSignedClientToken* _data;
}

-(MNWSSessionSignedClientToken*) getDataEntry;

@end

@protocol MNWSInfoRequestSessionSignedClientTokenDelegate<NSObject>
-(void) mnWSInfoRequestSessionSignedClientTokenCompleted:(MNWSInfoRequestResultSessionSignedClientToken*) result;
@end

@interface MNWSInfoRequestSessionSignedClientToken : MNWSInfoRequest {
@private
    NSString*                                           _payload;
    id<MNWSInfoRequestSessionSignedClientTokenDelegate> _delegate;
    NSString*                                           _blockName;
}

+(id) mnWSInfoRequestSessionSignedClientTokenWithPayload:(NSString*) payload
                                             andDelegate:(id<MNWSInfoRequestSessionSignedClientTokenDelegate>) delegate;
-(id) initWSInfoRequestSessionSignedClientTokenWithPayload:(NSString*) payload
                                              andDelegate:(id<MNWSInfoRequestSessionSignedClientTokenDelegate>) delegate;

@end


@interface MNWSInfoRequestResultSystemGameNetStats : MNWSInfoRequestResult {
@private
    MNWSSystemGameNetStats* _data;
}

-(MNWSSystemGameNetStats*) getDataEntry;

@end

@protocol MNWSInfoRequestSystemGameNetStatsDelegate<NSObject>
-(void) mnWSInfoRequestSystemGameNetStatsCompleted:(MNWSInfoRequestResultSystemGameNetStats*) result;
@end

@interface MNWSInfoRequestSystemGameNetStats : MNWSInfoRequest {
@private
    id<MNWSInfoRequestSystemGameNetStatsDelegate> _delegate;
    NSString*                                     _blockName;
}

+(id) mnWSInfoRequestSystemGameNetStatsWithDelegate:(id<MNWSInfoRequestSystemGameNetStatsDelegate>) delegate;
-(id) initWSInfoRequestSystemGameNetStatsWithDelegate:(id<MNWSInfoRequestSystemGameNetStatsDelegate>) delegate;

@end

@interface MNWSInfoRequestLeaderboardMode : NSObject {
}

-(NSString*) addContent:(MNWSRequestContent*) content;

@end

@interface MNWSInfoRequestLeaderboardModeCurrentUser : MNWSInfoRequestLeaderboardMode {
@private
    NSInteger _scope;
    NSInteger _period;
}

+(id) mnWSInfoRequestLeaderboardModeCurrentUserWithScope:(NSInteger) scope andPeriod:(NSInteger) period;
-(id) initWSInfoRequestLeaderboardModeCurrentUserWithScope:(NSInteger) scope andPeriod:(NSInteger) period;

@end

@interface MNWSInfoRequestLeaderboardModeAnyGameGlobal : MNWSInfoRequestLeaderboardMode {
@private
    NSInteger _gameId;
    NSInteger _gameSetId;
    NSInteger _period;
}

+(id) mnWSInfoRequestLeaderboardModeAnyGameGlobalWithGameId:(NSInteger) gameId
                                                  gameSetId:(NSInteger) gameSetId
                                                  andPeriod:(NSInteger) period;
-(id) initWSInfoRequestLeaderboardModeAnyGameGlobalWithGameId:(NSInteger) gameId
                                                    gameSetId:(NSInteger) gameSetId
                                                    andPeriod:(NSInteger) period;
@end

@interface MNWSInfoRequestLeaderboardModeAnyUserAnyGameGlobal : MNWSInfoRequestLeaderboardMode {
@private
    MNUserId  _userId;
    NSInteger _gameId;
    NSInteger _gameSetId;
    NSInteger _period;
}

+(id) mnWSInfoRequestLeaderboardModeAnyUserAnyGameGlobalWithUserId:(MNUserId) userId
                                                            gameId:(NSInteger) gameId
                                                         gameSetId:(NSInteger) gameSetId
                                                         andPeriod:(NSInteger) period;
-(id) initWSInfoRequestLeaderboardModeAnyUserAnyGameGlobalWithUserId:(MNUserId) userId
                                                              gameId:(NSInteger) gameId
                                                           gameSetId:(NSInteger) gameSetId
                                                           andPeriod:(NSInteger) period;
@end

@interface MNWSInfoRequestLeaderboardModeCurrUserAnyGameLocal : MNWSInfoRequestLeaderboardMode {
@private
    NSInteger _gameId;
    NSInteger _gameSetId;
    NSInteger _period;
}

+(id) mnWSInfoRequestLeaderboardModeCurrUserAnyGameLocalWithGameId:(NSInteger) gameId
                                                         gameSetId:(NSInteger) gameSetId
                                                         andPeriod:(NSInteger) period;
-(id) initWSInfoRequestLeaderboardModeCurrUserAnyGameLocalWithGameId:(NSInteger) gameId
                                                           gameSetId:(NSInteger) gameSetId
                                                           andPeriod:(NSInteger) period;
@end

@interface MNWSInfoRequestResultLeaderboard : MNWSInfoRequestResult {
@private
    NSArray* _data;
}

-(NSArray*) getDataEntry;

@end

@protocol MNWSInfoRequestLeaderboardDelegate<NSObject>
-(void) mnWSInfoRequestLeaderboardCompleted:(MNWSInfoRequestResultLeaderboard*) result;
@end

@interface MNWSInfoRequestLeaderboard : MNWSInfoRequest {
@private
    MNWSInfoRequestLeaderboardMode*        _mode;
    id<MNWSInfoRequestLeaderboardDelegate> _delegate;
    NSString*                              _blockName;
}

+(id) mnWSInfoRequestLeaderboardWithMode:(MNWSInfoRequestLeaderboardMode*) mode
                             andDelegate:(id<MNWSInfoRequestLeaderboardDelegate>) delegate;
-(id) initWSInfoRequestLeaderboardWithMode:(MNWSInfoRequestLeaderboardMode*) mode
                               andDelegate:(id<MNWSInfoRequestLeaderboardDelegate>) delegate;

@end


@interface MNWSLoader : NSObject {
@private
    MNWSRequest* _request;
}

-(void) cancel;
@end

/**
 * @brief "Web service" MultiNet provider.
 *
 * "Web service" provider provides ability to send information requests to the server.
 */
@interface MNWSProvider : NSObject {
@private

    MNSession* _session;
}

/**
 * Initializes and return newly allocated MNWSProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session;

/**
 * Send information request to server
 * @param request request to be sent
 * @return MNWSLoader object (it can be user to cancel request)
 */
-(MNWSLoader*) send:(MNWSInfoRequest*) request;
/**
 * Send several information requests to server simultaneously
 * @param requests array of requests to be sent
 * @return MNWSLoader object (it can be user to cancel request)
 */
-(MNWSLoader*) sendBatch:(NSArray*) requests;

@end
