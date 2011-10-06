//
//  MNDelegateArray.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/12/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNDelegateArray.h"

static const void *arrayCallBackNonRetainingRetain (CFAllocatorRef allocator, const void *value) {
    return value;
}

static void arrayCallBackNonRetainingRelease (CFAllocatorRef allocator, const void *value) {
}

#define MNDelegateArrayUpdateAdd        (0)
#define MNDelegateArrayUpdateRemove     (1)
#define MNDelegateArrayUpdateReplaceAll (2)

@interface MNDelegateArrayUpdateItem : NSObject
{
    @private

    unsigned int _updateMode;
    id           _delegate;
}

@property (nonatomic,assign) unsigned int updateMode;
@property (nonatomic,retain) id           delegate;

-(id) initWithMode:(unsigned int) updateMode andDelegate:(id) delegate;
-(void) dealloc;

@end


@implementation MNDelegateArrayUpdateItem

@synthesize updateMode = _updateMode;
@synthesize delegate   = _delegate;

-(id) initWithMode:(unsigned int) updateMode andDelegate:(id) delegate {
    self = [super init];

    if (self != nil) {
        self.updateMode = updateMode;
        self.delegate   = delegate;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];

    [super dealloc];
}

@end


@implementation MNDelegateArray

-(id) init {
    self = [super init];

    if (self != nil) {
        CFArrayCallBacks arrayCallBacksNonRetaining = kCFTypeArrayCallBacks;
        arrayCallBacksNonRetaining.retain  = arrayCallBackNonRetainingRetain;
        arrayCallBacksNonRetaining.release = arrayCallBackNonRetainingRelease;

        _delegates   = (NSMutableArray*)(CFArrayCreateMutable(NULL,0,&arrayCallBacksNonRetaining));
        _updateQueue = [[NSMutableArray alloc] init];

        _callDepth = 0;
    }

    return self;
}

-(void) dealloc {
    [_updateQueue release];
    [_delegates release];

    [super dealloc];
}

-(void) beginCall {
    _callDepth++;
}

-(void) replayUpdateQueue {
    for (MNDelegateArrayUpdateItem* updateItem in _updateQueue) {
        unsigned int mode = updateItem.updateMode;
        id delegate       = updateItem.delegate;

        if      (mode == MNDelegateArrayUpdateAdd) {
            [_delegates addObject: delegate];
        }
        else if (mode == MNDelegateArrayUpdateRemove) {
            [self removeDelegate: delegate];
        }
        else if (mode == MNDelegateArrayUpdateReplaceAll) {
            [_delegates removeAllObjects];

            if (delegate != nil) {
                [_delegates addObject: delegate];
            }
        }
    }
}

-(void) endCall {
    if (_callDepth > 0) {
        _callDepth--;
    }
    else {
        NSLog(@"warning: inconsistent begin/end delegates call");
    }

    if (_callDepth == 0) {
        [self replayUpdateQueue];
        [_updateQueue removeAllObjects];
    }
}

-(void) setDelegate:(id) delegate {
    if (_callDepth > 0) {
        [_updateQueue addObject:
         [[[MNDelegateArrayUpdateItem alloc] initWithMode: MNDelegateArrayUpdateReplaceAll
                                              andDelegate: delegate] autorelease]];
    }
    else {
        [_delegates removeAllObjects];

        if (delegate != nil) {
            [_delegates addObject: delegate];
        }
    }
}

-(void) addDelegate:(id) delegate {
    if (delegate !=  nil) {
        if (_callDepth > 0) {
            [_updateQueue addObject:
             [[[MNDelegateArrayUpdateItem alloc] initWithMode: MNDelegateArrayUpdateAdd
                                                  andDelegate: delegate] autorelease]];
        }
        else {
            [_delegates addObject: delegate];
        }
    }
}

-(void) removeDelegate:(id) delegate {
    if (_callDepth > 0) {
        [_updateQueue addObject:
         [[[MNDelegateArrayUpdateItem alloc] initWithMode: MNDelegateArrayUpdateRemove
                                              andDelegate: delegate] autorelease]];
    }
    else {
        NSUInteger index = 0;
        NSUInteger count = [_delegates count];
        BOOL found = NO;

        while (index < count && !found) {
            if ([_delegates objectAtIndex: index] == delegate) {
                found = YES;
            }
            else {
                index++;
            }
        }

        if (found) {
            [_delegates removeObjectAtIndex: index];
        }
    }
}

-(NSUInteger) count {
    return [_delegates count];
}

-(id) delegateAtIndex:(NSUInteger) index {
    return [_delegates objectAtIndex: index];
}

/* NSFastEnumeration protocol */
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [_delegates countByEnumeratingWithState: state objects: stackbuf count: len];
}

@end
