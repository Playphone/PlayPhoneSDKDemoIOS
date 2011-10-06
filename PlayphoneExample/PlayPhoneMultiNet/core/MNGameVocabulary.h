//
//  MNGameVocabulary.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNDelegateArray.h"
#import "MNURLDownloader.h"

enum {
    MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS = -200,
    MN_GV_UPDATE_STATUS_CHECK_IN_PROGRESS    = -100,
    MN_GV_UPDATE_STATUS_UNKNOWN              = -1,
    MN_GV_UPDATE_STATUS_UP_TO_DATE           = 0,
    MN_GV_UPDATE_STATUS_NEED_DOWNLOAD        = 1
};

enum {
    MN_GV_DOWNLOAD_SUCCESS =  0,
    MN_GV_DOWNLOAD_FAIL    = -1
};

@protocol MNGameVocabularyDelegate<NSObject>
@optional
-(void) mnGameVocabularyStatusUpdated:(int) updateStatus;
-(void) mnGameVocabularyDownloadStarted;
-(void) mnGameVocabularyDownloadFinished:(int) downloadStatus;
@end

@interface MNGameVocabulary : NSObject<MNSessionDelegate,MNURLDownloaderDelegate> {
    @private

    MNSession* _session;
    MNDelegateArray* _delegates;
    int              _status;

    NSString* _webServerUrl;
    MNURLDownloader* _versionDownloader;
    MNURLDownloader* _dataDownloader;
}

-(id) initWithSession:(MNSession*) session;
-(void) dealloc;

-(int) getVocabularyStatus;
-(BOOL) startDownload;
-(void) checkForUpdate;
-(NSData*) getFileData:(NSString*) fileName;

-(void) addDelegate:(id<MNGameVocabularyDelegate>) delegate;
-(void) removeDelegate:(id<MNGameVocabularyDelegate>) delegate;

+(BOOL) isUpdateStatusFinal:(int) status;

@end
