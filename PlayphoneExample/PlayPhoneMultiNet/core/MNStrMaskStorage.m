//
//  MNStrMaskStorage.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 11/30/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNStrMaskStorage.h"

#define MNStrMaskStorageAverageCapacity (2)
#define MNStrMaskWildCardChar           ('*')

@implementation MNStrMaskStorage

static BOOL strCheckMask (NSString* mask, NSString* str) {
    NSInteger baseLen = [mask length] - 1;

    if (baseLen >= 0 && [mask characterAtIndex: baseLen] == MNStrMaskWildCardChar) {
        NSUInteger strLen = [str length];

        if (strLen >= baseLen) {
            return [str hasPrefix: [mask substringToIndex: baseLen]];
        }
        else {
            return NO;
        }
    }
    else {
        return [mask isEqualToString: str];
    }
}

-(id) init {
    self = [super init];

    if (self != nil) {
        masks = [[NSMutableSet alloc] initWithCapacity: MNStrMaskStorageAverageCapacity];
    }

    return self;
}

-(void) dealloc {
    [masks release];

    [super dealloc];
}

-(void) addMask:(NSString*) mask {
    [masks addObject: mask];
}

-(void) removeMask:(NSString*) mask {
    [masks removeObject: mask];
}

-(BOOL) checkString:(NSString*) str {
    for (NSString* mask in masks) {
        if (strCheckMask(mask,str)) {
            return YES;
        }
    }

    return NO;
}

@end
