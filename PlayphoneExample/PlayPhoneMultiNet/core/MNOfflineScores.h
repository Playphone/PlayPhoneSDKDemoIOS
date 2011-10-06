//
//  MNOfflineScores.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 8/12/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNCommon.h"
#import "MNVarStorage.h"

#ifdef __cplusplus
extern "C" {
#endif

extern BOOL MNOfflineScoreSaveScore (MNVarStorage* varStorage, MNUserId userId, NSInteger gameSetId, long long score);

#ifdef __cplusplus
}
#endif
