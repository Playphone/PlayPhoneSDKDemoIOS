//
//  MNBuddyListRequest.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/28/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNURLDownloader.h"


@interface MNBuddyListEntry : NSObject
{
@private

    NSDictionary* _attrs;
}

@property (readonly) NSDictionary* attributes;

@property (readonly) MNUserId   userId;
@property (readonly) NSString*  nickName;
@property (readonly) NSString*  socNetIdList;
@property (readonly) NSString*  socNetUserIdList;
@property (readonly) NSInteger  inGameId; // -1 if user is offline
@property (readonly) NSString*  inGameName;
@property (readonly) NSString*  inGameIconUrl;
@property (readonly) BOOL       hasCurrentGame;
@property (readonly) NSString*  localeCode;
@property (readonly) NSString*  avatarUrl;
@property (readonly) BOOL       isOnline;
@property (readonly) NSInteger  userSFId;
@property (readonly) NSInteger  primarySocNetId;
@property (readonly) long long  primarySocNetUserId;
@property (readonly) NSUInteger flags;
@property (readonly) BOOL       isIgnored;
@property (readonly) NSInteger  inRoomId;
@property (readonly) BOOL       isInLobbyRoom;
@property (readonly) NSString*  currGameAchievementsList;

-(id) initWithAttributes:(NSDictionary*) attrs;

@end


@interface MNBuddyListResponse : NSObject
{
@private

    NSArray* _buddies;
}

@property (readonly) NSArray* buddies;

-(id) initWithBuddyArray:(NSArray*) buddies;

@end


@class MNBuddyListRequest;

@protocol MNBuddyListRequestDelegate<NSObject>
-(void) mnBuddyListRequest:(MNBuddyListRequest*) request didSucceedWithResponse:(MNBuddyListResponse*) response;
-(void) mnBuddyListRequest:(MNBuddyListRequest*) request didFailWithError:(NSString*) error;
@end


@interface MNBuddyListRequest : NSObject<MNURLDownloaderDelegate> {
@private

    MNSession* _session;
    MNURLDownloader* _downloader;
    id<MNBuddyListRequestDelegate> _delegate;
}

-(id)   initWithSession:(MNSession*) session;
-(BOOL) sendWithDelegate:(id<MNBuddyListRequestDelegate>) delegate;
-(void) cancel;

@end
