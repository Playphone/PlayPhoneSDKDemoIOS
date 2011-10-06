//
//  MNRandom.h
//  MultiNet client
//
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MNRANDOM_RAND_MAX   (0x7FFFFFFF)
#define MNRANDOM_RANDOM_MAX (0x7FFFFFFF)

@interface MNRandom : NSObject {
    @private

    unsigned int _seed;
}

-(id) init;
-(id) initWithSeed:(int) seed;

-(void) setSeed:(int) seed;
-(int) nextInt;
-(int) nextInt:(int) upBound;

-(void) srand:(int) seed;
-(int) rand;

-(void) srandom:(int) seed;
-(int) random;

@end

#ifdef __cplusplus
 #define mn_extern_c extern "C"
#else
 #define mn_extern_c extern
#endif

mn_extern_c void MNRandom_mn_srand   (int seed);
mn_extern_c int  MNRandom_mn_rand    (void);

mn_extern_c void MNRandom_mn_srandom (int seed);
mn_extern_c int  MNRandom_mn_random  (void);

#undef mn_extern_c
