//
//  MNRandom.m
//  MultiNet client
//
//  Copyright 2009 PlayPhone. All rights reserved.
//

#include <time.h>

#import "MNRandom.h"

static unsigned int  MNRandomSeed = 1;
static BOOL          MNRandomInitialized = NO;

static void MNSRand (unsigned int *seed, int new_seed) {
    *seed = new_seed != 0 ? (unsigned int)new_seed : 1;
}

static int MNRandomNext (unsigned int *seed)  {
    *seed ^= (*seed << 13) & 0xFFFFFFFFU;
    *seed ^= *seed >> 17;
    *seed ^= (*seed << 5) & 0xFFFFFFFFU;

    return (int)(*seed & 0xFFFFFFFF);
}

static int MNRand (unsigned int *seed)  {
    return MNRandomNext(seed) & 0x7FFFFFFF;
}

static int MNRandomNextIntUpTo (int upBound, unsigned int *seed) {
    if (upBound <= 0) {
        return 0;
    }

    if ((upBound & -upBound) == upBound) {
        return (int)(MNRand(seed) % upBound);
    }

    int randomBits;
    int result;

    do
     {
      randomBits = MNRand(seed);
      result     = randomBits % upBound;
     } while (randomBits - result + (upBound - 1) < 0);

    return result;
}

@implementation MNRandom

-(id) init {
    self = [super init];

    if (self != nil) {
        MNSRand(&_seed,time(NULL));
    }

    return self;
}

-(id) initWithSeed:(int) seed {
    self = [super init];

    if (self != nil) {
        MNSRand(&_seed,seed);
    }

    return self;
}

-(void) setSeed:(int ) seed {
    MNSRand(&_seed,seed);
}

-(int) nextInt {
    return MNRandomNext(&_seed);
}

-(int) nextInt:(int) upBound {
    return MNRandomNextIntUpTo(upBound,&_seed);
}

-(void) srand:(int) seed {
    MNSRand(&_seed,seed);
}

-(int) rand {
    return MNRand(&_seed);
}

-(void) srandom:(int) seed {
    MNSRand(&_seed,seed);
}

-(int) random {
    return MNRand(&_seed);
}

@end

void MNRandom_mn_srand   (int seed) {
    MNRandomSeed = seed;
    MNRandomInitialized = YES;
}

int  MNRandom_mn_rand    (void) {
    if (!MNRandomInitialized) {
        MNRandom_mn_srand(time(NULL));
    }

    return MNRand(&MNRandomSeed);
}

void MNRandom_mn_srandom (int seed) {
    MNRandomSeed = seed;
    MNRandomInitialized = YES;
}

int  MNRandom_mn_random  (void) {
    if (!MNRandomInitialized) {
        MNRandom_mn_srandom(time(NULL));
    }

    return MNRand(&MNRandomSeed);
}
