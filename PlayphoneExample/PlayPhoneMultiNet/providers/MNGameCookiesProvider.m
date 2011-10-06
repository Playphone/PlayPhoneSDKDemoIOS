//
//  MNGameCookiesProvider.m
//  MultiNet client
//
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNGameCookiesProvider.h"
#import "MNTools.h"

static NSString* MNGameCookiesProviderPluginName = @"com.playphone.mn.guc";

#define MNGameCookiesProviderAPIReqNumber  (0)
#define MNGameCookiesProviderDataMaxLength (1024)

static NSString* MNGameCookiesProviderUploadRequestFormat = @"p%d:%d:%@";
static NSString* MNGameCookiesProviderDeleteRequestFormat = @"d%d";
static NSString* MNGameCookiesProviderDownloadRequestFormat = @"g%d:%d";

#define MNGameCookiesProviderOpStatusOk    ('s')
#define MNGameCookiesProviderOpStatusError ('e')

@implementation MNGameCookiesProvider

+(id) MNGameCookiesProviderWithSession:(MNSession*) session {
	return [[[MNGameCookiesProvider alloc] initWithSession: session] autorelease];
}

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

-(void) downloadUserCookie:(NSInteger) key {
	[_session sendPlugin: MNGameCookiesProviderPluginName message: [NSString stringWithFormat: MNGameCookiesProviderDownloadRequestFormat, key, MNGameCookiesProviderAPIReqNumber]];
}

-(void) uploadUserCookieWithKey:(NSInteger) key andCookie:(NSString*) cookie {
	if (cookie != nil) {
		if ([cookie length] <= MNGameCookiesProviderDataMaxLength) {
			[_session sendPlugin: MNGameCookiesProviderPluginName message: [NSString stringWithFormat: MNGameCookiesProviderUploadRequestFormat, key, MNGameCookiesProviderAPIReqNumber, cookie]];
		}
		else {
            [_delegates beginCall];

            for (id<MNGameCookiesProviderDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(gameCookie:uploadFailedWithError:)]) {
                    [delegate gameCookie: key uploadFailedWithError: @"game cookie data length exceeds allowed limit"];
                }
            }

            [_delegates endCall];
		}
	}
	else {
		[_session sendPlugin: MNGameCookiesProviderPluginName message: [NSString stringWithFormat: MNGameCookiesProviderDeleteRequestFormat, key, MNGameCookiesProviderAPIReqNumber]];
	}
}

-(void) addDelegate:(id<MNGameCookiesProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNGameCookiesProviderDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

-(BOOL) parseResponse:(NSString*) response requestNumber:(NSInteger*) requestNumber key:(NSInteger*) key opStatus:(unichar*) opStatus value:(NSString**) value {
	NSUInteger length   = [response length];
	NSRange    keyRange = [response rangeOfString: @":" options: 0 range: NSMakeRange(1,length - 1)];

	if (keyRange.location == NSNotFound) {
		return NO;
	}

	if (!MNStringScanInteger(key,[response substringWithRange: NSMakeRange(1,keyRange.location - 1)])) {
		return NO;
	}

	NSUInteger pos = keyRange.location + 1;

	if (pos >= length) {
		return NO;
	}

	NSRange reqNumberRange = [response rangeOfString: @":" options: 0 range: NSMakeRange(pos,length - pos)];

	if (reqNumberRange.location == NSNotFound) {
		return NO;
	}

	if (!MNStringScanInteger(requestNumber,[response substringWithRange: NSMakeRange(pos,reqNumberRange.location - 1)])) {
		return NO;
	}

	pos = reqNumberRange.location + 1;

	if (pos >= length) {
		return NO;
	}

	*opStatus = [response characterAtIndex: pos];

	if (*opStatus != MNGameCookiesProviderOpStatusOk && *opStatus != MNGameCookiesProviderOpStatusError) {
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

-(void) handleGetResponse:(NSString*) response withLength:(NSUInteger) length {
	NSInteger  key;
	NSInteger  requestNumber;
	unichar    status;
	NSString*  value;

	if ([self parseResponse: response requestNumber: &requestNumber key: &key opStatus: &status value: &value]) {
		if (requestNumber != MNGameCookiesProviderAPIReqNumber) {
			return;
		}

		if (status == MNGameCookiesProviderOpStatusOk) {
            [_delegates beginCall];

            for (id<MNGameCookiesProviderDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(gameCookie:downloadSucceeded:)]) {
                    [delegate gameCookie: key downloadSucceeded: value];
                }
            }

            [_delegates endCall];
        }
		else {
            [_delegates beginCall];

            for (id<MNGameCookiesProviderDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(gameCookie:downloadFailedWithError:)]) {
                    [delegate gameCookie: key downloadFailedWithError: value];
                }
            }

            [_delegates endCall];
		}
	}
}

-(void) handlePutResponse:(NSString*) response withLength:(NSUInteger) length {
	NSInteger  key;
	NSInteger  requestNumber;
	unichar    status;
	NSString*  value;

	if ([self parseResponse: response requestNumber: &requestNumber key: &key opStatus: &status value: &value]) {
		if (requestNumber != MNGameCookiesProviderAPIReqNumber) {
			return;
		}

		if (status == MNGameCookiesProviderOpStatusOk) {
            [_delegates beginCall];

            for (id<MNGameCookiesProviderDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(gameCookieUploadSucceeded:)]) {
                    [delegate gameCookieUploadSucceeded: key];
                }
            }

            [_delegates endCall];
		}
		else {
            [_delegates beginCall];

            for (id<MNGameCookiesProviderDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(gameCookie:UploadFailedWithError:)]) {
                    [delegate gameCookie: key uploadFailedWithError: value];
                }
            }

            [_delegates endCall];
		}
	}
}

/* MNSessionDelegate protocol methods */

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (sender != nil) {
        return;
    }

    if (![pluginName isEqualToString: MNGameCookiesProviderPluginName]) {
        return;
    }

	NSUInteger length = [message length];

	if (length == 0) {
		return;
	}

	unichar cmdChar = [message characterAtIndex: 0];

	if      (cmdChar == 'g') {
		[self handleGetResponse: message withLength: length];
	}
	else if (cmdChar == 'p' || cmdChar == 'd') {
		[self handlePutResponse: message withLength: length];
	}
}

@end
