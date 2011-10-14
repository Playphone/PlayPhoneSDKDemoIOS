//
//  MNDelegateArray.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/12/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNDelegateArray : NSObject<NSFastEnumeration> {
    @private

    unsigned int    _callDepth;
    NSMutableArray *_delegates;
    NSMutableArray* _updateQueue;
}

-(id) init;
-(void) dealloc;

-(void) beginCall;
-(void) endCall;

-(void) setDelegate:(id) delegate;
-(void) addDelegate:(id) delegate;
-(void) removeDelegate:(id) delegate;

-(NSUInteger) count;
-(id) delegateAtIndex:(NSUInteger) index;

/* NSFastEnumeration protocol */
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end

#define MN_DELEGATE_ARRAY_CALL_PROLOG(protocol,delegates) \
do {                                                      \
    [(delegates) beginCall];                              \
                                                          \
    for (id<protocol> delegate in (delegates)) {

#define MN_DELEGATE_ARRAY_CALL_EPILOG(delegates) \
    }                                            \
                                                 \
    [(delegates) endCall];                       \
} while (0)

#define MN_DELEGATE_ARRAY_CALL_NOARG(protocol,delegates,sel) \
    MN_DELEGATE_ARRAY_CALL_PROLOG(protocol,delegates)        \
    if ([delegate respondsToSelector: @selector(sel)]) {     \
        [delegate sel];                                      \
    }                                                        \
    MN_DELEGATE_ARRAY_CALL_EPILOG(delegates)

#define MN_DELEGATE_ARRAY_CALL_ARG1(protocol,delegates,sel0,arg0) \
    MN_DELEGATE_ARRAY_CALL_PROLOG(protocol,delegates)             \
    if ([delegate respondsToSelector: @selector(sel0:)]) {        \
        [delegate sel0: (arg0)];                                  \
    }                                                             \
    MN_DELEGATE_ARRAY_CALL_EPILOG(delegates)

#define MN_DELEGATE_ARRAY_CALL_ARG2(protocol,delegates,sel0,arg0,sel1,arg1) \
    MN_DELEGATE_ARRAY_CALL_PROLOG(protocol,delegates)                       \
    if ([delegate respondsToSelector: @selector(sel0:sel1:)]) {             \
        [delegate sel0: (arg0) sel1: (arg1)];                               \
    }                                                                       \
    MN_DELEGATE_ARRAY_CALL_EPILOG(delegates)

#define MN_DELEGATE_ARRAY_CALL_ARG3(protocol,delegates,sel0,arg0,sel1,arg1,sel2,arg2) \
    MN_DELEGATE_ARRAY_CALL_PROLOG(protocol,delegates)                                 \
    if ([delegate respondsToSelector: @selector(sel0:sel1:sel2:)]) {                  \
        [delegate sel0: (arg0) sel1: (arg1) sel2: (arg2)];                            \
    }                                                                                 \
    MN_DELEGATE_ARRAY_CALL_EPILOG(delegates)
