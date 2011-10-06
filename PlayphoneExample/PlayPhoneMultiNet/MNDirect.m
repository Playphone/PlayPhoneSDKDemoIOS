//
//  MNDirect.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/24/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNDirect.h"
#import "MNTools.h"

#import "MNAchievementsProvider.h"
#import "MNClientRobotsProvider.h"
#import "MNGameCookiesProvider.h"
#import "MNMyHiScoresProvider.h"
#import "MNPlayerListProvider.h"
#import "MNScoreProgressProvider.h"
#import "MNVItemsProvider.h"
#import "MNVShopProvider.h"

static MNAchievementsProvider*  MNDirectAchievementsProvider  = nil;
static MNClientRobotsProvider*  MNDirectClientRobotsProvider  = nil;
static MNGameCookiesProvider*   MNDirectGameCookiesProvider   = nil;
static MNMyHiScoresProvider*    MNDirectMyHiScoresProvider    = nil;
static MNPlayerListProvider*    MNDirectPlayerListProvider    = nil;
static MNScoreProgressProvider* MNDirectScoreProgressProvider = nil;
static MNVItemsProvider*        MNDirectVItemsProvider        = nil;
static MNVShopProvider*         MNDirectVShopProvider         = nil;

@interface MNSessionDirectDelegate: NSObject<MNSessionDelegate,MNUserProfileViewDelegate> {
    @private

    MNSession* _session;
    MNGameParams* _gameParams;
    id<MNDirectDelegate> _delegate;
}

@property (nonatomic,retain) MNGameParams* gameParams;

-(id) initWithSession:(MNSession*) session andDirectDelegate:(id<MNDirectDelegate>) delegate;
-(void) dealloc;

/* MNSessionDelegate protocol */
-(void) mnSessionDoStartGameWithParams:(MNGameParams*) params;
-(void) mnSessionDoFinishGame;
-(void) mnSessionDoCancelGame;
-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus;
-(void) mnSessionGameMessageReceived:(NSString*) message from:(MNUserInfo*) sender;
-(void) mnSessionErrorOccurred:(MNErrorInfo*) error;

/* MNUserProfileViewDelegate protocol */
-(void) mnUserProfileViewDoGoBack;

@end

static MNSession* session = nil;
static MNUserProfileView* view = nil;
static MNSessionDirectDelegate* directDelegate = nil;

@implementation MNSessionDirectDelegate

@synthesize gameParams = _gameParams;

-(id) initWithSession:(MNSession*) session andDirectDelegate:(id<MNDirectDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _session  = session;
        _delegate = delegate;
    }

    return self;
}

-(void) dealloc {
    [_gameParams release];

    [super dealloc];
}

-(void) mnSessionDoStartGameWithParams:(MNGameParams*) params {
    self.gameParams = params;

    if ([_delegate respondsToSelector: @selector(mnDirectDoStartGameWithParams:)]) {
        [_delegate mnDirectDoStartGameWithParams: params];
    }
}

-(void) mnSessionDoFinishGame {
    if ([_delegate respondsToSelector: @selector(mnDirectDoFinishGame)]) {
        [_delegate mnDirectDoFinishGame];
    }
}

-(void) mnSessionDoCancelGame {
    [_session cancelPostScoreOnLogin];

    if ([_delegate respondsToSelector: @selector(mnDirectDoCancelGame)]) {
        [_delegate mnDirectDoCancelGame];
    }

    self.gameParams = nil;
}

-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus {
    if ([_delegate respondsToSelector: @selector(mnDirectSessionStatusChangedTo:)]) {
        [_delegate mnDirectSessionStatusChangedTo: newStatus];
    }
}

-(void) mnSessionGameMessageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if ([_delegate respondsToSelector: @selector(mnDirectDidReceiveGameMessage:from:)]) {
        [_delegate mnDirectDidReceiveGameMessage: message from: sender];
    }
}

-(void) mnSessionErrorOccurred:(MNErrorInfo*) error {
    if ([_delegate respondsToSelector: @selector(mnDirectErrorOccurred:)]) {
        [_delegate mnDirectErrorOccurred: error];
    }
}

-(void) mnUserProfileViewDoGoBack {
    [_session cancelPostScoreOnLogin];

    if ([_delegate respondsToSelector: @selector(mnDirectViewDoGoBack)]) {
        [_delegate mnDirectViewDoGoBack];
    }
}

@end

static void releaseProviders (void) {
    [MNDirectAchievementsProvider release]; MNDirectAchievementsProvider = nil;
    [MNDirectClientRobotsProvider release]; MNDirectClientRobotsProvider = nil;
    [MNDirectGameCookiesProvider release]; MNDirectGameCookiesProvider = nil;
    [MNDirectMyHiScoresProvider release]; MNDirectMyHiScoresProvider = nil;
    [MNDirectPlayerListProvider release]; MNDirectPlayerListProvider = nil;
    [MNDirectScoreProgressProvider release]; MNDirectScoreProgressProvider = nil;
    [MNDirectVItemsProvider release]; MNDirectVItemsProvider = nil;
    [MNDirectVShopProvider release]; MNDirectVShopProvider = nil;
}

static void initializeProviders (MNSession* session) {
    releaseProviders();

    MNDirectAchievementsProvider  = [[MNAchievementsProvider alloc] initWithSession: session];
    MNDirectClientRobotsProvider  = [[MNClientRobotsProvider alloc] initWithSession: session];
    MNDirectGameCookiesProvider   = [[MNGameCookiesProvider alloc] initWithSession: session];
    MNDirectMyHiScoresProvider    = [[MNMyHiScoresProvider alloc] initWithSession: session];
    MNDirectPlayerListProvider    = [[MNPlayerListProvider alloc] initWithSession: session];
    MNDirectScoreProgressProvider = [[MNScoreProgressProvider alloc] initWithSession: session];
    MNDirectVItemsProvider        = [[MNVItemsProvider alloc] initWithSession: session];
    MNDirectVShopProvider         = [[MNVShopProvider alloc] initWithSession: session andVItemsProvider: MNDirectVItemsProvider];
}

@implementation MNDirect

+(BOOL) prepareSessionWithGameId:(NSInteger) gameId gameSecret:(NSString*) gameSecret frame:(CGRect) frame andDelegate:(id<MNDirectDelegate>) delegate {
    [MNDirect shutdownSession];

    session = [[MNSession alloc] initWithGameId: gameId andGameSecret: gameSecret];

    if (session == nil) {
        return NO;
    }

    directDelegate = [[MNSessionDirectDelegate alloc] initWithSession: session andDirectDelegate: delegate];

    if (directDelegate == nil) {
        [session release]; session = nil;

        return NO;
    }

    initializeProviders(session);

    if ([delegate respondsToSelector: @selector(mnDirectSessionReady:)]) {
        [delegate mnDirectSessionReady: session];
    }

    view = [[MNUserProfileView alloc] initWithFrame: frame];

    if (view == nil) {
        releaseProviders();
        [directDelegate release]; directDelegate = nil;
        [session release]; session = nil;

        return NO;
    }

    [view addDelegate: directDelegate];
    [view bindToSession: session];

    [session addDelegate: directDelegate];

    return YES;
}

+(BOOL) prepareSessionWithGameId:(NSInteger) gameId gameSecret:(NSString*) gameSecret andDelegate:(id<MNDirectDelegate>) delegate {
	return [MNDirect prepareSessionWithGameId: gameId gameSecret: gameSecret frame: [UIScreen mainScreen].applicationFrame andDelegate: delegate];
}

+(NSString*) makeGameSecretByComponents:(unsigned int) secret1
                                secret2:(unsigned int) secret2
                                secret3:(unsigned int) secret3
                                secret4:(unsigned int) secret4 {
    return MNGetGameSecret(secret1,secret2,secret3,secret4);
}

+(void) shutdownSession {
    releaseProviders();

    [view release]; view = nil;
    [session release]; session = nil;
    [directDelegate release]; directDelegate = nil;
}

+(BOOL) isOnline {
    if (session != nil) {
        return [session isOnline];
    }
    else {
        return NO;
    }
}

+(BOOL) isUserLoggedIn {
    if (session != nil) {
        return [session isUserLoggedIn];
    }
    else {
        return NO;
    }
}

+(NSInteger) getSessionStatus {
    if (session != nil) {
        return [session getStatus];
    }
    else {
        return MN_OFFLINE;
    }
}

+(void) setDefaultGameSetId:(NSInteger) gameSetId {
    [session setDefaultGameSetId: gameSetId];
}

+(NSInteger) getDefaultGameSetId {
    return [session getDefaultGameSetId];
}

+(void) postGameScore:(long long) score {
    if (session != nil && directDelegate != nil) {
        if (directDelegate.gameParams == nil) {
            directDelegate.gameParams = [[[MNGameParams alloc] initWithGameSetId: [session getDefaultGameSetId]
                                                               gameSetParams: @""
                                                               scorePostLinkId: @""
                                                               gameSeed: 0
                                                               playModel: MN_PLAYMODEL_SINGLEPLAY] autorelease];
        }

        MNGameResult* gameResult = [[MNGameResult alloc] initWithGameParams: directDelegate.gameParams];

        gameResult.score = score;

        [session finishGameWithResult: gameResult];

        [gameResult release];

        directDelegate.gameParams = nil;
    }
}

+(void) postGameScorePending:(long long) score {
    if (session != nil && directDelegate != nil) {
        if (directDelegate.gameParams == nil) {
            directDelegate.gameParams = [[[MNGameParams alloc] initWithGameSetId: [session getDefaultGameSetId]
                                                               gameSetParams: @""
                                                               scorePostLinkId: @""
                                                               gameSeed: 0
                                                               playModel: MN_PLAYMODEL_SINGLEPLAY] autorelease];
        }

        MNGameResult* gameResult = [[MNGameResult alloc] initWithGameParams: directDelegate.gameParams];

        gameResult.score = score;

        [session schedulePostScoreOnLogin: gameResult];

        [gameResult release];

        directDelegate.gameParams = nil;
    }
}

+(void) cancelGame {
    if (session != nil && directDelegate != nil) {
        [session cancelPostScoreOnLogin];

        [session cancelGameWithParams: directDelegate.gameParams];

        directDelegate.gameParams = nil;
    }
}

+(void) sendAppBeacon:(NSString*) actionName beaconData:(NSString*) beaconData {
    if (session != nil) {
        [session sendAppBeacon: actionName beaconData: beaconData];
    }
}

+(void) execAppCommand:(NSString*) name withParam:(NSString*) param {
    [session execAppCommand: name withParam: param];
}

+(void) sendGameMessage:(NSString*) message {
    if (session != nil) {
        [session sendGameMessage: message];
    }
}

+(BOOL) handleOpenURL:(NSURL*) url {
    return [session handleOpenURL: url];
}

+(MNSession*) getSession {
    return session;
}

+(MNUserProfileView*) getView {
    return view;
}

+(MNAchievementsProvider*) achievementsProvider {
    return MNDirectAchievementsProvider;
}

+(MNClientRobotsProvider*)  clientRobotsProvider {
    return MNDirectClientRobotsProvider;
}

+(MNGameCookiesProvider*)   gameCookiesProvider {
    return MNDirectGameCookiesProvider;
}

+(MNMyHiScoresProvider*)    myHiScoresProvider {
    return MNDirectMyHiScoresProvider;
}

+(MNPlayerListProvider*)    playerListProvider {
    return MNDirectPlayerListProvider;
}

+(MNScoreProgressProvider*) scoreProgressProvider {
    return MNDirectScoreProgressProvider;
}

+(MNVItemsProvider*) vItemsProvider {
    return MNDirectVItemsProvider;
}

+(MNVShopProvider*) vShopProvider {
    return MNDirectVShopProvider;
}

@end
