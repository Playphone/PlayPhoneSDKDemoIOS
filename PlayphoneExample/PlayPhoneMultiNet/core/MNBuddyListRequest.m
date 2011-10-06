//
//  MNBuddyListRequest.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/28/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "TouchXML.h"

#import "MNTools.h"
#import "MNBuddyListRequest.h"

static NSInteger getIntegerFromDict (NSDictionary* dict, NSString* key, NSInteger defValue) {
    NSString* val = [dict objectForKey: key];

    if (val != nil) {
        NSInteger intVal;

        if (MNStringScanInteger(&intVal,val)) {
            return intVal;
        }
    }

    return defValue;
}

static long long getLongLongFromDict (NSDictionary* dict, NSString* key, long long defValue) {
    NSString* val = [dict objectForKey: key];

    if (val != nil) {
        long long longLongVal;

        if (MNStringScanLongLong(&longLongVal,val)) {
            return longLongVal;
        }
    }

    return defValue;
}

static BOOL getBoolFromDict (NSDictionary* dict, NSString* key, BOOL defValue) {
    NSString* val = [dict objectForKey: key];

    if (val != nil) {
        if ([val isEqualToString: @"true"]) {
            return YES;
        }
        else if ([val isEqualToString: @"false"]) {
            return NO;
        }
    }

    return defValue;
}

@implementation MNBuddyListEntry

@synthesize attributes = _attrs;

-(id) initWithAttributes:(NSDictionary*) attrs {
    self = [super init];

    if (self != nil) {
        _attrs = [attrs retain];
    }

    return self;
}

-(void) dealloc {
    [_attrs release];

    [super dealloc];
}

-(MNUserId) userId {
    return getLongLongFromDict(_attrs,@"friend_user_id",MNUserIdUndefined);
}

-(NSString*) nickName {
    return [_attrs objectForKey: @"friend_user_nick_name"];
}

-(NSString*) socNetIdList {
    return [_attrs objectForKey: @"friend_sn_id_list"];
}

-(NSString*) socNetUserIdList {
    return [_attrs objectForKey: @"friend_sn_user_asnid_list"];
}

-(NSInteger) inGameId {
    return getIntegerFromDict(_attrs,@"friend_in_game_id",-1);
}

-(NSString*) inGameName {
    return [_attrs objectForKey: @"friend_in_game_name"];
}

-(NSString*) inGameIconUrl {
    return [_attrs objectForKey: @"friend_in_game_icon_url"];
}

-(BOOL) hasCurrentGame {
    return getBoolFromDict(_attrs,@"friend_has_current_game",NO);
}

-(NSString*) localeCode {
    return [_attrs objectForKey: @"friend_user_locale"];
}

-(NSString*) avatarUrl {
    return [_attrs objectForKey: @"friend_user_avatar_url"];
}

-(BOOL) isOnline {
    return getBoolFromDict(_attrs,@"friend_user_online_now",NO);
}

-(NSInteger) userSFId {
    return getIntegerFromDict(_attrs,@"friend_user_sfid",MNSmartFoxUserIdUndefined);
}

-(NSInteger) primarySocNetId {
    return getIntegerFromDict(_attrs,@"friend_sn_id",-1);
}

-(long long) primarySocNetUserId {
    return getLongLongFromDict(_attrs,@"friend_sn_user_asnid",-1);
}

-(NSUInteger) flags {
    return (NSUInteger)getLongLongFromDict(_attrs,@"friend_flags",0);
}

-(BOOL) isIgnored {
    return getBoolFromDict(_attrs,@"friend_is_ignored",NO);
}

-(NSInteger) inRoomId {
    return getIntegerFromDict(_attrs,@"friend_in_room_sfid",-1);
}

-(BOOL) isInLobbyRoom {
    return getBoolFromDict(_attrs,@"friend_in_room_is_lobby",NO);
}

-(NSString*) currGameAchievementsList {
    return [_attrs objectForKey: @"friend_curr_game_achievemenets_list"];
}

@end


@implementation MNBuddyListResponse

@synthesize buddies = _buddies;

-(id) initWithBuddyArray:(NSArray*) buddies {
    self = [super init];

    if (self != nil) {
        _buddies = [buddies retain];
    }

    return self;
}

-(void) dealloc {
    [_buddies release];

    [super dealloc];
}

@end


@implementation MNBuddyListRequest

-(id) initWithSession:(MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session    = [session retain];
        _downloader = nil;
        _delegate   = nil;
    }

    return self;
}

-(void) dealloc {
    [_downloader release];
    [_delegate release];
    [_session release];

    [super dealloc];
}

-(BOOL) sendWithDelegate:(id<MNBuddyListRequestDelegate>) delegate {
    if (_downloader != nil) {
        return NO; // in progress
    }

    NSString*     webServiceUrlString = [NSString stringWithFormat: @"%@/user_ajax_host.php",[_session getWebServerURL]];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat: @"%d",[_session getGameId]],
                            @"ctx_game_id",
                            [NSString stringWithFormat: @"%lld",[_session getMyUserId]],
                            @"ctx_user_id",
                            [_session getMySId],
                            @"ctx_user_sid",
                            MNGetDeviceIdMD5(),
                            @"ctx_dev_id",
                            [NSString stringWithFormat: @"%d", MNDeviceTypeiPhoneiPod],
                            @"ctx_dev_type",
                            @"currentUserBuddyList",
                            @"info_list",
                            nil];

    NSURLRequest* request = MNGetURLRequestWithPostMethod([NSURL URLWithString: webServiceUrlString],params);

    _delegate = [delegate retain];
    _downloader = [[MNURLDownloader alloc] init];
    [_downloader loadRequest: request delegate: self];

    return YES;
}

-(void) cancel {
    [_downloader cancel];
    [_downloader release]; _downloader = nil;
    [_delegate release]; _delegate = nil;
}

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    NSError *error;
    CXMLDocument *document;

    document = [[CXMLDocument alloc] initWithData: data options: 0 error: &error];

    if ([[[document rootElement] name] isEqualToString: @"responseData"]) {
        CXMLNode* node = [[document rootElement] childAtIndex: 0];

        while (node != nil && [node kind] != CXMLElementKind) {
            node = [node nextSibling];
        }
        
        if (node != nil && [node kind] == CXMLElementKind) {
            if      ([[node name] isEqualToString: @"errorMessage"]) {
                [_delegate mnBuddyListRequest: self didFailWithError: [node stringValue]];
            }
            else if ([[node name] isEqualToString: @"currentUserBuddyList"]) {
                NSMutableArray* buddies = [[NSMutableArray alloc] init];
                NSArray* buddyNodes = [node children];

                for (CXMLNode* buddyNode in buddyNodes) {
                    if ([buddyNode kind] == CXMLElementKind && [[buddyNode name] isEqualToString: @"buddyItem"]) {
                        NSArray* buddyParamNodes = [buddyNode children];
                        NSMutableDictionary* buddyParams = [[NSMutableDictionary alloc] init];
                     
                        for (CXMLNode* buddyParamNode in buddyParamNodes) {
                            if ([buddyParamNode kind] == CXMLElementKind) {
                                NSString* value = [buddyParamNode stringValue];

                                if (value != nil) {
                                    [buddyParams setValue: value forKey: [buddyParamNode name]];
                                }
                            }
                        }

                        MNBuddyListEntry* buddyEntry = [[MNBuddyListEntry alloc] initWithAttributes: buddyParams];

                        [buddies addObject: buddyEntry];

                        [buddyParams release];
                        [buddyEntry release];
                    }
                }

                MNBuddyListResponse* response = [[MNBuddyListResponse alloc] initWithBuddyArray: buddies];
                [buddies release];

                [_delegate mnBuddyListRequest: self didSucceedWithResponse: response];

                [response release];
            }
        }
    }

    [document release];

    [_downloader autorelease]; _downloader = nil;
    [_delegate autorelease]; _delegate = nil;
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    [_delegate mnBuddyListRequest: self didFailWithError: error.message];

    [_downloader autorelease]; _downloader = nil;
    [_delegate autorelease]; _delegate = nil;
}

@end
