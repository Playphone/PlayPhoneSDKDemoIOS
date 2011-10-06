//
//  MNScoreProgressView.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 16.08.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNSession.h"
#import "MNScoreProgressProvider.h"
#import <UIKit/UIKit.h>

#define MNScoreProgressScoreResendDefTimeout     (2)


@interface MNScoreProgressView : UIView <MNSessionDelegate,MNScoreProgressProviderDelegate> {
    BOOL                     inited;
    long long                currentScore;
    NSTimer                 *scoreResendTimer;
    NSTimeInterval           scoreResendTimeout;
 
    MNScoreProgressProviderScoreCompareFunc   scoreCompareFunc;
    void                                     *scoreCompareFuncContext;
}

-(void) postScore:(long long) score;
-(void) sessionReady;

-(void) setScoreCompareFunc:(MNScoreProgressProviderScoreCompareFunc) func withContext:(void*) context;
-(BOOL) checkProvider;

@property (nonatomic,assign) NSTimeInterval scoreResendTimeout;

@end
