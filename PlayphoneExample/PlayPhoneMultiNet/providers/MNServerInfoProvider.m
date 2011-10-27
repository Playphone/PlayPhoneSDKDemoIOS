//
//  MNServerInfoProvider.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import "INFSmartFoxiPhoneClient.h"
#import "INFSmartFoxRoom.h"
#import "INFSmartFoxRoomVariable.h"

#import "MNTools.h"

#import "MNServerInfoProvider.h"

static NSString* MNServerInfoProviderPluginName = @"com.playphone.mn.si";

#define MNServerInfoProviderAPIReqNumber (0)

static NSString* MNServerInfoProviderDownloadRequestFormat = @"g%d:%d";

#define MNServerInfoProviderOpStatusOk    ('s')
#define MNServerInfoProviderOpStatusError ('e')

/*FIXME: move this func to MNTools */
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

@implementation MNServerInfoProvider

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

-(void) requestServerInfoItem:(NSInteger) key {
    [_session sendPlugin: MNServerInfoProviderPluginName
                 message: [NSString stringWithFormat: MNServerInfoProviderDownloadRequestFormat, key, MNServerInfoProviderAPIReqNumber]];
}

-(void) addDelegate:(id<MNServerInfoProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNServerInfoProviderDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

-(BOOL) parseResponse:(NSString*) response requestNumber:(NSInteger*) requestNumber key:(NSInteger*) key opStatus:(unichar*) opStatus value:(NSString**) value {
    NSUInteger length   = [response length];
    NSUInteger pos      = 1; // skip response type char

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

    if (*opStatus != MNServerInfoProviderOpStatusOk &&
        *opStatus != MNServerInfoProviderOpStatusError) {
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
    NSInteger  key;
    NSInteger  requestNumber;
    unichar    status;
    NSString*  value;
    
    if ([self parseResponse: response requestNumber: &requestNumber key: &key opStatus: &status value: &value]) {
        if (requestNumber != MNServerInfoProviderAPIReqNumber) {
            return;
        }

        if (status == MNServerInfoProviderOpStatusOk) {
            MN_DELEGATE_ARRAY_CALL_ARG2(MNServerInfoProviderDelegate,_delegates,
                                        serverInfoWithKey,key,
                                        received,value);
        }
        else {
            MN_DELEGATE_ARRAY_CALL_ARG2(MNServerInfoProviderDelegate,_delegates,
                                        serverInfoWithKey,key,
                                        requestFailedWithError,value);
        }
    }
}

/* MNSessionDelegate protocol methods */

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (sender != nil) {
        return;
    }

    if (![pluginName isEqualToString: MNServerInfoProviderPluginName]) {
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
