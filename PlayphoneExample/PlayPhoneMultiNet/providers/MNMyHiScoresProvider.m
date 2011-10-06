//
//  MNMyHiScoresProvider.m
//  MultiNet client
//
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNTools.h"
#import "MNMyHiScoresProvider.h"

static NSString* MNMyHiScoresProviderPluginName = @"com.playphone.mn.scorenote";

static NSString* MNMyHiScoresProviderMessageSeparatorChar = @":";
#define MNMyHiScoresProviderMessagePeriodCharWeekly  ('W')
#define MNMyHiScoresProviderMessagePeriodCharMonthly ('M')
#define MNMyHiScoresProviderMessagePeriodCharAllTime ('A')

/* NOTE: prefix is always one-letter, length is always equal to 1 */
#define MNMyHiScoresProviderMessagePrefixLen (1)
static NSString* MNMyHiScoresProviderMessagePrefixInit   = @"i";
static NSString* MNMyHiScoresProviderMessagePrefixModify = @"m";

@interface MNMyHiScoresProvider()
-(void) dealloc;

-(void) processInitMessage:(NSString*) message;
-(void) processModifyMessage:(NSString*) message;

/* MNSessionDelegate protocol */
-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender;
@end


@implementation MNMyHiScoresProvider

-(id) initWithSession:(MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session   = session;
        _delegates = [[MNDelegateArray alloc] init];
        _scores    = [[NSMutableDictionary alloc] init];

        [_session addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [_session removeDelegate: self];
	[_delegates release];
    [_scores release];

    [super dealloc];
}

-(NSNumber*) getMyHiScore:(NSInteger) gameSetId {
    return [_scores objectForKey: [NSNumber numberWithInteger: gameSetId]];
}

-(NSDictionary*) getMyHiScores {
    return [[_scores copy] autorelease];
}

-(void) addDelegate:(id<MNMyHiScoresProviderDelegate>) delegate {
	[_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNMyHiScoresProviderDelegate>) delegate {
	[_delegates removeDelegate: delegate];
}

-(void) processInitMessage:(NSString*) message {
    [_scores removeAllObjects];
    
    NSArray* entries = [message componentsSeparatedByString: @";"];
    
    for (NSString* entry in entries) {
        NSRange gameSetIdRange = [entry rangeOfString: MNMyHiScoresProviderMessageSeparatorChar];
        
        if (gameSetIdRange.location != NSNotFound) {
            NSInteger gameSetId;
            long long score;

            if (MNStringScanInteger(&gameSetId,[entry substringToIndex: gameSetIdRange.location]) &&
                MNStringScanLongLong(&score,[entry substringFromIndex: gameSetIdRange.location + 1])) {
                [_scores setObject: [NSNumber numberWithLongLong: score]
                         forKey: [NSNumber numberWithInteger: gameSetId]];
            }
        }
    }
}

-(void) processModifyMessage:(NSString*) message {
    NSRange gameSetIdEndRange = [message rangeOfString: MNMyHiScoresProviderMessageSeparatorChar];

    if (gameSetIdEndRange.location == NSNotFound) {
        return;
    }

    NSUInteger messageLength = [message length];

    NSRange scoreEndRange = [message rangeOfString: MNMyHiScoresProviderMessageSeparatorChar
                                     options: 0
                                     range: NSMakeRange(gameSetIdEndRange.location + 1,messageLength - gameSetIdEndRange.location - 1)];

    if (scoreEndRange.location == NSNotFound) {
        return;
    }

    NSInteger gameSetId;
    long long score;

    if (MNStringScanInteger(&gameSetId,[message substringToIndex: gameSetIdEndRange.location]) &&
        MNStringScanLongLong(&score,[message substringWithRange: NSMakeRange(gameSetIdEndRange.location + 1,
                                                                             scoreEndRange.location - gameSetIdEndRange.location)])) {
        unsigned int periodMask = 0;

        for (NSUInteger index = scoreEndRange.location + 1; index < messageLength; index++) {
            unichar periodChar = [message characterAtIndex: index];

            switch (periodChar) {
                case MNMyHiScoresProviderMessagePeriodCharWeekly: {
                    periodMask |= MN_HS_PERIOD_MASK_WEEK;
                } break;

                case MNMyHiScoresProviderMessagePeriodCharMonthly: {
                    periodMask |= MN_HS_PERIOD_MASK_MONTH;
                } break;

                case MNMyHiScoresProviderMessagePeriodCharAllTime: {
                    periodMask |= MN_HS_PERIOD_MASK_ALLTIME;
                } break;

                default: {
                }
            }
        }

        if (periodMask != 0) {
            if (periodMask & MN_HS_PERIOD_MASK_ALLTIME) {
                [_scores setObject: [NSNumber numberWithLongLong: score]
                            forKey: [NSNumber numberWithInteger: gameSetId]];
            }

			[_delegates beginCall];

            for (id<MNMyHiScoresProviderDelegate> delegate in _delegates) {
				if ([delegate respondsToSelector: @selector(hiScoreUpdated:gameSetId:periodMask:)]) {
					[delegate hiScoreUpdated: score gameSetId: gameSetId periodMask: periodMask];
				}
			}

			[_delegates endCall];
        }
    }
}

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (sender != nil) {
        return;
    }

    if (![pluginName isEqualToString: MNMyHiScoresProviderPluginName]) {
        return;
    }

    if      ([message hasPrefix: MNMyHiScoresProviderMessagePrefixInit]) {
        [self processInitMessage: [message substringFromIndex: MNMyHiScoresProviderMessagePrefixLen]];
    }
    else if ([message hasPrefix: MNMyHiScoresProviderMessagePrefixModify]) {
        [self processModifyMessage: [message substringFromIndex: MNMyHiScoresProviderMessagePrefixLen]];
    }
}

@end
