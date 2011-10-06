//
//  MNWSRequest.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNURLDownloader.h"

#define MNWS_ERROR_DOMAIN_TRANSPORT_ERROR  (0)
#define MNWS_ERROR_DOMAIN_SERVER_ERROR     (1)
#define MNWS_ERROR_DOMAIN_PARSE_ERROR      (2)
#define MNWS_ERROR_DOMAIN_PARAMETERS_ERROR (3)

#define MNWS_LEADERBOARD_PERIOD_ALL_TIME   (0)
#define MNWS_LEADERBOARD_PERIOD_THIS_WEEK  (1)
#define MNWS_LEADERBOARD_PERIOD_THIS_MONTH (2)

#define MNWS_LEADERBOARD_SCOPE_GLOBAL (0)
#define MNWS_LEADERBOARD_SCOPE_LOCAL  (1)

@interface MNWSRequestError : NSObject
{
@private

    int       _domain;
    NSString* _message;
}

@property (nonatomic,assign) int       domain;
@property (nonatomic,retain) NSString* message;

@end


@interface MNWSGenericItem : NSObject
{
@private

    NSMutableDictionary* _data;
}

-(NSString*) getValueByName:(NSString*) name;
-(void) putValue:(NSString*) value name:(NSString*) name;

-(NSNumber*) getIntegerValue:(NSString*) name;
-(NSNumber*) getUnsignedIntegerValue:(NSString*) name;
-(NSNumber*) getLongLongValue:(NSString*) name;
-(NSNumber*) getBooleanValue:(NSString*) name;

@end


@interface MNWSResponse : NSObject
{
@private

    NSMutableDictionary* blocks;
}

-(id) getDataForBlock:(NSString*) blockName;

@end


@protocol MNWSRequestDelegate<NSObject>
@optional

-(void) wsRequestDidSucceed:(MNWSResponse*) response;
-(void) wsRequestDidFailWithError:(MNWSRequestError*) error;

@end


@interface MNWSRequest : NSObject<MNURLDownloaderDelegate>
{
@private

    MNURLDownloader*        _downloader;
    NSDictionary*           _parsers;
    NSDictionary*           _mapping;
    id<MNWSRequestDelegate> _delegate;
}

-(void) cancel;

@end


@interface MNWSRequestContent : NSObject
{
@private

    NSMutableString*     content;
    NSMutableDictionary* mapping;
}

@property (nonatomic,readonly) NSString*            content;
@property (nonatomic,readonly) NSMutableDictionary* mapping;

-(NSString*) addInfoBlock:(NSString*) infoBlockSelector;
-(NSString*) addCurrentUserInfo;
-(NSString*) addCurrUserBuddyList;
-(NSString*) addCurrGameRoomList;
-(NSString*) addCurrGameRoomUserList:(NSInteger) roomSFId;
-(NSString*) addAnyUser:(MNUserId) userId;
-(NSString*) addAnyGame:(NSInteger) gameId;
-(NSString*) addCurrUserLeaderboard:(NSInteger) scope period:(NSInteger) period;
-(NSString*) addAnyGameLeaderboardGlobal:(NSInteger) gameId gameSetId:(NSInteger) gameSetId period:(NSInteger) period;
-(NSString*) addAnyUserAnyGameLeaderboardGlobal:(MNUserId) userId gameId:(NSInteger) gameId gameSetId:(NSInteger) gameSetId period:(NSInteger) period;
-(NSString*) addCurrUserAnyGameLeaderboardLocal:(NSInteger) gameId gameSetId:(NSInteger) gameSetId period:(NSInteger) period;
-(NSString*) addCurrUserSubscriptionStatusPlayPhone;

-(void) addNameMappingForBlockName:(NSString*) blockName toParserName:(NSString*) parserName;

@end


@interface MNWSRequestSender : NSObject {
@private

    MNSession*           _session;
    NSMutableDictionary* _parsers;
    NSString*            _altRequestPath;
}

@property (nonatomic,retain) NSString* requestPath;

-(id) initWithSession:(MNSession*) session;
-(MNWSRequest*) sendWSRequest:(MNWSRequestContent*) requestContent withDelegate:(id<MNWSRequestDelegate>) delegate;
-(MNWSRequest*) sendWSRequestAuthorized:(MNWSRequestContent*) requestContent withDelegate:(id<MNWSRequestDelegate>) delegate;

@end
