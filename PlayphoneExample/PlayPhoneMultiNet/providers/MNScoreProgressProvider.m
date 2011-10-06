//
//  MNScoreProgressProvider.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 12/16/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNTools.h"
#import "MNScoreProgressProvider.h"

static NSString* MNScoreProgressProviderPluginName = @"com.playphone.mn.ps1";

#define MNScoreProgressProviderMinRefreshInterval        (500)
#define MNScoreProgressProviderUpdateDelayDefaultFactor  (3)
#define MNScoreProgressProviderSyncModeStoredSlicesCount (4)

@interface MNScoreProgressProviderStateSlice : NSObject {
    @private

    NSMutableDictionary* _scores;
}

-(id) init;
-(void) dealloc;

-(void) clear;

-(void) updateUser:(MNUserInfo*) userInfo score:(long long) score;

-(NSArray*) createSortedArrayUsingFunction:(MNScoreProgressProviderScoreCompareFunc) compareFunc
            andContext:(void*) compareFuncContext;
@end

@implementation MNScoreProgressProviderStateSlice

-(id) init {
    self = [super init];

    if (self != nil) {
        _scores = [[NSMutableDictionary alloc] init];
    }

    return self;
}

-(void) dealloc {
    [_scores release];

    [super dealloc];
}

-(void) clear {
    [_scores removeAllObjects];
}

-(void) updateUser:(MNUserInfo*) userInfo score:(long long) score {
    NSNumber* userId = [[NSNumber alloc] initWithLongLong: userInfo.userId];
    MNScoreProgressProviderItem* item = [[MNScoreProgressProviderItem alloc] initWithUserInfo: userInfo score: score andPlace: 0];

    [_scores setObject: item forKey: userId];

    [item release];
    [userId release];
}

typedef struct {
    MNScoreProgressProviderScoreCompareFunc compareFunc;
    void*                                 compareFuncContext;
} MNScoreSortingContext;

NSInteger MNScoreProgressProviderScoreCompareFuncMoreIsBetter
                    (MNScoreProgressProviderItem* score1,
                     MNScoreProgressProviderItem* score2,
                     void* context) {
    long long delta = score1.score - score2.score;

    if (delta > 0) {
        return NSOrderedDescending;
    }
    else if (delta < 0) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

NSInteger MNScoreProgressProviderScoreCompareFuncLessIsBetter
                    (MNScoreProgressProviderItem* score1,
                     MNScoreProgressProviderItem* score2,
                     void* context) {
    return MNScoreProgressProviderScoreCompareFuncMoreIsBetter(score2,score1,context);
}

static NSInteger MNPluginScoreCompareFunction (id item1, id item2, void* context) {
    MNScoreSortingContext* sortingContext = (MNScoreSortingContext*)context;

    int cmp = sortingContext->compareFunc((MNScoreProgressProviderItem*)item1,
                                          (MNScoreProgressProviderItem*)item2,
                                          sortingContext->compareFuncContext);

    /*NOTE: we reverse comparison result to make array to be sorted in descending order */
    if      (cmp == NSOrderedDescending) {
        return NSOrderedAscending;
    }
    else if (cmp == NSOrderedAscending) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

-(NSArray*) createSortedArrayUsingFunction:(MNScoreProgressProviderScoreCompareFunc) compareFunc
                                andContext:(void*) compareFuncContext {
    NSUInteger count = [_scores count];
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity: count];

    if (count > 0) {
        for (id userId in _scores) {
            [array addObject: [_scores objectForKey: userId]];
        }

        MNScoreSortingContext context;

        context.compareFunc        = compareFunc == NULL ? MNScoreProgressProviderScoreCompareFuncMoreIsBetter : compareFunc;
        context.compareFuncContext = compareFuncContext;

        [array sortUsingFunction: MNPluginScoreCompareFunction context: &context];

        MNScoreProgressProviderItem* item = (MNScoreProgressProviderItem*)[array objectAtIndex: 0];

        item.place = 1;

        long long score = item.score;
        int       place = 1;

        item.place = place;

        for (NSUInteger index = 1; index < count; index++) {
            item = (MNScoreProgressProviderItem*)[array objectAtIndex: index];

            if (item.score != score) {
                score = item.score;
                place++;
            }

            item.place = place;
        }
    }

    return array;
}

@end

@interface MNScoreProgressProviderSyncState : NSObject
{
    @private

    int             _period;

    int             _baseTime;
    NSMutableArray* _syncScoreSlices;
}

-(id) initWithPeriod:(int) period;
-(void) dealloc;

-(void) setBaseTime:(int) baseTime;
-(void) updateSyncScore:(long long) score forUser:(MNUserInfo*) userInfo andTime:(int) scoreTime;
-(void) clear;

-(NSArray*) createSortedArrayUsingFunction:(MNScoreProgressProviderScoreCompareFunc) compareFunc
            andContext:(void*) compareFuncContext;

@end


@implementation MNScoreProgressProviderSyncState

-(id) initWithPeriod:(int) period {
    self = [super init];

    if (self != nil) {
        _period = period;
        _baseTime = 0;
        _syncScoreSlices = [[NSMutableArray alloc] initWithCapacity: MNScoreProgressProviderSyncModeStoredSlicesCount];

        for (unsigned int index = 0; index < MNScoreProgressProviderSyncModeStoredSlicesCount; index++) {
            [_syncScoreSlices addObject: [[[MNScoreProgressProviderStateSlice alloc] init] autorelease]];
        }
    }

    return self;
}

-(void) dealloc {
    [_syncScoreSlices release];

    [super dealloc];
}

-(void) clear {
    _baseTime = 0;

    for (unsigned int index = 0; index < MNScoreProgressProviderSyncModeStoredSlicesCount; index++) {
        [[_syncScoreSlices objectAtIndex: index] clear];
    }
}

-(void) setBaseTime:(int) baseTime {
    if (baseTime <= _baseTime) {
        return;
    }

    unsigned int offset = (baseTime - _baseTime) / _period;

    if (offset < MNScoreProgressProviderSyncModeStoredSlicesCount) {
        [_syncScoreSlices removeObjectsInRange: NSMakeRange(0,offset)];

        for (unsigned int index = 0; index < offset; index++) {
            [_syncScoreSlices addObject: [[[MNScoreProgressProviderStateSlice alloc] init] autorelease]];
        }
    }
    else {
        for (unsigned int index = 0; index < MNScoreProgressProviderSyncModeStoredSlicesCount; index++) {
            [[_syncScoreSlices objectAtIndex: index] clear];
        }
    }

    _baseTime = baseTime;
}

-(void) updateSyncScore:(long long) score forUser:(MNUserInfo*) userInfo andTime:(int) scoreTime {
    if (scoreTime < _baseTime) {
        return; /* too late for this score */
    }

    unsigned int sliceIndex = (scoreTime - _baseTime) / _period;

    if (sliceIndex >= MNScoreProgressProviderSyncModeStoredSlicesCount) {
        return; /* too far in the future */
    }

    [[_syncScoreSlices objectAtIndex: sliceIndex] updateUser: userInfo score: score];
}

-(NSArray*) createSortedArrayUsingFunction:(MNScoreProgressProviderScoreCompareFunc) compareFunc
            andContext:(void*) compareFuncContext {

    return [[_syncScoreSlices objectAtIndex: 0] createSortedArrayUsingFunction: compareFunc
             andContext: compareFuncContext];
}

@end


@interface MNScoreProgressProvider ()
-(void) initStateData;
-(void) deallocStateData;
-(void) dealloc;
-(void) sendScore:(long long) score forTime:(int) scoreTime;
-(BOOL) parseMessage:(NSString*) message forScore:(long long*) score andTime:(int*) scoreTime;
-(void) notifyScoreUpdated;
-(BOOL) isInGamePlay;
/* MNSessionDelegate protocol */
-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender;
@end


@implementation MNScoreProgressProvider

-(id) initWithSession: (MNSession*) session
      refreshInterval: (int) refreshInterval
      andUpdateDelay: (int) updateDelay {
    self = [super init];

    if (self != nil) {
        _session = session;
        _refreshInterval = refreshInterval;
        _updateDelay = updateDelay;
        _delegates = [[MNDelegateArray alloc] init];;
        _scoreCompareFunc = NULL;

        _running = NO;
        _startTime = nil;

        [self initStateData];
    }

    return self;
}

-(id) initWithSession: (MNSession*) session {
    return [self initWithSession: session refreshInterval: 0 andUpdateDelay: 0];
}

-(void) initStateData {
    _postScoreTimer = nil;

    if (_refreshInterval == 0) {
        _asyncMode = YES;
    }
    else {
        _asyncMode = NO;

        if (_refreshInterval < MNScoreProgressProviderMinRefreshInterval) {
            _refreshInterval = MNScoreProgressProviderMinRefreshInterval;
        }

        if (_updateDelay <= 0) {
            _updateDelay = _refreshInterval / MNScoreProgressProviderUpdateDelayDefaultFactor;
        }

        _updateDelay /= 1000.0;
    }

    if (_asyncMode) {
        _scoreState.asyncScoreSlice = [[MNScoreProgressProviderStateSlice alloc] init];
    }
    else {
        _scoreState.syncState = [[MNScoreProgressProviderSyncState alloc] initWithPeriod: _refreshInterval];
    }
}

-(void) deallocStateData {
    if (_asyncMode) {
        [_scoreState.asyncScoreSlice release];
    }
    else {
        [_scoreState.syncState release];
        
        [NSObject cancelPreviousPerformRequestsWithTarget: self];
        [_postScoreTimer invalidate];
        [_postScoreTimer release];
    }
}

-(void) dealloc {
    if (_running) {
        [_session removeDelegate: self];
    }

    [self deallocStateData];

	[_delegates release];
    [_startTime release];
    [super dealloc];
}

-(void) setRefreshInterval:(int) refreshInterval andUpdateDelay:(int) updateDelay {
    if (_running) {
        return; // ignore call during gameplay
    }

    [self deallocStateData];

    _refreshInterval = refreshInterval;
    _updateDelay = updateDelay;

    [self initStateData];
}

-(void) setScoreCompareFunc:(MNScoreProgressProviderScoreCompareFunc) compareFunc
                withContext:(void*) context {
    _scoreCompareFunc        = compareFunc;
    _scoreCompareFuncContext = context;
}

-(void) sendScore:(long long) score forTime:(int) scoreTime {
    if ([self isInGamePlay]) {
        NSString* message = [[NSString alloc] initWithFormat: @"%d:%lld",
                            scoreTime,score];

        [_session sendPlugin: MNScoreProgressProviderPluginName message: message];

        [message release];
    }
}

-(void) postScore: (long long) score {
    if (_running) {
        if (_asyncMode) {
            double scoreTime;

            scoreTime = -[_startTime timeIntervalSinceNow] * 1000;

            [_scoreState.asyncScoreSlice updateUser: [_session getMyUserInfo] score: score];
            [self notifyScoreUpdated];
            [self sendScore: score forTime: (int)scoreTime];
        }
        else {
            _currentScore = score;
        }
    }
}

-(void) postScoreTimerFired:(NSTimer*) timer {
    double scoreTime;

    scoreTime = -[_startTime timeIntervalSinceNow] * 1000 + _refreshInterval / 2;
    scoreTime = ((int)(scoreTime / _refreshInterval)) * _refreshInterval;

    int baseTime = (int)scoreTime;

    [self sendScore: _currentScore forTime: baseTime];
    [_scoreState.syncState setBaseTime: baseTime];
    [_scoreState.syncState updateSyncScore: _currentScore forUser: [_session getMyUserInfo] andTime: baseTime];

    [self performSelector: @selector(notifyScoreUpdated) withObject: nil afterDelay: _updateDelay];
}

-(void) start {
    if (_postScoreTimer != nil) {
        [_postScoreTimer invalidate];
        [_postScoreTimer release];

        _postScoreTimer = nil;
    }

    [_startTime release];

    _startTime = [[NSDate alloc] init];
    _currentScore = 0;

    if (_asyncMode) {
        [_scoreState.asyncScoreSlice clear];
    }
    else {
        [_scoreState.syncState clear];

        _postScoreTimer = [[NSTimer scheduledTimerWithTimeInterval: _refreshInterval / 1000.0
                                    target: self
                                    selector: @selector(postScoreTimerFired:)
                                    userInfo: nil
                                    repeats: YES] retain];
    }

    if (!_running) {
        [_session addDelegate: self];
    }

    _running = YES;
}

-(void) stop {
    if (_running) {
        _running = NO;

        [_session removeDelegate: self];
    }

    if (_asyncMode) {
        [_scoreState.asyncScoreSlice clear];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget: self];
        [_postScoreTimer invalidate];
        [_postScoreTimer release];

        _postScoreTimer = nil;

        [_scoreState.syncState clear];
    }

    [_startTime release];
    _startTime = nil;
}

-(void) notifyScoreUpdated {
    if ([self isInGamePlay]) {
        NSArray* scores = nil;

        if (_asyncMode) {
            scores = [_scoreState.asyncScoreSlice createSortedArrayUsingFunction: _scoreCompareFunc andContext: _scoreCompareFuncContext];
        }
        else {
            scores = [_scoreState.syncState createSortedArrayUsingFunction: _scoreCompareFunc andContext: _scoreCompareFuncContext];
        }

        if (scores != nil) {
			[_delegates beginCall];
			
			for (id<MNScoreProgressProviderDelegate> delegate in _delegates) {
				[delegate scoresUpdated: scores];
			}

			[_delegates endCall];

            [scores release];
        }
    }
}

-(BOOL) parseMessage:(NSString*) message forScore:(long long*) score andTime:(int*) scoreTime {
    NSArray* components = [message componentsSeparatedByString: @":"];

    if ([components count] != 2) {
        return NO;
    }

    if (!MNStringScanInteger(scoreTime,[components objectAtIndex: 0])) {
        return NO;
    }

    if (!MNStringScanLongLong(score,[components objectAtIndex: 1])) {
        return NO;
    }

    return YES;
}

-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (!_running) {
        return;
    }

    if (sender == nil) {
        return;
    }

    if (![pluginName isEqualToString: MNScoreProgressProviderPluginName]) {
        return;
    }

    long long score;
    int       scoreTime;

    if (![self parseMessage: message forScore: &score andTime: &scoreTime]) {
        return;
    }

    if (_asyncMode) {
        [_scoreState.asyncScoreSlice updateUser: sender score: score];
        [self notifyScoreUpdated];
    }
    else {
        [_scoreState.syncState updateSyncScore: score forUser: sender andTime: scoreTime];
    }
}

-(BOOL) isInGamePlay {
    NSInteger status = [_session getStatus];

    return status == MN_IN_GAME_PLAY;
}

-(void) addDelegate:(id<MNScoreProgressProviderDelegate>) delegate {
	[_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNScoreProgressProviderDelegate>) delegate {
	[_delegates removeDelegate: delegate];
}

@end


@implementation MNScoreProgressProviderItem

@synthesize userInfo = _userInfo;
@synthesize score    = _score;
@synthesize place    = _place;

-(id) initWithUserInfo:(MNUserInfo*) userInfo score:(long long) score andPlace:(int) place {
    self = [super init];

    if (self != nil) {
        self.userInfo = userInfo;
        self.score    = score;
        self.place    = place;
    }

    return self;
}

-(void) dealloc {
    [_userInfo release];

    [super dealloc];
}

@end
