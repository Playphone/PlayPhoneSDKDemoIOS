//
//  MNGameRoomCookiesProvider.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import "INFSmartFoxiPhoneClient.h"
#import "INFSmartFoxRoom.h"
#import "INFSmartFoxRoomVariable.h"

#import "MNTools.h"

#import "MNGameRoomCookiesProvider.h"

static NSString* MNGameRoomCookiesProviderPluginName = @"com.playphone.mn.grc";

#define MNGameRoomCookiesProviderAPIReqNumber  (0)
#define MNGameRoomCookiesProviderDataMaxLength (1024)
#define MNGameRoomCookiesProviderCookieMinKey  (0)
#define MNGameRoomCookiesProviderCookieMaxKey  (99)

static NSString* MNGameRoomCookiesProviderDownloadRequestFormat = @"g%d:%d:%d";

#define MNGameRoomCookiesProviderOpStatusOk    ('s')
#define MNGameRoomCookiesProviderOpStatusError ('e')

static NSString* MNGameRoomCookieGetVarNameByKey (NSInteger key) {
    return [NSString stringWithFormat: @"MN_RV_%d", key];
}

static NSString* responseStrReadWord (NSString* str, NSUInteger* pos, NSUInteger strLength) {
    if (*pos >= strLength) {
        return nil;
    }

    NSRange columnRange = [str rangeOfString: @":" options: 0 range: NSMakeRange(*pos,strLength - *pos)];

    if (columnRange.location == NSNotFound) {
        return nil;
    }

    NSString* word = [str substringWithRange: NSMakeRange(*pos,columnRange.location - *pos)];

    *pos = columnRange.location + 1;

    return word;
}

@implementation MNGameRoomCookiesProvider

-(id) initWithSession:(MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session   = session;
        _delegates = [[MNDelegateArray alloc] init];

       [_session addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [_session removeDelegate: self];

    [_delegates release];

    [super dealloc];
}

-(void) downloadGameRoomCookieForRoom:(NSInteger) roomSFId withKey:(NSInteger) key {
    [_session sendPlugin: MNGameRoomCookiesProviderPluginName
                 message: [NSString stringWithFormat: MNGameRoomCookiesProviderDownloadRequestFormat, roomSFId, key, MNGameRoomCookiesProviderAPIReqNumber]];
}

-(void) setCurrentGameRoomCookieWithKey:(NSInteger) key andCookie:(NSString*) cookie {
    if (key < MNGameRoomCookiesProviderCookieMinKey ||
        key > MNGameRoomCookiesProviderCookieMaxKey ||
        (cookie != nil &&
         [cookie length] > MNGameRoomCookiesProviderDataMaxLength)) {
        NSLog(@"unable to set room cookie - invalid cookie");

        return;
    }

    NSString* varName = MNGameRoomCookieGetVarNameByKey(key);
    INFSmartFoxiPhoneClient* smartFox = [_session getSmartFox];
    INFSmartFoxRoomVariable* var;

    if (cookie != nil) {
        var = [INFSmartFoxRoomVariable roomVariableWithString: varName value: cookie];
    }
    else {
        var = [[[INFSmartFoxRoomVariable alloc] initWithParams: varName value: nil] autorelease];
    }

    var.priv       = NO;
    var.persistent = YES;

    [smartFox setRoomVariables:[NSArray arrayWithObject: var]
                        roomId: smartFox.activeRoomId
                  setOwnership: NO];
}

-(NSString*) currentGameRoomCookieWithKey:(NSInteger) key {
    INFSmartFoxRoom* activeRoom = [[_session getSmartFox] getActiveRoom];

    if (activeRoom == nil) {
        NSLog(@"unable to get room cookie - no active room found");

        return nil;
    }

    NSObject* var = [activeRoom getVariable: MNGameRoomCookieGetVarNameByKey(key)];

    return [var description];
}

-(void) addDelegate:(id<MNGameRoomCookiesProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNGameRoomCookiesProviderDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

-(BOOL) parseResponse:(NSString*) response roomSFId:(NSInteger*) roomSFId requestNumber:(NSInteger*) requestNumber key:(NSInteger*) key opStatus:(unichar*) opStatus value:(NSString**) value {
    NSUInteger length   = [response length];
    NSUInteger pos      = 1; // skip response type char

    if (!MNStringScanInteger(roomSFId,responseStrReadWord(response,&pos,length))) {
        return NO;
    }

    if (!MNStringScanInteger(key,responseStrReadWord(response,&pos,length))) {
        return NO;
    }

    if (!MNStringScanInteger(requestNumber,responseStrReadWord(response,&pos,length))) {
        return NO;
    }

    if (pos >= length) {
        return NO;
    }

    *opStatus = [response characterAtIndex: pos];

    if (*opStatus != MNGameRoomCookiesProviderOpStatusOk &&
        *opStatus != MNGameRoomCookiesProviderOpStatusError) {
        return NO;
    }

    pos++;

    if (pos >= length) {
        *value = nil;

        return YES;
    }

    if ([response characterAtIndex: pos] != ':') {
        return NO;
    }

    pos++;

    *value = [response substringFromIndex: pos];

    return YES;
}

-(void) handleGetResponse:(NSString*) response {
    NSInteger  roomSFId;
    NSInteger  key;
    NSInteger  requestNumber;
    unichar    status;
    NSString*  value;

    if ([self parseResponse: response roomSFId: &roomSFId requestNumber: &requestNumber key: &key opStatus: &status value: &value]) {
        if (requestNumber != MNGameRoomCookiesProviderAPIReqNumber) {
            return;
        }

        if (status == MNGameRoomCookiesProviderOpStatusOk) {
            MN_DELEGATE_ARRAY_CALL_ARG3(MNGameRoomCookiesProviderDelegate,_delegates,
                                        gameRoomCookieForRoom,roomSFId,
                                        withKey,key,
                                        downloadSucceeded,value);
        }
        else {
            MN_DELEGATE_ARRAY_CALL_ARG3(MNGameRoomCookiesProviderDelegate,_delegates,
                                        gameRoomCookieForRoom,roomSFId,
                                        withKey,key,
                                        downloadFailedWithError,value);
	}
    }
}

/* MNSessionDelegate protocol methods */

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (sender != nil) {
        return;
    }

    if (![pluginName isEqualToString: MNGameRoomCookiesProviderPluginName]) {
        return;
    }

    NSUInteger length = [message length];

    if (length == 0) {
        return;
    }

    unichar cmdChar = [message characterAtIndex: 0];

    if (cmdChar == 'g') {
        [self handleGetResponse: message];
    }
}

@end
