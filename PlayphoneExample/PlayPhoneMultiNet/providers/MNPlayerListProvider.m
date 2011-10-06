//
//  MNPlayerListProvider.m
//  MultiNet client
//
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNTools.h"
#import "MNPlayerListProvider.h"

static NSString* MNPlayerListProviderPluginName = @"com.playphone.mn.psi";

/* NOTE: prefix is always one-letter, length is always equal to 1 */
#define MNPlayerListProviderMessagePrefixLen (1)
static NSString* MNPlayerListProviderMessagePrefixInit   = @"i";
static NSString* MNPlayerListProviderMessagePrefixModify = @"m";


@interface MNPlayerListProviderPlayerStatus : NSObject {
@private

MNUserInfo* _userInfo;
NSInteger   _userStatus;
}

@property (nonatomic,retain) MNUserInfo* userInfo;
@property (nonatomic,assign) NSInteger   userStatus;

-(id) initWithUserInfo:(MNUserInfo*) userInfo andStatus:(NSInteger) status;
-(void) dealloc;

@end

static BOOL parseUserSFIdUserStatusString (NSInteger* sfid, NSInteger* status, NSString* str) {
    BOOL    valid     = NO;
    NSRange sfidRange = [str rangeOfString: @":"];

    if (sfidRange.location != NSNotFound) {
        NSString* sfidStr   = [str substringToIndex: sfidRange.location];
        NSString* statusStr = [str substringFromIndex: sfidRange.location + sfidRange.length];

        if (MNStringScanInteger(sfid,sfidStr) && MNStringScanInteger(status,statusStr)) {
            valid = YES;
        }
    }

    return valid;
}

@implementation MNPlayerListProviderPlayerStatus

@synthesize userInfo   = _userInfo;
@synthesize userStatus = _userStatus;

-(id) initWithUserInfo:(MNUserInfo*) userInfo andStatus:(NSInteger) status {
    self = [super init];

    if (self != nil) {
        self.userInfo   = userInfo;
        self.userStatus = status;
    }

    return self;
}

-(void) dealloc {
    [_userInfo release];

    [super dealloc];
}

@end


@implementation MNPlayerListProvider

-(id) initWithSession: (MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session = session;
        _delegates = [[MNDelegateArray alloc] init];
        
        _playerStatuses = [[NSMutableDictionary alloc] init];

        [_session addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [_session removeDelegate: self];
	[_delegates release];
    [_playerStatuses release];

    [super dealloc];
}

-(NSArray*) getPlayerList {
    NSMutableArray* playerList = [NSMutableArray array];

    for (NSNumber* sfid in _playerStatuses) {
        MNPlayerListProviderPlayerStatus* playerStatus = [_playerStatuses objectForKey: sfid];

        if (playerStatus.userStatus == MN_USER_PLAYER) {
            [playerList addObject: playerStatus.userInfo];
        }
    }

    return playerList;
}

-(void) processInitMessage:(NSString*) message {
    [_playerStatuses removeAllObjects];

    NSArray* entries = [message componentsSeparatedByString: @";"];

    for (NSString* entry in entries) {
        NSInteger sfid;
        NSInteger status;

        if (parseUserSFIdUserStatusString(&sfid,&status,entry)) {
            MNUserInfo* userInfo = [_session getUserInfoBySFId: sfid];

            if (userInfo != nil) {
                MNPlayerListProviderPlayerStatus* playerStatus = [[MNPlayerListProviderPlayerStatus alloc] initWithUserInfo: userInfo andStatus: status];

                [_playerStatuses setObject: playerStatus forKey: [NSNumber numberWithInteger: sfid]];

                [playerStatus release];
            }
        }
    }
}

-(void) processModifyMessage:(NSString*) message {
    NSInteger sfid;
    NSInteger newStatus;

    if (parseUserSFIdUserStatusString(&sfid,&newStatus,message)) {
        NSNumber* sfidKey = [NSNumber numberWithInteger: sfid];

        MNPlayerListProviderPlayerStatus* playerStatus = [_playerStatuses objectForKey: sfidKey];

        if (playerStatus != nil) {
            NSInteger oldStatus = playerStatus.userStatus;

            playerStatus.userStatus = newStatus;

            if (newStatus == MN_USER_PLAYER) {
                if (oldStatus != MN_USER_PLAYER) {
					[_delegates beginCall];

					for (id<MNPlayerListProviderDelegate> delegate in _delegates) {
						if ([delegate respondsToSelector: @selector(onPlayerJoin:)]) {
							[delegate onPlayerJoin: playerStatus.userInfo];
						}
					}

					[_delegates endCall];
                }
            }
            else if (oldStatus == MN_USER_PLAYER) {
				[_delegates beginCall];

				for (id<MNPlayerListProviderDelegate> delegate in _delegates) {
					if ([delegate respondsToSelector: @selector(onPlayerLeft:)]) {
						[delegate onPlayerLeft: playerStatus.userInfo];
					}
				}

				[_delegates endCall];
            }
        }
        else {
            MNUserInfo* userInfo = [_session getUserInfoBySFId: sfid];

            if (userInfo != nil) {
                playerStatus = [[MNPlayerListProviderPlayerStatus alloc] initWithUserInfo: userInfo andStatus: newStatus];

                [_playerStatuses setObject: playerStatus forKey: [NSNumber numberWithInteger: sfid]];

                [playerStatus release];

                if (newStatus == MN_USER_PLAYER) {
					[_delegates beginCall];

					for (id<MNPlayerListProviderDelegate> delegate in _delegates) {
						if ([delegate respondsToSelector: @selector(onPlayerJoin:)]) {
							[delegate onPlayerJoin: userInfo];
						}
					}

					[_delegates endCall];
                }
            }
        }
    }
}

-(void) addDelegate:(id<MNPlayerListProviderDelegate>) delegate {
	[_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNPlayerListProviderDelegate>) delegate {
	[_delegates removeDelegate: delegate];
}

/* MNSessionDelegate protocol methods */

-(void) mnSessionRoomUserLeave:(MNUserInfo*) userInfo {
    if (userInfo.userId != [_session getMyUserId]) {
        NSNumber* sfid = [NSNumber numberWithInteger: userInfo.userSFId];
        MNPlayerListProviderPlayerStatus* playerStatus = [_playerStatuses objectForKey: sfid];

        if (playerStatus != nil) {
            playerStatus = [playerStatus retain];

            [_playerStatuses removeObjectForKey: sfid];

            if (playerStatus.userStatus == MN_USER_PLAYER) {
				[_delegates beginCall];
				
				for (id<MNPlayerListProviderDelegate> delegate in _delegates) {
					if ([delegate respondsToSelector: @selector(onPlayerLeft:)]) {
						[delegate onPlayerLeft: playerStatus.userInfo];
					}
				}

				[_delegates endCall];
            }

            [playerStatus release];
        }
    }
}

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (sender != nil) {
        return;
    }

    if (![pluginName isEqualToString: MNPlayerListProviderPluginName]) {
        return;
    }

    if      ([message hasPrefix: MNPlayerListProviderMessagePrefixInit]) {
        [self processInitMessage: [message substringFromIndex: MNPlayerListProviderMessagePrefixLen]];
    }
    else if ([message hasPrefix: MNPlayerListProviderMessagePrefixModify]) {
        [self processModifyMessage: [message substringFromIndex: MNPlayerListProviderMessagePrefixLen]];
    }
}

-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus {
    if (newStatus == MN_OFFLINE || newStatus == MN_LOGGEDIN) {
        [_playerStatuses removeAllObjects];
    }
}

@end
