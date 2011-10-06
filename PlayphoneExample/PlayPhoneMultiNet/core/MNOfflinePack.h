//
//  MNOfflinePack.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/12/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNURLDownloader.h"

@protocol MNOfflinePackDelegate<NSObject>
@optional

-(void) mnOfflinePackStartPageReadyAtUrl:(NSString*) url;
-(void) mnOfflinePackIsUnavailableBecauseOfError:(NSString*) error;

@end


@interface MNOfflinePack : NSObject<MNURLDownloaderDelegate> {
    @private

    id<MNOfflinePackDelegate> _delegate;
    MNURLDownloader*          _downloader;
    NSString*                 _startPageUrl;
    NSString*                 _webServerUrl;
    NSInteger                 _gameId;

    unsigned int _retrievalState;
    BOOL         _startFromDownloadedPack;
    BOOL         _packUnavailable;
}

-(id) initOfflinePackWithGameId:(NSInteger) gameId andDelegate:(id<MNOfflinePackDelegate>) delegate;
-(NSString*) getStartPageUrl;

-(void) setWebServerUrl:(NSString*) url;

-(BOOL) isPackUnavailable;

@end
