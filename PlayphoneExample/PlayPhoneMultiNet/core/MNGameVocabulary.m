//
//  MNGameVocabulary.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import "MNGameVocabulary.h"
#import "MNTools.h"
#import "MNZipTool.h"
#import "MNSessionInternal.h"

#define MN_GV_HTTP_TIMEOUT (10 * 60)

static NSString* MN_GV_DATA_FILE_NAME = @"data_game_vocabulary.zip";
static NSString* MN_GV_DATA_TEMP_FILE_NAME = @"data_game_vocabulary.zip.tmp";
static NSString* MN_GV_DATA_BAK_FILE_NAME = @"data_game_vocabulary.zip.bak";
static NSString* MN_GV_DATA_FILE_URL = @"data_game_vocabulary_zip.php";
static NSString* MN_GV_VERSION_FILE_NAME = @"data_game_vocabulary_version.txt";
static NSString* MN_GV_VERSION_FILE_URL = @"data_game_vocabulary_version_txt.php";
static NSString* MN_ROOT_PATH = @"multinet";
static NSString* MN_BUNDLE_DIR_NAME = @"MN.bundle";

@interface MNGameVocabulary()
-(void) checkWebServerUrl;
-(void) setVocabularyStatus:(int) newStatus;
-(NSURLRequest*) requestWithUrl:(NSString*) url;
-(void) onRemoteVersionArrived:(NSString*) remoteVersion;
-(void) onUpdatedDataReceived:(NSData*) data;
-(NSString*) getLocalVersion;

-(void) mnSessionConfigLoaded;
-(void) mnSessionConfigLoadStarted;
-(void) mnSessionErrorOccurred:(MNErrorInfo*) error;

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data;
-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error;

@end

//FIXME: copy of the same func in MNOfflinePack, have to move it to MNTools...
static NSString* getMultiNetRootPath (void) {
    NSArray*  paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];

    return [documentsDirectory stringByAppendingPathComponent: MN_ROOT_PATH];
}

static NSString* MNGameVocabularyDataFileGetName () {
    return [getMultiNetRootPath() stringByAppendingPathComponent: MN_GV_DATA_FILE_NAME];
}

static BOOL MNGameVocabularyDataFileExists () {
    return [[NSFileManager defaultManager] fileExistsAtPath: MNGameVocabularyDataFileGetName()];
}

static NSString* MNGameVocabularyDataTempFileGetName () {
    return [getMultiNetRootPath() stringByAppendingPathComponent: MN_GV_DATA_TEMP_FILE_NAME];
}

static NSString* MNGameVocabularyDataBakFileGetName () {
    return [getMultiNetRootPath() stringByAppendingPathComponent: MN_GV_DATA_BAK_FILE_NAME];
}

static NSString* MNGameVocabularyBundledFileGetName () {
    return [[[[NSBundle mainBundle] bundlePath]
             stringByAppendingPathComponent: MN_BUNDLE_DIR_NAME]
            stringByAppendingPathComponent: MN_GV_DATA_FILE_NAME];
}

static BOOL MNGameVocabularyBundledFileExists () {
    return [[NSFileManager defaultManager] fileExistsAtPath: MNGameVocabularyBundledFileGetName()];
}

@implementation MNGameVocabulary

-(id) initWithSession:(MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session = session;
        _delegates = [[MNDelegateArray alloc] init];
        _status = MN_GV_UPDATE_STATUS_UNKNOWN;

        [_session addDelegate: self];

        _webServerUrl      = nil;
        _dataDownloader    = nil;
        _versionDownloader = nil;
    }

    return self;
}

-(void) dealloc {
    [_session removeDelegate: self];
    [_webServerUrl release];
    [_delegates release];

    [super dealloc];
}

-(int) getVocabularyStatus {
    return _status;
}

-(BOOL) startDownload {
    [self checkWebServerUrl];

    if (_status != MN_GV_UPDATE_STATUS_NEED_DOWNLOAD || _webServerUrl == nil) {
        return NO;
    }

    [self setVocabularyStatus: MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS];

    NSURLRequest* request = [self requestWithUrl: [NSString stringWithFormat: @"%@/%@",_webServerUrl,MN_GV_DATA_FILE_URL]];

    if (_dataDownloader != nil) {
        [_dataDownloader release];
    }

    _dataDownloader = [[MNURLDownloader alloc] init];

    [_dataDownloader loadRequest: request delegate: self];

    return YES;
}

-(void) checkForUpdate {
    if (_status == MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS ||
        _status == MN_GV_UPDATE_STATUS_CHECK_IN_PROGRESS ||
        _status == MN_GV_UPDATE_STATUS_NEED_DOWNLOAD) {
        return;
    }

    [self setVocabularyStatus: MN_GV_UPDATE_STATUS_CHECK_IN_PROGRESS];

    [self checkWebServerUrl];

    if (_webServerUrl != nil) {
        [self setVocabularyStatus: MN_GV_UPDATE_STATUS_CHECK_IN_PROGRESS];

        if (_versionDownloader != nil) {
            [_versionDownloader release];
        }

        _versionDownloader = [[MNURLDownloader alloc] init];

        NSURLRequest* request = [self requestWithUrl: [NSString stringWithFormat: @"%@/%@",_webServerUrl,MN_GV_VERSION_FILE_URL]];

        [_versionDownloader loadRequest: request delegate: self];
    }
    else {
        [self setVocabularyStatus: MN_GV_UPDATE_STATUS_UNKNOWN];
    }
}

-(NSData*) getFileData:(NSString*) fileName {
    NSData* data = nil;
    NSString* zipFileName = nil;

    if (MNGameVocabularyDataFileExists()) {
        zipFileName = MNGameVocabularyDataFileGetName();
    }
    else if (MNGameVocabularyBundledFileExists()) {
        zipFileName = MNGameVocabularyBundledFileGetName();
    }

    if (zipFileName != nil) {
        void* buffer;
        size_t size;

        if (MNZipToolExtractFileData(&buffer,&size,[zipFileName UTF8String],[fileName UTF8String]) == MNZIP_OK) {
            data = [NSData dataWithBytes: buffer length: size];

            free(buffer);
        }
    }

    return data;
}

-(void) addDelegate:(id<MNGameVocabularyDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNGameVocabularyDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

+(BOOL) isUpdateStatusFinal:(int) status {
    return status > -100;
}

-(void) checkWebServerUrl {
    if (_webServerUrl == nil) {
        _webServerUrl = [[_session getWebServerURL] copy];
    }
}

-(void) setVocabularyStatus:(int) newStatus {
    _status = newStatus;

    [_delegates beginCall];

    for (id<MNGameVocabularyDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnGameVocabularyStatusUpdated:)]) {
            [delegate mnGameVocabularyStatusUpdated: newStatus];
        }
    }

    [_delegates endCall];
}

-(NSURLRequest*) requestWithUrl:(NSString*) url {
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat: @"%d",[_session getGameId]],
                            @"game_id",
                            [NSString stringWithFormat: @"%d",MNDeviceTypeiPhoneiPod],
                            @"dev_type",
                            MNClientAPIVersion,
                            @"client_ver",
                            [[NSLocale currentLocale] localeIdentifier],
                            @"client_locale",
                            nil];

    NSMutableURLRequest* request = MNGetURLRequestWithPostMethod([NSURL URLWithString: url],params);

    [request setTimeoutInterval: MN_GV_HTTP_TIMEOUT];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData];

    return request;
}

-(void) onRemoteVersionArrived:(NSString*) remoteVersion {
    if (remoteVersion == nil || [remoteVersion length] == 0) {
        [self setVocabularyStatus: MN_GV_UPDATE_STATUS_UNKNOWN];
    }
    else {
        NSString* localVersion = [self getLocalVersion];

        if ([localVersion isEqualToString: remoteVersion]) {
            [self setVocabularyStatus: MN_GV_UPDATE_STATUS_UP_TO_DATE];
        }
        else {
            [self setVocabularyStatus: MN_GV_UPDATE_STATUS_NEED_DOWNLOAD];
        }
    }
}

-(void) onUpdatedDataReceived:(NSData*) data {
    BOOL           ok               = YES;
    BOOL           backupOk         = NO;
    NSFileManager* fileManager      = [NSFileManager defaultManager];
    NSString*      dataFilePath     = getMultiNetRootPath();
    NSString*      dataFileName     = MNGameVocabularyDataFileGetName();
    NSString*      dataFileTempName = MNGameVocabularyDataTempFileGetName();
    NSString*      dataFileBakName  = MNGameVocabularyDataBakFileGetName();

    if (![fileManager fileExistsAtPath: dataFilePath]) {
        ok = [fileManager createDirectoryAtPath: dataFilePath withIntermediateDirectories: YES attributes: nil error: nil];
    }

    if (ok) {
        ok = [data writeToFile: dataFileTempName atomically: YES];
    }

    if (ok) {
        if ([fileManager fileExistsAtPath: dataFileName]) {
            if ([fileManager fileExistsAtPath: dataFileBakName]) {
                [fileManager removeItemAtPath: dataFileBakName error: NULL];
            }

            backupOk = ok = [fileManager moveItemAtPath: dataFileName toPath: dataFileBakName error: NULL];
        }
    }

    if (ok) {
        ok = [fileManager moveItemAtPath: dataFileTempName toPath: dataFileName error: NULL];

        if (!ok) {
            if (backupOk) {
                [fileManager moveItemAtPath: dataFileBakName toPath: dataFileName error: NULL];
            }
        }
    }

    if ([fileManager fileExistsAtPath: dataFileBakName]) {
        [fileManager removeItemAtPath: dataFileBakName error: NULL];
    }

    if ([fileManager fileExistsAtPath: dataFileTempName]) {
        [fileManager removeItemAtPath: dataFileTempName error: NULL];
    }

    [_delegates beginCall];

    for (id<MNGameVocabularyDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(mnGameVocabularyDownloadFinished:)]) {
            [delegate mnGameVocabularyDownloadFinished: ok ? MN_GV_DOWNLOAD_SUCCESS : MN_GV_DOWNLOAD_FAIL];
        }
    }

    [_delegates endCall];

    [self setVocabularyStatus: ok ? MN_GV_UPDATE_STATUS_UP_TO_DATE : MN_GV_UPDATE_STATUS_NEED_DOWNLOAD];
}

-(NSString*) getLocalVersion {
    NSData* data = [self getFileData: MN_GV_VERSION_FILE_NAME];

    if (data == nil) {
        return @"";
    }
    else {
        return [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    }
}

-(void) mnSessionConfigLoaded {
    NSString* newWebServerUrl = [_session getWebServerURL];

    if (newWebServerUrl != nil) {
        [_webServerUrl release];

        _webServerUrl = [newWebServerUrl copy];
    }

    NSString* remoteVersion = [_session getConfigData].gameVocabularyVersion;

    [self onRemoteVersionArrived: (remoteVersion != nil ? remoteVersion : @"")];
}

-(void) mnSessionConfigLoadStarted {
    [self setVocabularyStatus: MN_GV_UPDATE_STATUS_CHECK_IN_PROGRESS];
}

-(void) mnSessionErrorOccurred:(MNErrorInfo*) error {
    if (error.actionCode == MNErrorInfoActionCodeLoadConfig) {
        [self setVocabularyStatus: MN_GV_UPDATE_STATUS_UNKNOWN];
    }
}

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    if (downloader == _versionDownloader) {
        [self onRemoteVersionArrived: [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease]];
    }
    else if (downloader == _dataDownloader) {
        [self onUpdatedDataReceived: data];
    }
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    if (downloader == _versionDownloader) {
        if (_status != MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS) {
            [self setVocabularyStatus: MN_GV_UPDATE_STATUS_UNKNOWN];
        }
    }
    else if (downloader == _dataDownloader) {
        [_delegates beginCall];

        for (id<MNGameVocabularyDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(mnGameVocabularyDownloadFinished:)]) {
                [delegate mnGameVocabularyDownloadFinished: MN_GV_DOWNLOAD_FAIL];
            }
        }

        [_delegates endCall];

        [self setVocabularyStatus: MN_GV_UPDATE_STATUS_NEED_DOWNLOAD];
    }
}

@end
