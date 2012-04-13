//
//  MNWSProvider.m
//  MultiNet client
//
//  Copyright 2012 PlayPhone. All rights reserved.
//

#import "MNWSRequest.h"
#import "MNWSProvider.h"

@interface MNWSRequestContent()
-(NSString*) addCurrUserSubscriptionStatusForSnId:(NSInteger) snId;
@end

@interface MNWSInfoRequest()
-(void) handleRequestCompleted:(MNWSResponse*) response;
-(void) handleRequestError:(MNWSRequestError*) error;
-(void) addContent:(MNWSRequestContent*) content;
@end

@interface MNWSInfoRequestResult()
-(void) setError:(NSString*) errorMessage;
@end

@interface MNWSProviderRequestDelegate : NSObject<MNWSRequestDelegate> {
@private
    NSArray* _requests;
}

-(id) initWithMNWSInfoRequests:(NSArray*) requests;

@end


@implementation MNWSInfoRequest

-(void) handleRequestCompleted:(MNWSResponse*) response {
}

-(void) handleRequestError:(MNWSRequestError*) error {
}

-(void) addContent:(MNWSRequestContent*) content {
}

@end

@implementation MNWSInfoRequestResult

-(id) init {
    self = [super init];

    if (self != nil) {
        _failed       = false;
        _errorMessage = nil;
    }

    return self;
}

-(void) dealloc {
    [_errorMessage release];

    [super dealloc];
}

-(void) setError:(NSString*) errorMessage {
    _failed = YES;
    [_errorMessage release];
    _errorMessage = [errorMessage retain];
}

-(BOOL) hadError {
    return _failed;
}

-(NSString*) getErrorMessage {
    return _errorMessage;
}

@end


@implementation MNWSProviderRequestDelegate

-(id) initWithMNWSInfoRequests:(NSArray *)requests {
    self = [super init];

    if (self != nil) {
        _requests = [requests retain];
    }

    return self;
}

-(void) dealloc {
    [_requests release];

    [super dealloc];
}

-(void) wsRequestDidSucceed:(MNWSResponse*) response {
    for (MNWSInfoRequest* request in _requests) {
        [request handleRequestCompleted: response];
    }

    [self autorelease];
}

-(void) wsRequestDidFailWithError:(MNWSRequestError*) error {
    for (MNWSInfoRequest* request in _requests) {
        [request handleRequestError: error];
    }

    [self autorelease];
}

@end


@implementation MNWSLoader

-(id) initWithMNWSRequest:(MNWSRequest*) request {
    self = [super init];

    if (self != nil) {
        _request = request;
    }

    return self;
}

-(void) cancel {
    [_request cancel];
}

@end


@implementation MNWSProvider

-(id) initWithSession: (MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session = session;
    }

    return self;
}

-(MNWSLoader*) send:(MNWSInfoRequest*) request {
    return [self sendBatch: [NSArray arrayWithObject: request]];
}

-(MNWSLoader*) sendBatch:(NSArray*) requests {
    MNWSRequestSender*  sender  = [[MNWSRequestSender alloc] initWithSession: _session];
    MNWSRequestContent* content = [[MNWSRequestContent alloc] init];
    MNWSProviderRequestDelegate* delegate = [[MNWSProviderRequestDelegate alloc] initWithMNWSInfoRequests: requests];

    for (MNWSInfoRequest* request in requests) {
        [request addContent: content];
    }

    MNWSLoader* loader = [[[MNWSLoader alloc] initWithMNWSRequest: [sender sendWSRequestSmartAuth: content withDelegate: delegate]] autorelease];

    [sender release];
    [content release];

    return loader;
}

@end


@implementation MNWSInfoRequestResultAnyGame

-(id) initWithMNWSAnyGameItem:(MNWSAnyGameItem*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(MNWSAnyGameItem*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestAnyGame

+(id) mnWSInfoRequestAnyGameWithGameId:(NSInteger) gameId andDelegate:(id<MNWSInfoRequestAnyGameDelegate>) delegate {
    return [[[MNWSInfoRequestAnyGame alloc] initWSInfoRequestAnyGameWithGameId: gameId andDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestAnyGameWithGameId:(NSInteger) gameId andDelegate:(id<MNWSInfoRequestAnyGameDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _gameId    = gameId;
        _delegate  = [delegate retain];
        _blockName = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultAnyGame* result = [[MNWSInfoRequestResultAnyGame alloc] initWithMNWSAnyGameItem: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestAnyGameCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultAnyGame* result = [[MNWSInfoRequestResultAnyGame alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestAnyGameCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addAnyGame: _gameId] retain];
}

@end


@implementation MNWSInfoRequestResultAnyUser

-(id) initWithMNWSAnyUserItem:(MNWSAnyUserItem*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(MNWSAnyUserItem*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestAnyUser

+(id) mnWSInfoRequestAnyUserWithUserId:(MNUserId) userId andDelegate:(id<MNWSInfoRequestAnyUserDelegate>) delegate {
    return [[[MNWSInfoRequestAnyUser alloc] initWSInfoRequestAnyUserWithUserId: userId andDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestAnyUserWithUserId:(MNUserId) userId andDelegate:(id<MNWSInfoRequestAnyUserDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _userId    = userId;
        _delegate  = [delegate retain];
        _blockName = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultAnyUser* result = [[MNWSInfoRequestResultAnyUser alloc] initWithMNWSAnyUserItem: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestAnyUserCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultAnyUser* result = [[MNWSInfoRequestResultAnyUser alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestAnyUserCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addAnyUser: _userId] retain];
}

@end


@implementation MNWSInfoRequestResultAnyUserGameCookies

-(id) initWithMNWSUserGameCookieList:(NSArray*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(NSArray*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestAnyUserGameCookies

+(id) mnWSInfoRequestAnyUserGameCookiesWithUserIdList:(NSArray*) userIdList
                                           cookieKeyList:(NSArray*) cookieKeyList
                                          andDelegate:(id<MNWSInfoRequestAnyUserGameCookiesDelegate>) delegate {
    return [[[MNWSInfoRequestAnyUserGameCookies alloc] initWSInfoRequestAnyUserGameCookiesWithUserIdList: userIdList
                                                            cookieKeyList: cookieKeyList
                                                              andDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestAnyUserGameCookiesWithUserIdList:(NSArray*) userIdList
           cookieKeyList:(NSArray*) cookieKeyList
             andDelegate:(id<MNWSInfoRequestAnyUserGameCookiesDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _userIdList    = [userIdList retain];
        _cookieKeyList = [cookieKeyList retain];
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_userIdList release];
    [_cookieKeyList release];
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultAnyUserGameCookies* result = [[MNWSInfoRequestResultAnyUserGameCookies alloc] initWithMNWSUserGameCookieList: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestAnyUserGameCookiesCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultAnyUserGameCookies* result = [[MNWSInfoRequestResultAnyUserGameCookies alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestAnyUserGameCookiesCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addAnyUserGameCookies: _userIdList withKeys: _cookieKeyList] retain];
}

@end


@implementation MNWSInfoRequestResultCurrGameRoomList

-(id) initWithMNWSRoomList:(NSArray*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(NSArray*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestCurrGameRoomList

+(id) mnWSInfoRequestCurrGameRoomListWithDelegate:(id<MNWSInfoRequestCurrGameRoomListDelegate>) delegate {
    return [[[MNWSInfoRequestCurrGameRoomList alloc] initWSInfoRequestCurrGameRoomListWithDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestCurrGameRoomListWithDelegate:(id<MNWSInfoRequestCurrGameRoomListDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultCurrGameRoomList* result = [[MNWSInfoRequestResultCurrGameRoomList alloc] initWithMNWSRoomList: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestCurrGameRoomListCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultCurrGameRoomList* result = [[MNWSInfoRequestResultCurrGameRoomList alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestCurrGameRoomListCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addCurrGameRoomList] retain];
}

@end


@implementation MNWSInfoRequestResultCurrGameRoomUserList

-(id) initWithMNWSRoomUserInfoList:(NSArray*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(NSArray*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestCurrGameRoomUserList

+(id) mnWSInfoRequestCurrGameRoomUserListWithRoomSFId:(NSInteger) roomSFId
                                          andDelegate:(id<MNWSInfoRequestCurrGameRoomUserListDelegate>) delegate {
    return [[[MNWSInfoRequestCurrGameRoomUserList alloc] initWSInfoRequestCurrGameRoomUserListWithRoomSFId: roomSFId
                                                                                               andDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestCurrGameRoomUserListWithRoomSFId:(NSInteger) roomSFId
           andDelegate:(id<MNWSInfoRequestCurrGameRoomUserListDelegate>)delegate {
    self = [super init];

    if (self != nil) {
        _roomSFId      = roomSFId;
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultCurrGameRoomUserList* result = [[MNWSInfoRequestResultCurrGameRoomUserList alloc] initWithMNWSRoomUserInfoList: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestCurrGameRoomUserListCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultCurrGameRoomUserList* result = [[MNWSInfoRequestResultCurrGameRoomUserList alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestCurrGameRoomUserListCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addCurrGameRoomUserList: _roomSFId] retain];
}

@end


@implementation MNWSInfoRequestResultCurrUserBuddyList

-(id) initWithMNWSBuddyList:(NSArray*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(NSArray*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestCurrUserBuddyList

+(id) mnWSInfoRequestCurrUserBuddyListWithDelegate:(id<MNWSInfoRequestCurrUserBuddyListDelegate>) delegate {
    return [[[MNWSInfoRequestCurrUserBuddyList alloc] initWSInfoRequestCurrUserBuddyListWithDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestCurrUserBuddyListWithDelegate:(id<MNWSInfoRequestCurrUserBuddyListDelegate>)delegate {
    self = [super init];

    if (self != nil) {
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultCurrUserBuddyList* result = [[MNWSInfoRequestResultCurrUserBuddyList alloc] initWithMNWSBuddyList: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestCurrUserBuddyListCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultCurrUserBuddyList* result = [[MNWSInfoRequestResultCurrUserBuddyList alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestCurrUserBuddyListCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addCurrUserBuddyList] retain];
}

@end


@implementation MNWSInfoRequestResultCurrUserSubscriptionStatus

-(id) initWithMNWSSubscriptionStatus:(MNWSCurrUserSubscriptionStatus*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(MNWSCurrUserSubscriptionStatus*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestCurrUserSubscriptionStatus

+(id) mnWSInfoRequestCurrUserSubscriptionStatusWithDelegate:(id<MNWSInfoRequestCurrUserSubscriptionStatusDelegate>) delegate {
    return [[[MNWSInfoRequestCurrUserSubscriptionStatus alloc] initWSInfoRequestCurrUserSubscriptionStatusWithDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestCurrUserSubscriptionStatusWithDelegate:(id<MNWSInfoRequestCurrUserSubscriptionStatusDelegate>)delegate {
    self = [super init];

    if (self != nil) {
        _socNetId      = MNWSSNIdPlayPhone;
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultCurrUserSubscriptionStatus* result = [[MNWSInfoRequestResultCurrUserSubscriptionStatus alloc] initWithMNWSSubscriptionStatus: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestCurrUserSubscriptionStatusCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultCurrUserSubscriptionStatus* result = [[MNWSInfoRequestResultCurrUserSubscriptionStatus alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestCurrUserSubscriptionStatusCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addCurrUserSubscriptionStatusForSnId: _socNetId] retain];
}

@end


@implementation MNWSInfoRequestResultCurrentUserInfo

-(id) initWithMNWSCurrentUserInfo:(MNWSCurrentUserInfo*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(MNWSCurrentUserInfo*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestCurrentUserInfo

+(id) mnWSInfoRequestCurrentUserInfoWithDelegate:(id<MNWSInfoRequestCurrentUserInfoDelegate>) delegate {
    return [[[MNWSInfoRequestCurrentUserInfo alloc] initWSInfoRequestCurrentUserInfoWithDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestCurrentUserInfoWithDelegate:(id<MNWSInfoRequestCurrentUserInfoDelegate>)delegate {
    self = [super init];

    if (self != nil) {
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultCurrentUserInfo* result = [[MNWSInfoRequestResultCurrentUserInfo alloc] initWithMNWSCurrentUserInfo: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestCurrentUserInfoCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultCurrentUserInfo* result = [[MNWSInfoRequestResultCurrentUserInfo alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestCurrentUserInfoCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addCurrentUserInfo] retain];
}

@end


@implementation MNWSInfoRequestResultSessionSignedClientToken

-(id) initWithMNWSSessionSignedClientToken:(MNWSSessionSignedClientToken*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(MNWSSessionSignedClientToken*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestSessionSignedClientToken

+(id) mnWSInfoRequestSessionSignedClientTokenWithPayload:(NSString*) payload
                                             andDelegate:(id<MNWSInfoRequestSessionSignedClientTokenDelegate>) delegate {
    return [[[MNWSInfoRequestSessionSignedClientToken alloc] initWSInfoRequestSessionSignedClientTokenWithPayload: payload andDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestSessionSignedClientTokenWithPayload:(NSString*) payload
                                               andDelegate:(id<MNWSInfoRequestSessionSignedClientTokenDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _payload       = [payload retain];
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_payload release];
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultSessionSignedClientToken* result = [[MNWSInfoRequestResultSessionSignedClientToken alloc] initWithMNWSSessionSignedClientToken: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestSessionSignedClientTokenCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultSessionSignedClientToken* result = [[MNWSInfoRequestResultSessionSignedClientToken alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestSessionSignedClientTokenCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addGetSessionSignedClientToken: _payload] retain];
}

@end


@implementation MNWSInfoRequestResultSystemGameNetStats

-(id) initWithMNWSSystemGameNetStats:(MNWSSystemGameNetStats*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(MNWSSystemGameNetStats*) getDataEntry {
    return _data;
}

@end


@implementation MNWSInfoRequestSystemGameNetStats

+(id) mnWSInfoRequestSystemGameNetStatsWithDelegate:(id<MNWSInfoRequestSystemGameNetStatsDelegate>) delegate {
    return [[[MNWSInfoRequestSystemGameNetStats alloc] initWSInfoRequestSystemGameNetStatsWithDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestSystemGameNetStatsWithDelegate:(id<MNWSInfoRequestSystemGameNetStatsDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultSystemGameNetStats* result = [[MNWSInfoRequestResultSystemGameNetStats alloc] initWithMNWSSystemGameNetStats: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestSystemGameNetStatsCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultSystemGameNetStats* result = [[MNWSInfoRequestResultSystemGameNetStats alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestSystemGameNetStatsCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[content addSystemGameNetStats] retain];
}

@end

@implementation MNWSInfoRequestLeaderboardMode
-(NSString*) addContent:(MNWSRequestContent*) content {
    return nil;
}
@end

@implementation MNWSInfoRequestLeaderboardModeCurrentUser

+(id) mnWSInfoRequestLeaderboardModeCurrentUserWithScope:(NSInteger) scope andPeriod:(NSInteger) period {
    return [[[MNWSInfoRequestLeaderboardModeCurrentUser alloc] initWSInfoRequestLeaderboardModeCurrentUserWithScope:scope andPeriod: period] autorelease];
}

-(id) initWSInfoRequestLeaderboardModeCurrentUserWithScope:(NSInteger) scope andPeriod:(NSInteger) period {
    self = [super init];

    if (self != nil) {
        _scope  = scope;
        _period = period;
    }

    return self;
}

-(NSString*) addContent:(MNWSRequestContent*) content {
    return [content addCurrUserLeaderboard: _scope period: _period];
}

@end

@implementation MNWSInfoRequestLeaderboardModeAnyGameGlobal

+(id) mnWSInfoRequestLeaderboardModeAnyGameGlobalWithGameId:(NSInteger) gameId
                                                  gameSetId:(NSInteger) gameSetId
                                                  andPeriod:(NSInteger) period {
    return [[[MNWSInfoRequestLeaderboardModeAnyGameGlobal alloc] initWSInfoRequestLeaderboardModeAnyGameGlobalWithGameId:gameId gameSetId: gameSetId andPeriod: period] autorelease];
}

-(id) initWSInfoRequestLeaderboardModeAnyGameGlobalWithGameId:(NSInteger) gameId
                                                    gameSetId:(NSInteger) gameSetId
                                                    andPeriod:(NSInteger) period {
    self = [super init];

    if (self != nil) {
        _gameId    = gameId;
        _gameSetId = gameSetId;
        _period    = period;
    }

    return self;
}

-(NSString*) addContent:(MNWSRequestContent*) content {
    return [content addAnyGameLeaderboardGlobal: _gameId gameSetId: _gameSetId period: _period];
}

@end

@implementation MNWSInfoRequestLeaderboardModeAnyUserAnyGameGlobal

+(id) mnWSInfoRequestLeaderboardModeAnyUserAnyGameGlobalWithUserId:(MNUserId) userId
                                                            gameId:(NSInteger) gameId
                                                         gameSetId:(NSInteger) gameSetId
                                                         andPeriod:(NSInteger) period {
    return [[[MNWSInfoRequestLeaderboardModeAnyUserAnyGameGlobal alloc] initWSInfoRequestLeaderboardModeAnyUserAnyGameGlobalWithUserId:userId gameId:gameId gameSetId:gameSetId andPeriod: period] autorelease];
}

-(id) initWSInfoRequestLeaderboardModeAnyUserAnyGameGlobalWithUserId:(MNUserId) userId
                                                              gameId:(NSInteger) gameId
                                                           gameSetId:(NSInteger) gameSetId
                                                           andPeriod:(NSInteger) period {
    self = [super init];

    if (self != nil) {
        _userId    = userId;
        _gameId    = gameId;
        _gameSetId = gameSetId;
        _period    = period;
    }

    return self;
}

-(NSString*) addContent:(MNWSRequestContent*) content {
    return [content addAnyUserAnyGameLeaderboardGlobal: _userId gameId: _gameId gameSetId: _gameSetId period: _period];
}

@end

@implementation MNWSInfoRequestLeaderboardModeCurrUserAnyGameLocal

+(id) mnWSInfoRequestLeaderboardModeCurrUserAnyGameLocalWithGameId:(NSInteger) gameId
                                                         gameSetId:(NSInteger) gameSetId
                                                         andPeriod:(NSInteger) period {
    return [[[MNWSInfoRequestLeaderboardModeCurrUserAnyGameLocal alloc] initWSInfoRequestLeaderboardModeCurrUserAnyGameLocalWithGameId: gameId gameSetId: gameSetId andPeriod: period] autorelease];
}

-(id) initWSInfoRequestLeaderboardModeCurrUserAnyGameLocalWithGameId:(NSInteger) gameId
                                                           gameSetId:(NSInteger) gameSetId
                                                           andPeriod:(NSInteger) period {
    self = [super init];

    if (self != nil) {
        _gameId    = gameId;
        _gameSetId = gameSetId;
        _period    = period;
    }

    return self;
}

-(NSString*) addContent:(MNWSRequestContent*) content {
    return [content addCurrUserAnyGameLeaderboardLocal: _gameId gameSetId: _gameSetId period: _period];
}

@end

@implementation MNWSInfoRequestResultLeaderboard

-(id) initWithMNWSLeaderboardItemList:(NSArray*) data {
    self = [super init];

    if (self != nil) {
        _data = [data retain];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(NSArray*) getDataEntry {
    return _data;
}

@end

@implementation MNWSInfoRequestLeaderboard

+(id) mnWSInfoRequestLeaderboardWithMode:(MNWSInfoRequestLeaderboardMode*) mode
                             andDelegate:(id<MNWSInfoRequestLeaderboardDelegate>) delegate {
    return [[[MNWSInfoRequestLeaderboard alloc] initWSInfoRequestLeaderboardWithMode: mode andDelegate: delegate] autorelease];
}

-(id) initWSInfoRequestLeaderboardWithMode:(MNWSInfoRequestLeaderboardMode*) mode andDelegate:(id<MNWSInfoRequestLeaderboardDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _mode          = [mode retain];
        _delegate      = [delegate retain];
        _blockName     = nil;
    }

    return self;
}

-(void) dealloc {
    [_mode release];
    [_delegate release];
    [_blockName release];

    [super dealloc];
}

-(void) handleRequestCompleted:(MNWSResponse*) response {
    MNWSInfoRequestResultLeaderboard* result = [[MNWSInfoRequestResultLeaderboard alloc] initWithMNWSLeaderboardItemList: [response getDataForBlock: _blockName]];

    [_delegate mnWSInfoRequestLeaderboardCompleted: result];

    [result release];
}

-(void) handleRequestError:(MNWSRequestError*) error {
    MNWSInfoRequestResultLeaderboard* result = [[MNWSInfoRequestResultLeaderboard alloc] init];

    [result setError: error.message];

    [_delegate mnWSInfoRequestLeaderboardCompleted: result];

    [result release];
}

-(void) addContent:(MNWSRequestContent*) content {
    [_blockName release];
    _blockName = [[_mode addContent: content] retain];
}

@end
