//
//  MNVarStorage.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 9/22/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNVarStorage.h"

#define MNVarStorageAverageVarCount (16)

static NSString* MNVAR_TMP_PREFIX  = @"tmp.";
static NSString* MNVAR_PROP_PREFIX = @"prop.";

@implementation MNVarStorage

#define MNVAR_MASK_WILDCARD_CHAR ('*')

static NSString* maskGetMaskPrefix (NSString* mask) {
    NSUInteger maskLen = [mask length];

    if (maskLen > 0 && [mask characterAtIndex: maskLen - 1] == MNVAR_MASK_WILDCARD_CHAR) {
        return [mask substringToIndex: maskLen - 1];
    }
    else {
        return nil;
    }
}

static BOOL varNameHasTempPrefix (NSString* varName) {
    return [varName hasPrefix: MNVAR_TMP_PREFIX] || [varName hasPrefix: MNVAR_PROP_PREFIX];
}

static void copyVariablesByMasks (NSArray* masks, NSMutableDictionary* destStorage, NSMutableDictionary* srcStorage) {
    NSUInteger index = 0;
    NSUInteger count = [masks count];
    BOOL done = NO;

    while (index < count && !done) {
        NSString* mask = [masks objectAtIndex: index];
        NSString* maskPrefix = maskGetMaskPrefix(mask);

        if (maskPrefix != nil) {
            if ([maskPrefix length] > 0) {
                for (NSString* var in srcStorage) {
                    if ([var hasPrefix: maskPrefix]) {
                        [destStorage setObject: [srcStorage objectForKey: var] forKey: var];
                    }
                }
            }
            else {
                [destStorage addEntriesFromDictionary: srcStorage];

                done = YES;
            }
        }
        else {
            id value = [srcStorage objectForKey: mask];
            
            if (value != nil) {
                [destStorage setObject: value forKey: mask];
            }
        }

        index++;
    }
}

static void removeVariablesByMasks (NSArray* masks, NSMutableDictionary* storage) {
    NSMutableArray* keys = [[NSMutableArray alloc] initWithCapacity: [storage count]];
    NSUInteger index = 0;
    NSUInteger count = [masks count];
    BOOL done = NO;

    while (index < count && !done) {
        NSString* mask = [masks objectAtIndex: index];
        NSString* maskPrefix = maskGetMaskPrefix(mask);

        if (maskPrefix != nil) {
            if ([maskPrefix length] > 0) {
                for (NSString* var in storage) {
                    if ([var hasPrefix: maskPrefix]) {
                        [keys addObject: var];
                    }
                }
            }
            else {
                [storage removeAllObjects];
                
                done = YES;
            }
        }
        else {
            [storage removeObjectForKey: mask];
        }

        index++;
    }

    if ([keys count] > 0) {
        [storage removeObjectsForKeys: keys];
    }

    [keys release];
}

-(id) initWithContentsOfFile:(NSString*) path {
    self = [super init];

    if (self != nil) {
        persistentStorage = [[NSMutableDictionary alloc] initWithContentsOfFile: path];

        if  (persistentStorage == nil) {
            persistentStorage = [[NSMutableDictionary alloc] initWithCapacity: MNVarStorageAverageVarCount];
        }

        tempStorage = [[NSMutableDictionary alloc] init];
    }

    return self;
}

-(void) dealloc {
    [tempStorage release];
    [persistentStorage release];

    [super dealloc];
}

-(BOOL) writeToFile:(NSString*) path {
    return [persistentStorage writeToFile: path atomically: YES];
}

-(void) setValue:(NSString*) value forVariable:(NSString*) name {
    if (varNameHasTempPrefix(name)) {
        [tempStorage setValue: value forKey: name];
    }
    else {
        [persistentStorage setValue: value forKey: name];
    }
}

-(NSString*) getValueForVariable:(NSString*) name {
    if (varNameHasTempPrefix(name)) {
        return [tempStorage objectForKey: name];
    }
    else {
        return [persistentStorage objectForKey: name];
    }
}

-(NSDictionary*) dictionaryWithVariablesByMask:(NSString*) mask {
    NSArray* maskList = [[NSArray alloc] initWithObjects: mask, nil];

    NSDictionary* result = [self dictionaryWithVariablesByMasks: maskList];

    [maskList release];

    return result;
}

-(NSDictionary*) dictionaryWithVariablesByMasks:(NSArray*) masks {
    NSMutableDictionary* result = [[[NSMutableDictionary alloc] initWithCapacity: MNVarStorageAverageVarCount] autorelease];

    copyVariablesByMasks(masks,result,tempStorage);
    copyVariablesByMasks(masks,result,persistentStorage);

    return result;
}

-(void) removeVariablesByMask:(NSString*) mask {
    NSArray* maskList = [[NSArray alloc] initWithObjects: mask, nil];

    [self removeVariablesByMasks: maskList];

    [maskList release];
}

-(void) removeVariablesByMasks:(NSArray*) masks {
    removeVariablesByMasks(masks,tempStorage);
    removeVariablesByMasks(masks,persistentStorage);
}

@end
