//
//  MNWSRequest.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import "limits.h"
#import "TouchXML.h"

#import "MNTools.h"
#import "MNWSXmlTools.h"
#import "MNWSRequest.h"

#import "MNWSBuddyListItem.h"
#import "MNWSLeaderboardListItem.h"
#import "MNWSAnyGameItem.h"
#import "MNWSAnyUserItem.h"
#import "MNWSCurrUserSubscriptionStatus.h"
#import "MNWSCurrentUserInfo.h"
#import "MNWSRoomListItem.h"
#import "MNWSRoomUserInfoItem.h"

#define MNWSSNIdPlayPhone (4)

static NSString* MNWSURLPath = @"user_ajax_host.php";

@protocol MNWSXmlDataParser<NSObject>
-(id) parseElement:(CXMLElement*) element;
@end


@interface MNWSRequestError()
+(id) mnWSErrorWithDomain:(int) domain andMessage:(NSString*) message;
-(id) initMNWSErrorWithDomain:(int) domain andMessage:(NSString*) message;
@end


@interface MNWSResponse()
-(void) addBlock:(NSString*) name withData:(id) data;
@end


@interface MNWSRequest()
-(id) initWithMNWSRequestDelegate:(id<MNWSRequestDelegate>) delegate parsers:(NSDictionary*) parsers andMapping:(NSDictionary*) mapping;
-(void) sendRequestToUrl:(NSURL*) url withPostData:(NSDictionary*) postData;
-(void) handleXmlResponse:(NSData*) data;
@end


@interface MNWSRequestSender()
-(void) setupStdParsers;
-(MNWSRequest*) sendWSRequest:(MNWSRequestContent*) requestContent authorized:(BOOL) authorized withDelegate:(id<MNWSRequestDelegate>) delegate;
@end

@interface MNWSRequestContent()
-(NSString*) addInfoBlock:(NSString*) blockName withParam:(NSString*) param;
-(NSString*) addInfoBlock:(NSString*) blockName withParam1:(NSString*) param1 andParam2:(NSString*) param2;
-(NSString*) addInfoBlock:(NSString*) blockName withParam1:(NSString*) param1 param2:(NSString*) param2 andParam3:(NSString*) param3;
@end


@interface MNWSXmlGenericParser : NSObject<MNWSXmlDataParser>
{
@private

    Class _dataClass;
}

+(id) MNWSXmlGenericParserWithDataClass:(Class) dataClass;
-(id) initWithDataClass:(Class) dataClass;
-(id) parseElement:(CXMLElement*) element;

@end


@interface MNWSXmlGenericItemListParser : NSObject<MNWSXmlDataParser>
{
@private

    NSString*             _itemTagName;
    id<MNWSXmlDataParser> _itemParser;
}

+(id) MNWSXmlGenericItemListParserWithItemTagName:(NSString*) itemTagName andItemParser:(id<MNWSXmlDataParser>) itemParser;
-(id) initWithItemTagName:(NSString*) itemTagName andItemParser:(id<MNWSXmlDataParser>) itemParser;
-(id) parseElement:(CXMLElement*) element;

@end


@implementation MNWSRequestError

@synthesize domain  = _domain;
@synthesize message = _message;

+(id) mnWSErrorWithDomain:(int) domain andMessage:(NSString*) message {
    return [[[MNWSRequestError alloc] initMNWSErrorWithDomain: domain andMessage: message] autorelease];
}

-(id) initMNWSErrorWithDomain:(int) domain andMessage:(NSString*) message {
    self = [super init];

    if (self != nil) {
        _domain  = domain;
        _message = [message retain];
    }

    return self;
}

-(void) dealloc {
    [_message release];

    [super dealloc];
}

@end


@implementation MNWSResponse

-(id) init {
    self = [super init];

    if (self != nil) {
        blocks = [[NSMutableDictionary alloc] init];
    }

    return self;
}

-(void) dealloc {
    [blocks release];

    [super dealloc];
}
-(id) getDataForBlock:(NSString*) blockName {
    return [blocks objectForKey: blockName];
}

-(void) addBlock:(NSString*) name withData:(id) data {
    [blocks setObject: data forKey: name];
}

@end


@implementation MNWSRequest

-(id) initWithMNWSRequestDelegate:(id<MNWSRequestDelegate>) delegate parsers:(NSDictionary*) parsers andMapping:(NSDictionary*) mapping {
    self = [super init];

    if (self != nil) {
        _downloader = nil;
        _delegate   = [delegate retain];
        _parsers    = [parsers retain];
        _mapping    = [mapping retain];
    }

    [self retain]; // to prevent object deallocation before cancel, downloader:dataReady: or downloader:didFailWithError: call
                   // these calls will send autorelease message to deallocate request object

    return self;
}

-(void) dealloc {
    [_downloader release];
    [_delegate release];
    [_parsers release];
    [_mapping release];

    [super dealloc];
}

-(void) cancel {
    [_downloader cancel];

    [self autorelease];
}

-(void) sendRequestToUrl:(NSURL*) url withPostData:(NSDictionary*) postData {
    _downloader = [[MNURLDownloader alloc] init];

    [_downloader loadRequest: MNGetURLRequestWithPostMethod(url,postData) delegate: self];
}

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    [self handleXmlResponse: data];

    [self autorelease];
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    if ([_delegate respondsToSelector: @selector(wsRequestDidFailWithError:)]) {
        [_delegate wsRequestDidFailWithError: [MNWSRequestError mnWSErrorWithDomain: MNWS_ERROR_DOMAIN_TRANSPORT_ERROR andMessage: error.message]];
    }

    [self autorelease];
}

-(void) handleXmlResponse:(NSData*) data {
    NSError *error;
    CXMLDocument *document;

    document = [[CXMLDocument alloc] initWithData: data options: 0 error: &error];

    CXMLNode* rootElement = [document rootElement];

    if ([[rootElement name] isEqualToString: @"responseData"]) {
        CXMLNode* node = MNWSXmlNodeGetFirstChildElement(rootElement);

        if ([[node name] isEqualToString: @"errorMessage"]) {
            if ([_delegate respondsToSelector: @selector(wsRequestDidFailWithError:)]) {
                [_delegate wsRequestDidFailWithError: [MNWSRequestError mnWSErrorWithDomain: MNWS_ERROR_DOMAIN_SERVER_ERROR andMessage: [node stringValue]]];
            }
        }
        else {
            MNWSResponse* response = [[MNWSResponse alloc] init];

            while (node != nil) {
                NSString* tagName    = [node name];
                NSString* mappedName = [_mapping objectForKey: tagName];

                id<MNWSXmlDataParser> parser = [_parsers objectForKey: (mappedName != nil ? mappedName : tagName)];

                if (parser != nil) {
                    [response addBlock: tagName withData: [parser parseElement: (CXMLElement*) node]];
                }
                else {
                    [response addBlock: tagName withData: node];
                }

                node = MNWSXmlNodeGetNextSiblingElement(node);
            }

            if ([_delegate respondsToSelector: @selector(wsRequestDidSucceed:)]) {
                [_delegate wsRequestDidSucceed: response];
            }

            [response release];
        }
    }
    else {
        if ([_delegate respondsToSelector: @selector(wsRequestDidFailWithError:)]) {
            [_delegate wsRequestDidFailWithError: [MNWSRequestError mnWSErrorWithDomain: MNWS_ERROR_DOMAIN_PARSE_ERROR andMessage: @"document element's tag must be \"responseData\""]];
        }
    }

    [document release];
}

@end


static NSString* getPeriodNameByCode (NSInteger period) {
    if (period == MNWS_LEADERBOARD_PERIOD_THIS_WEEK) {
        return @"ThisWeek";
    }
    else if (period == MNWS_LEADERBOARD_PERIOD_THIS_MONTH) {
        return @"ThisMonth";
    }
    else {
        return @"AllTime";
    }
}

static NSString* getScopeNameByCode (NSInteger scope) {
    if (scope == MNWS_LEADERBOARD_SCOPE_LOCAL) {
        return @"Local";
    }
    else {
        return @"Global";
    }
}

@implementation MNWSRequestContent

@synthesize content;
@synthesize mapping;

-(id) init {
    self = [super init];

    if (self != nil) {
        content = [[NSMutableString alloc] init];
        mapping = nil;
    }

    return self;
}

-(void) dealloc {
    [content release];
    [mapping release];

    [super dealloc];
}

-(NSString*) addInfoBlock:(NSString*) infoBlockSelector {
    if ([content length] > 0) {
        [content appendString: @","];
    }

    [content appendString: infoBlockSelector];

    return infoBlockSelector;
}

-(NSString*) addInfoBlock:(NSString*) blockName withParam:(NSString*) param {
    [self addInfoBlock: [NSString stringWithFormat: @"%@:%@",blockName,param]];

    return blockName;
}

-(NSString*) addInfoBlock:(NSString*) blockName withParam1:(NSString*) param1 andParam2:(NSString*) param2 {
    [self addInfoBlock: [NSString stringWithFormat: @"%@:%@:%@",blockName,param1,param2]];

    return blockName;
}

-(NSString*) addInfoBlock:(NSString*) blockName withParam1:(NSString*) param1 param2:(NSString*) param2 andParam3:(NSString*) param3 {
    [self addInfoBlock: [NSString stringWithFormat: @"%@:%@:%@:%@",blockName,param1,param2,param3]];

    return blockName;
}

-(NSString*) addCurrentUserInfo {
    return [self addInfoBlock: @"currentUser"];
}

-(NSString*) addCurrUserBuddyList {
    return [self addInfoBlock: @"currentUserBuddyList"];
}

-(NSString*) addCurrGameRoomList {
    return [self addInfoBlock: @"currentGameRoomList"];
}

-(NSString*) addCurrGameRoomUserList:(NSInteger) roomSFId {
    return [self addInfoBlock: @"currentGameRoomUserList" withParam: [NSString stringWithFormat: @"%d",roomSFId]];
}

-(NSString*) addAnyUser:(MNUserId) userId {
    return [self addInfoBlock: @"anyUser" withParam: [NSString stringWithFormat: @"%llu",userId]];
}

-(NSString*) addAnyGame:(NSInteger) gameId {
    return [self addInfoBlock: @"anyGame" withParam: [NSString stringWithFormat: @"%d",gameId]];
}

-(NSString*) addCurrUserLeaderboard:(NSInteger) scope period:(NSInteger) period {
    return [self addInfoBlock: [NSString stringWithFormat: @"currentUserLeaderboard%@%@",getScopeNameByCode(scope),getPeriodNameByCode(period)]];
}

-(NSString*) addAnyGameLeaderboardGlobal:(NSInteger) gameId gameSetId:(NSInteger) gameSetId period:(NSInteger) period {
    return [self addInfoBlock: [NSString stringWithFormat: @"anyGameLeaderboardGlobal%@",getPeriodNameByCode(period)]
                   withParam1: [NSString stringWithFormat: @"%d",gameId]
                    andParam2: [NSString stringWithFormat: @"%d",gameSetId]];
}

-(NSString*) addAnyUserAnyGameLeaderboardGlobal:(MNUserId) userId gameId:(NSInteger) gameId gameSetId:(NSInteger) gameSetId period:(NSInteger) period {
    return [self addInfoBlock: [NSString stringWithFormat: @"anyUserAnyGameLeaderboardGlobal%@",getPeriodNameByCode(period)]
                   withParam1: [NSString stringWithFormat: @"%llu",userId]
                       param2: [NSString stringWithFormat: @"%d",gameId]
                    andParam3: [NSString stringWithFormat: @"%d",gameSetId]];
}

-(NSString*) addCurrUserAnyGameLeaderboardLocal:(NSInteger) gameId gameSetId:(NSInteger) gameSetId period:(NSInteger) period {
    return [self addInfoBlock: [NSString stringWithFormat: @"currentUserAnyGameLeaderboardGlobal%@",getPeriodNameByCode(period)]
                   withParam1: [NSString stringWithFormat: @"%d",gameId]
                    andParam2: [NSString stringWithFormat: @"%d",gameSetId]];
}

-(NSString*) addCurrUserSubscriptionStatusForSnId:(NSInteger) snId {
    return [self addInfoBlock: @"currentUserSubscriptionStatus" withParam: [NSString stringWithFormat: @"%d",snId]];
}

-(NSString*) addCurrUserSubscriptionStatusPlayPhone {
    return [self addCurrUserSubscriptionStatusForSnId: MNWSSNIdPlayPhone];
}

-(void) addNameMappingForBlockName:(NSString*) blockName toParserName:(NSString*) parserName {
    if (mapping == nil) {
        mapping = [[NSMutableDictionary alloc] init];
    }

    [mapping setObject: parserName forKey: blockName];
}

@end


@implementation MNWSRequestSender

-(id) initWithSession:(MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session = [session retain];
        _parsers = [[NSMutableDictionary alloc] init];
        _altRequestPath = nil;

        [self setupStdParsers];
    }

    return self;
}

-(void) dealloc {
    [_parsers release];
    [_session release];
    [_altRequestPath release];

    [super dealloc];
}

-(NSString*) requestPath {
    return _altRequestPath != nil ? _altRequestPath : MNWSURLPath;
}

-(void) setRequestPath:(NSString*) requestPath {
    [_altRequestPath release];
    _altRequestPath = [requestPath copy];
}

-(void) setupStdParsers {
    MNWSXmlGenericItemListParser* buddyListParser =
     [MNWSXmlGenericItemListParser MNWSXmlGenericItemListParserWithItemTagName: @"buddyItem"
                                                                 andItemParser: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSBuddyListItem class]]];
    MNWSXmlGenericItemListParser* leaderBoardListParser =
    [MNWSXmlGenericItemListParser MNWSXmlGenericItemListParserWithItemTagName: @"leaderboardItem"
                                                                andItemParser: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSLeaderboardListItem class]]];

    [_parsers setObject: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSCurrentUserInfo class]] forKey: @"currentUser"];
    [_parsers setObject: buddyListParser forKey: @"currentUserBuddyList"];
    [_parsers setObject: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSAnyUserItem class]] forKey: @"anyUser"];
    [_parsers setObject: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSAnyGameItem class]] forKey: @"anyGame"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserLeaderboardGlobalThisWeek"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserLeaderboardGlobalThisMonth"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserLeaderboardGlobalAllTime"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserLeaderboardLocalThisWeek"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserLeaderboardLocalThisMonth"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserLeaderboardLocalAllTime"];
    [_parsers setObject: leaderBoardListParser forKey: @"anyGameLeaderboardGlobalThisWeek"];
    [_parsers setObject: leaderBoardListParser forKey: @"anyGameLeaderboardGlobalThisMonth"];
    [_parsers setObject: leaderBoardListParser forKey: @"anyGameLeaderboardGlobalAllTime"];
    [_parsers setObject: leaderBoardListParser forKey: @"anyUserAnyGameLeaderboardGlobalThisWeek"];
    [_parsers setObject: leaderBoardListParser forKey: @"anyUserAnyGameLeaderboardGlobalThisMonth"];
    [_parsers setObject: leaderBoardListParser forKey: @"anyUserAnyGameLeaderboardGlobalAllTime"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserAnyGameLeaderboardLocalThisWeek"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserAnyGameLeaderboardLocalThisMonth"];
    [_parsers setObject: leaderBoardListParser forKey: @"currentUserAnyGameLeaderboardLocalAllTime"];
    [_parsers setObject: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSCurrUserSubscriptionStatus class]] forKey: @"currentUserSubscriptionStatus"];
    [_parsers setObject: [MNWSXmlGenericItemListParser MNWSXmlGenericItemListParserWithItemTagName: @"roomInfoItem"
                                                                                     andItemParser: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSRoomListItem class]]]
                 forKey: @"currentGameRoomList"];
    [_parsers setObject: [MNWSXmlGenericItemListParser MNWSXmlGenericItemListParserWithItemTagName: @"roomUserInfoItem"
                                                                                     andItemParser: [MNWSXmlGenericParser MNWSXmlGenericParserWithDataClass: [MNWSRoomUserInfoItem class]]]
                 forKey: @"currentGameRoomUserList"];
}

-(MNWSRequest*) sendWSRequest:(MNWSRequestContent*) requestContent withDelegate:(id<MNWSRequestDelegate>) delegate {
    return [self sendWSRequest: requestContent authorized: NO withDelegate: delegate];
}

-(MNWSRequest*) sendWSRequestAuthorized:(MNWSRequestContent*) requestContent withDelegate:(id<MNWSRequestDelegate>) delegate {
    return [self sendWSRequest: requestContent authorized: YES withDelegate: delegate];
}

-(MNWSRequest*) sendWSRequest:(MNWSRequestContent*) requestContent authorized:(BOOL) authorized withDelegate:(id<MNWSRequestDelegate>) delegate {
    NSString* webServerUrl = [_session getWebServerURL];
    NSString* userSId      = [_session getMySId];

    if (webServerUrl == nil) {
        if ([delegate respondsToSelector: @selector(wsRequestDidFailWithError:)]) {
            [delegate wsRequestDidFailWithError: [MNWSRequestError mnWSErrorWithDomain: MNWS_ERROR_DOMAIN_TRANSPORT_ERROR
                                                                            andMessage: @"request cannot be sent (server url is undefined)"]];
        }

        return nil;
    }

    if (authorized && (![_session isOnline] || userSId == nil)) {
        if ([delegate respondsToSelector: @selector(wsRequestDidFailWithError:)]) {
            [delegate wsRequestDidFailWithError: [MNWSRequestError mnWSErrorWithDomain: MNWS_ERROR_DOMAIN_PARAMETERS_ERROR
                                                                            andMessage: @"authorized request cannot be sent if user is not logged in"]];
        }

        return nil;
    }

    NSMutableDictionary* postData = [[NSMutableDictionary alloc] init];

    [postData setObject: [NSString stringWithFormat: @"%d",[_session getGameId]] forKey: @"ctx_game_id"];
    [postData setObject: [NSString stringWithFormat: @"%d",[_session getDefaultGameSetId]] forKey: @"ctx_gameset_id"];
    [postData setObject: [NSString stringWithFormat: @"%d", MNDeviceTypeiPhoneiPod] forKey: @"ctx_dev_type"];
    [postData setObject: MNGetDeviceIdMD5() forKey: @"ctx_dev_id"];

    if (authorized) {
        [postData setObject: [NSString stringWithFormat: @"%lld",[_session getMyUserId]] forKey: @"ctx_user_id"];
        [postData setObject: userSId forKey: @"ctx_user_sid"];
    }

    [postData setObject: requestContent.content forKey: @"info_list"];

    MNWSRequest* request = [[[MNWSRequest alloc] initWithMNWSRequestDelegate: delegate parsers: _parsers andMapping: requestContent.mapping] autorelease];
    NSMutableString* urlString = [[NSMutableString alloc] initWithString: webServerUrl];

    [urlString appendString: @"/"];
    [urlString appendString: self.requestPath];

    [request sendRequestToUrl: [NSURL URLWithString: urlString] withPostData: postData];

    [urlString release];
    [postData release];

    return request;
}

@end


@implementation  MNWSXmlGenericParser

+(id) MNWSXmlGenericParserWithDataClass:(Class) dataClass {
    return [[[MNWSXmlGenericParser alloc] initWithDataClass: dataClass] autorelease];
}

-(id) initWithDataClass:(Class) dataClass {
    self = [super init];

    if (self != nil) {
        _dataClass = [dataClass retain];
    }

    return self;
}

-(void) dealloc {
    [_dataClass release];

    [super dealloc];
}

-(id) parseElement:(CXMLElement*) element {
    MNWSGenericItem* item;

    if (_dataClass != nil) {
        item = [[[_dataClass alloc] init] autorelease];
    }
    else {
        item = [[[MNWSGenericItem alloc] init] autorelease];
    }

    element = MNWSXmlNodeGetFirstChildElement(element);

    while (element != nil) {
        NSString* value = [element stringValue];

        if (value != nil) {
            [item putValue: value name: [element name]];
        }

        element = MNWSXmlNodeGetNextSiblingElement(element);
    }

    return item;
}

@end


@implementation MNWSGenericItem

-(id) init {
    self = [super init];

    if (self != nil) {
        _data = [[NSMutableDictionary alloc] init];
    }

    return self;
}

-(void) dealloc {
    [_data release];

    [super dealloc];
}

-(NSString*) getValueByName:(NSString*) name {
    return [_data objectForKey: name];
}

-(void) putValue:(NSString*) value name:(NSString*) name {
    if (value != nil) {
        [_data setObject: value forKey: name];
    }
}

-(NSNumber*) getIntegerValue:(NSString*) name {
    NSString* strValue = [_data objectForKey: name];

    if (strValue != nil) {
        NSInteger value;

        if (MNStringScanInteger(&value,strValue)) {
            return [NSNumber numberWithInteger: value];
        }
    }

    return nil;
}

-(NSNumber*) getUnsignedIntegerValue:(NSString*) name {
    NSString* strValue = [_data objectForKey: name];
    
    if (strValue != nil) {
        long long value;

        if (MNStringScanLongLong(&value,strValue)) {
            if (value >= 0 && value <= UINT_MAX) { //it's correct as long as sizeof(long long) > sizeof (unsigned)
                return [NSNumber numberWithUnsignedInt: (unsigned int)value];
            }
        }
    }

    return nil;
}

-(NSNumber*) getLongLongValue:(NSString*) name {
    NSString* strValue = [_data objectForKey: name];

    if (strValue != nil) {
        long long value;

        if (MNStringScanLongLong(&value,strValue)) {
            return [NSNumber numberWithLongLong: value];
        }
    }

    return nil;
}

-(NSNumber*) getBooleanValue:(NSString*) name {
    NSString* strValue = [_data objectForKey: name];

    if ([strValue isEqualToString: @"true"]) {
        return [NSNumber numberWithBool: YES];
    }
    else if ([strValue isEqualToString: @"false"]) {
        return [NSNumber numberWithBool: NO];
    }
    else {
        return nil;
    }
}

@end


@implementation MNWSXmlGenericItemListParser

+(id) MNWSXmlGenericItemListParserWithItemTagName:(NSString*) itemTagName andItemParser:(id<MNWSXmlDataParser>) itemParser {
    return [[[MNWSXmlGenericItemListParser alloc] initWithItemTagName: itemTagName andItemParser: itemParser] autorelease];
}

-(id) initWithItemTagName:(NSString*) itemTagName andItemParser:(id<MNWSXmlDataParser>) itemParser {
    self = [super init];

    if (self != nil) {
        _itemTagName = [itemTagName retain];
        _itemParser  = [itemParser retain];
    }

    return self;
}

-(void) dealloc {
    [_itemTagName release];
    [_itemParser release];

    [super dealloc];
}

-(id) parseElement:(CXMLElement*) element {
    NSMutableArray* list = [NSMutableArray array];

    element = MNWSXmlNodeGetFirstChildElement(element);

    while (element != nil) {
        if ([[element name] isEqualToString: _itemTagName]) {
            [list addObject: [_itemParser parseElement: element]];
        }

        element = MNWSXmlNodeGetNextSiblingElement(element);
    }

    return list;
}

@end
