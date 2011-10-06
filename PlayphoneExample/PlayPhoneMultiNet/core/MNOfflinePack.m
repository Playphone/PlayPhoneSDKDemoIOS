//
//  MNOfflinePack.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/12/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNCommon.h"
#import "MNTools.h"
#import "MNZipTool.h"
#import "MNOfflinePack.h"

// 0 - no log messages
// 1 - errors only
// 2 - errors and warnings
// 3 - all from above plus debug
#define MNOFFLINEPACK_VERBOSE 1

#define MNOfflinePackHttpTimeout (600)

#define MNOfflinePackRetrievalStateIdle    (0) // no downloads in progress
#define MNOfflinePackRetrievalStateVersion (1) // downloading remote pack version info
#define MNOfflinePackRetrievalStateData    (2) // downloading data pack

static NSString* MNRootPath                       = @"multinet";
static NSString* MNOfflineDirShortName            = @"web";
static NSString* MNOfflineBackupDirShortName      = @"web.bak";
static NSString* MNOfflineTempDirShortName         = @"web.tmp";
static NSString* MNOfflineDirVersionFileShortName = @"data_game_web_front_version.txt";
static NSString* MNUpdatePackShortName            = @"data_game_web_front.zip";

static NSString* MNRemotePackVersionUrlPath       = @"data_game_web_front_version_txt.php";
static NSString* MNRemotePackDataUrlPath          = @"data_game_web_front_zip.php";

#if MNOFFLINEPACK_VERBOSE > 2
#define MNOFFLINEPACK_LOG_INFO(message) NSLog(@"MNOfflinePack info: %@",(message));
#else
#define MNOFFLINEPACK_LOG_INFO(message) ;
#endif

#if MNOFFLINEPACK_VERBOSE > 1
#define MNOFFLINEPACK_LOG_WARNING(message) NSLog(@"MNOfflinePack warning: %@",(message));
#else
#define MNOFFLINEPACK_LOG_WARNING(message) ;
#endif

#if MNOFFLINEPACK_VERBOSE > 0
#define MNOFFLINEPACK_LOG_ERROR(message) NSLog(@"MNOfflinePack error: %@",(message));
#else
#define MNOFFLINEPACK_LOG_ERROR(message) ;
#endif

static NSString* getMultiNetRootPath (void) {
    NSArray*  paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];

    return [documentsDirectory stringByAppendingPathComponent: MNRootPath];
}

static NSString* getOfflineDirectoryPath (void) {
    return [getMultiNetRootPath() stringByAppendingPathComponent: MNOfflineDirShortName];
}

static NSString* getOfflineDirectoryURLString (void) {
    return [NSString stringWithFormat: @"%@://%@",NSURLFileScheme,getOfflineDirectoryPath()];
}

static NSString* getOfflineDirectoryVersionFilePath (void) {
    return [getOfflineDirectoryPath() stringByAppendingPathComponent: MNOfflineDirVersionFileShortName];
}

static NSString* getOfflineBackupDirectoryPath (void) {
    return [getMultiNetRootPath() stringByAppendingPathComponent: MNOfflineBackupDirShortName];
}

static NSString* getOfflineTempDirectoryPath (void) {
    return [getMultiNetRootPath() stringByAppendingPathComponent: MNOfflineTempDirShortName];
}

static NSString* getUpdatePackPath (void) {
    return [getMultiNetRootPath() stringByAppendingPathComponent: MNUpdatePackShortName];
}

static NSString* getInitialPackPath (void) {
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: MNUpdatePackShortName];
}

static BOOL offlineDirectoryExists (void) {
    return [[NSFileManager defaultManager] fileExistsAtPath: getOfflineDirectoryPath()];
}

static BOOL offlineBackupDirectoryExists (void) {
    return [[NSFileManager defaultManager] fileExistsAtPath: getOfflineBackupDirectoryPath()];
}

static BOOL offlineTempDirectoryExists (void) {
    return [[NSFileManager defaultManager] fileExistsAtPath: getOfflineTempDirectoryPath()];
}

static BOOL updatePackExists (void) {
    return [[NSFileManager defaultManager] fileExistsAtPath: getUpdatePackPath()];
}

static void removeTempFiles (void) {
    NSFileManager* fileManager = [NSFileManager defaultManager];

    [fileManager removeItemAtPath: getOfflineBackupDirectoryPath() error: NULL];
}

static NSURLRequest* createURLRequestWithParams (NSString* prefix, NSInteger gameId) {
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat: @"%d",gameId],
                              @"game_id",
                              [NSString stringWithFormat: @"%d",MNDeviceTypeiPhoneiPod],
                              @"dev_type",
                              MNClientAPIVersion,
                              @"client_ver",
                              [[NSLocale currentLocale] localeIdentifier],
                              @"client_locale",
                              nil];

    NSMutableURLRequest* request = MNGetURLRequestWithPostMethod([NSURL URLWithString: prefix],params);

    [request setTimeoutInterval: MNOfflinePackHttpTimeout];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData];

    return request;
}

static void updateOfflineDirectory (void) {
    NSFileManager* fileManager                = [NSFileManager defaultManager];
    NSString*      offlineTempDirectoryPath   = getOfflineTempDirectoryPath();
    NSString*      offlineDirectoryPath       = getOfflineDirectoryPath();
    NSString*      offlineBackupDirectoryPath = getOfflineBackupDirectoryPath();
    NSString*      updatePackPath             = getUpdatePackPath();
    
    MNOFFLINEPACK_LOG_INFO(@"updating offline directory");

    if (offlineTempDirectoryExists()) {
        MNOFFLINEPACK_LOG_INFO(@"stalled temporary directory found, removing...");
            
        if (![fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL]) {
                // stalled temp directory can not be removed. most safe way to deal with this
                // is to stop update operation and delay update to later time
                MNOFFLINEPACK_LOG_ERROR(@"stalled temporary directory removal failed, update cancelled");
                return;
        }
    }

    MNOFFLINEPACK_LOG_INFO(@"creating temporary directory...");

    if (![fileManager createDirectoryAtPath: offlineTempDirectoryPath withIntermediateDirectories: YES attributes: nil error: nil]) {
        // temporary directory can not be created. stop update, will try next time.
        MNOFFLINEPACK_LOG_ERROR(@"temporary directory creation failed, update cancelled");
        return;
    }

    MNOFFLINEPACK_LOG_INFO(@"unpacking update archive...");

    if (!MNZipToolUnzipFile([offlineTempDirectoryPath UTF8String],[updatePackPath UTF8String])) {
        MNOFFLINEPACK_LOG_ERROR(@"unpack failed, update cancelled");

        [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];
        [fileManager removeItemAtPath: updatePackPath error: NULL];

        return;
    }

    MNOFFLINEPACK_LOG_INFO(@"creating backup...");

    if (offlineDirectoryExists()) {
        if (offlineBackupDirectoryExists()) {
            MNOFFLINEPACK_LOG_INFO(@"stalled backup directory found, removing...");

            if (![fileManager removeItemAtPath: offlineBackupDirectoryPath error: NULL]) {
                // stalled backup directory can not be removed. most safe way to deal with this
                // is to stop update operation and delay update to later time
                MNOFFLINEPACK_LOG_ERROR(@"stalled backup directory removal failed, update cancelled");

                [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];

                return;
            }
        }

        MNOFFLINEPACK_LOG_INFO(@"renaming existing offline directory to .bak...");
            
        if (![fileManager moveItemAtPath: offlineDirectoryPath toPath: offlineBackupDirectoryPath error: NULL]) {
            // backup directory can not be renamed. stop update operation to prevent loss of current offline directory
            MNOFFLINEPACK_LOG_ERROR(@"cannot create backup directory, update cancelled");

            [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];

            return;
        }
    }

    MNOFFLINEPACK_LOG_INFO(@"renaming temporary directory to offline directory");

    if (![fileManager moveItemAtPath: offlineTempDirectoryPath toPath: offlineDirectoryPath error: NULL]) {
        // offline directory can not be setup.
        MNOFFLINEPACK_LOG_ERROR(@"offline directory setup failed, update cancelled");

        [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];
        
        return;
    }

    [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];
    [fileManager removeItemAtPath: updatePackPath error: NULL];
}

static void setupInitialPack (void) {
    NSFileManager* fileManager          = [NSFileManager defaultManager];
    NSString*      offlineTempDirectoryPath = getOfflineTempDirectoryPath();
    NSString*      offlineDirectoryPath = getOfflineDirectoryPath();

    if (offlineTempDirectoryExists()) {
        MNOFFLINEPACK_LOG_INFO(@"stalled temporary directory found, removing...");
        [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];
    }

    MNOFFLINEPACK_LOG_INFO(@"unpacking initial pack");

    if (![fileManager createDirectoryAtPath: offlineTempDirectoryPath withIntermediateDirectories: YES attributes: nil error: nil]) {
        // temporary directory can not be created. stop update, will try next time.
        MNOFFLINEPACK_LOG_ERROR(@"temporary directory creation failed, initial pack setup cancelled");
        return;
    }

    MNOFFLINEPACK_LOG_INFO(@"unpacking initial pack...");

    if (!MNZipToolUnzipFile([offlineTempDirectoryPath UTF8String],[getInitialPackPath() UTF8String])) {
        MNOFFLINEPACK_LOG_ERROR(@"initial pack unpacking failed");
        // try to remove partialy unpacked directory
        [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];

        return;
    }

    if (![fileManager moveItemAtPath: offlineTempDirectoryPath toPath: offlineDirectoryPath error: NULL]) {
        // offline directory can not be setup.
        MNOFFLINEPACK_LOG_ERROR(@"offline directory setup failed, initial pack setup cancelled");
        [fileManager removeItemAtPath: offlineTempDirectoryPath error: NULL];
    }
}

static NSString* getLocalOfflinePackVersion (void) {
    NSString* version = [NSString stringWithContentsOfFile: getOfflineDirectoryVersionFilePath() encoding: NSASCIIStringEncoding error: NULL];

    if (version != nil) {
        version = [version stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    return version;
}

@interface MNOfflinePack()
-(void) requestRemotePackVersion;
-(void) downloadPack;
-(void) dealloc;

// MNURLDownloaderDelegate protocol
-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data;
-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error;

@end


@implementation MNOfflinePack

-(id) initOfflinePackWithGameId:(NSInteger) gameId andDelegate:(id<MNOfflinePackDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _delegate     = delegate;
        _downloader   = [[MNURLDownloader alloc] init];
        _startPageUrl = nil;
        _webServerUrl = nil;
        _gameId       = gameId;

        _retrievalState          = MNOfflinePackRetrievalStateIdle;
        _startFromDownloadedPack = NO;
        _packUnavailable         = NO;

        removeTempFiles();
    }

    return self;
}

-(void) dealloc {
    removeTempFiles();

    [_webServerUrl release];
    [_startPageUrl release];

    [_downloader release];

    [super dealloc];
}

-(NSString*) getStartPageUrl {
    if (_startPageUrl == nil) {
        if (updatePackExists()) {
            updateOfflineDirectory();
        }

        if (!offlineDirectoryExists()) {
            setupInitialPack();
        }

        if (offlineDirectoryExists()) {
            _packUnavailable = NO;
            _startPageUrl = [getOfflineDirectoryURLString() retain];
        }
        else {
            _startFromDownloadedPack = YES;
        }
    }

    return _startPageUrl;
}

-(void) setWebServerUrl:(NSString*) url {
    if (_webServerUrl == nil && url != nil) {
        // start update procedure

        _webServerUrl = [url copy];

        if (getLocalOfflinePackVersion() == nil) {
            [self downloadPack];
        }
        else {
            [self requestRemotePackVersion];
        }
    }
}

-(void) requestRemotePackVersion {
    if (_retrievalState == MNOfflinePackRetrievalStateIdle) {
        MNOFFLINEPACK_LOG_INFO(@"retrieving remote pack version");

        _retrievalState = MNOfflinePackRetrievalStateVersion;

        NSURLRequest* request = createURLRequestWithParams
                                 ([NSString stringWithFormat: @"%@/%@",_webServerUrl,MNRemotePackVersionUrlPath],
                                  _gameId);

        [_downloader loadRequest: request delegate: self];
    }
    else {
        MNOFFLINEPACK_LOG_WARNING(@"trying to get remote pack version from invalid internal state");
    }
}

-(void) downloadPack {
    if (_retrievalState == MNOfflinePackRetrievalStateIdle) {
        MNOFFLINEPACK_LOG_INFO(@"retrieving remote pack data");

        _retrievalState = MNOfflinePackRetrievalStateData;

        NSURLRequest* request = createURLRequestWithParams
                                 ([NSString stringWithFormat: @"%@/%@",_webServerUrl,MNRemotePackDataUrlPath],
                                  _gameId);

        [_downloader loadRequest: request delegate: self];
    }
    else {
        MNOFFLINEPACK_LOG_WARNING(@"trying to get remote pack data from invalid internal state");
    }
}

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    if (_retrievalState == MNOfflinePackRetrievalStateVersion) {
        MNOFFLINEPACK_LOG_INFO(@"remote version retrieved");

        _retrievalState = MNOfflinePackRetrievalStateIdle;

        NSString* remoteVersion = [[[NSString alloc] initWithBytes: [data bytes]
                                                     length: [data length]
                                                     encoding: NSASCIIStringEncoding] autorelease];

        remoteVersion = [remoteVersion stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSString* localVersion = getLocalOfflinePackVersion();

        if (![localVersion isEqualToString: remoteVersion]) {
            MNOFFLINEPACK_LOG_INFO(@"local and remote versions differ - downloading data pack");

            [self downloadPack];
        }
    }
    else if (_retrievalState == MNOfflinePackRetrievalStateData) {
        MNOFFLINEPACK_LOG_INFO(@"update pack downloaded successfully");

        _retrievalState = MNOfflinePackRetrievalStateIdle;

        if ([data writeToFile: getUpdatePackPath() atomically: YES]) {
            MNOFFLINEPACK_LOG_INFO(@"downloaded update pack saved");

            if (_startFromDownloadedPack) {
                _startFromDownloadedPack = NO;

                updateOfflineDirectory();

                if (_startPageUrl == nil) {
                    if (offlineDirectoryExists()) {
                        _startPageUrl = [getOfflineDirectoryURLString() retain];
                        
                        if ([_delegate respondsToSelector: @selector(mnOfflinePackStartPageReadyAtUrl:)]) {
                            [_delegate mnOfflinePackStartPageReadyAtUrl: _startPageUrl];
                        }
                    }
                    else {
                        _packUnavailable = YES;

                        if ([_delegate respondsToSelector: @selector(mnOfflinePackIsUnavailableBecauseOfError:)]) {
                            [_delegate mnOfflinePackIsUnavailableBecauseOfError: @"offline data unpacking failed"];
                        }
                    }
                }
            }
        }
        else {
            MNOFFLINEPACK_LOG_ERROR(@"downloaded update pack save failed");

            if (_startFromDownloadedPack) {
                _packUnavailable = YES;
                
                if ([_delegate respondsToSelector: @selector(mnOfflinePackIsUnavailableBecauseOfError:)]) {
                    [_delegate mnOfflinePackIsUnavailableBecauseOfError: @"offline data unpacking failed"];
                }
            }
        }
    }
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    MNOFFLINEPACK_LOG_ERROR(error);

    if (_retrievalState == MNOfflinePackRetrievalStateData && _startFromDownloadedPack) {
        if ([_delegate respondsToSelector: @selector(mnOfflinePackIsUnavailableBecauseOfError:)]) {
            [_delegate mnOfflinePackIsUnavailableBecauseOfError: error.message];
        }

        _startFromDownloadedPack = NO;
        _packUnavailable         = YES;
    }

    _retrievalState = MNOfflinePackRetrievalStateIdle;
}

-(BOOL) isPackUnavailable {
    return _packUnavailable;
}

@end
