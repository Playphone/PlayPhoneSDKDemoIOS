//
//  MNOfflineScores.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 8/12/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <time.h>

#import "MNTools.h"
#import "MNOfflineScores.h"

static NSString* MNOfflineScoreGetVarNamePrefix (MNUserId userId, NSInteger gameSetId) {
    return [NSString stringWithFormat: @"offline.%lld.score_pending.%d.",(long long)userId,gameSetId];
}

extern BOOL MNOfflineScoreSaveScore (MNVarStorage* varStorage, MNUserId userId, NSInteger gameSetId, long long score) {
    NSString* varNamePrefix   = MNOfflineScoreGetVarNamePrefix(userId,gameSetId);
    NSString* scoreStr        = [NSString stringWithFormat: @"%lld",score];
    NSString* timeStr         = [NSString stringWithFormat: @"%lld",(long long)time(NULL)];
    NSString* minScoreVarName = [varNamePrefix stringByAppendingString: @"min.score"];
    NSString* minScoreStr     = [varStorage getValueForVariable: minScoreVarName];
    NSString* maxScoreVarName = [varNamePrefix stringByAppendingString: @"max.score"];
    NSString* maxScoreStr     = [varStorage getValueForVariable: maxScoreVarName];

    long long storedScore;

    if (minScoreStr == nil || !MNStringScanLongLong(&storedScore,minScoreStr) || score <= storedScore) {
        [varStorage setValue: scoreStr forVariable: minScoreVarName];
        [varStorage setValue: timeStr forVariable: [varNamePrefix stringByAppendingString: @"min.date"]];
    }

    if (maxScoreStr == nil || !MNStringScanLongLong(&storedScore,maxScoreStr) || score >= storedScore) {
        [varStorage setValue: scoreStr forVariable: maxScoreVarName];
        [varStorage setValue: timeStr forVariable: [varNamePrefix stringByAppendingString: @"max.date"]];
    }

    [varStorage setValue: scoreStr forVariable:[varNamePrefix stringByAppendingString: @"last.score"]];
    [varStorage setValue: timeStr forVariable: [varNamePrefix stringByAppendingString: @"last.date"]];

    return YES;
}
