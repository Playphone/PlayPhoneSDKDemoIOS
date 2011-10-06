//
//  MNConfigData.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/5/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNURLDownloader.h"

@protocol MNConfigDataDelegate;

@interface MNConfigData : NSObject<MNURLDownloaderDelegate> {
    @private

    BOOL      _loaded;
    NSString* _smartFoxAddr;
    NSInteger _smartFoxPort;
    NSString* _blueBoxAddr;
    NSInteger _blueBoxPort;
    BOOL      _smartConnect;
    NSString* _webServerURL;
    NSString* _facebookAPIKey;
    NSString* _facebookAppId;
    NSString* _launchTrackerUrl;
    NSString* _shutdownTrackerUrl;
    NSString* _beaconTrackerUrl;
    NSString* _enterForegroundTrackerUrl;
    NSString* _enterBackgroundTrackerUrl;
    NSString* _gameVocabularyVersion;

    NSURLRequest* _configRequest;
    MNURLDownloader* _downloader;
    id<MNConfigDataDelegate> _delegate;
}

@property (nonatomic,retain) NSString* smartFoxAddr;
@property (nonatomic,assign) NSInteger smartFoxPort;
@property (nonatomic,retain) NSString* blueBoxAddr;
@property (nonatomic,assign) NSInteger blueBoxPort;
@property (nonatomic,assign) BOOL      smartConnect;
@property (nonatomic,retain) NSString* webServerURL;
@property (nonatomic,retain) NSString* facebookAPIKey;
@property (nonatomic,retain) NSString* facebookAppId;
@property (nonatomic,retain) NSString* launchTrackerUrl;
@property (nonatomic,retain) NSString* shutdownTrackerUrl;
@property (nonatomic,retain) NSString* beaconTrackerUrl;
@property (nonatomic,retain) NSString* enterForegroundTrackerUrl;
@property (nonatomic,retain) NSString* enterBackgroundTrackerUrl;
@property (nonatomic,retain) NSString* gameVocabularyVersion;

-(id) initWithConfigRequest:(NSURLRequest*) configRequest;
-(BOOL) isLoaded;
-(void) clear;

-(void) loadWithDelegate:(id<MNConfigDataDelegate>) delegate;

@end


@protocol MNConfigDataDelegate<NSObject>

-(void) mnConfigDataLoaded:(MNConfigData*) configData;
-(void) mnConfigDataLoadDidFailWithError:(NSString*) error;

@end
