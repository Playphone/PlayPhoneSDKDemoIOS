//
//  MNConfigData.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/5/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNTools.h"
#import "MNConfigData.h"

static NSString* MNConfigParamSmartFoxServerAddr = @"SmartFoxServerAddr";
static NSString* MNConfigParamSmartFoxServerPort = @"SmartFoxServerPort";
static NSString* MNConfigParamBlueBoxServerAddr = @"BlueBoxServerAddr";
static NSString* MNConfigParamBlueBoxServerPort = @"BlueBoxServerPort";
static NSString* MNConfigParamSmartConnectMode = @"BlueBoxSmartConnect";

static NSString* MNConfigParamMultiNetWebServerURL = @"MultiNetWebServerURL";
static NSString* MNConfigParamFacebookApiKey = @"FacebookApiKey";
static NSString* MNConfigParamFacebookAppId = @"FacebookAppId";
static NSString* MNConfigParamFacebookSSOMode = @"FacebookSSOMode";

static NSString* MNConfigParamLaunchTrackerUrl = @"LaunchTrackerURL";
static NSString* MNConfigParamInstallTrackerUrl = @"InstallTrackerURL";
static NSString* MNConfigParamShutdownTrackerUrl = @"ShutdownTrackerURL";
static NSString* MNConfigParamBeaconTrackerUrl = @"BeaconTrackerURL";
static NSString* MNConfigParamEnterForegroundTrackerUrl = @"EnterForegroundTrackerURL";
static NSString* MNConfigParamEnterBackgroundTrackerUrl = @"EnterBackgroundTrackerURL";
static NSString* MNConfigParamGameVocabularyVersion = @"GameVocabularyVersion";
static NSString* MNConfigParamTryFastResumeMode = @"TryFastResumeMode";
static NSString* MNConfigParamAllowReadWiFiMAC = @"AllowReadWiFiMAC";
static NSString* MNConfigParamUseInstallIdInsteadOfUDID = @"UseInstallIdInsteadOfUDID";

static BOOL MNConfigDataGetParamString (NSString** value, NSDictionary* params, NSString* key) {
    *value = (NSString*)[params objectForKey: key];

    return *value != nil;
}

static BOOL MNConfigDataGetParamInteger (NSInteger* value, NSDictionary* params, NSString* key) {
    NSString* str = (NSString*)[params objectForKey: key];

    if (str != nil) {
        return MNStringScanInteger(value,str);
    }
    else {
        return NO;
    }
}

static BOOL MNConfigDataGetParamBoolean (BOOL* value, NSDictionary* params, NSString* key) {
    NSString* str = (NSString*)[params objectForKey: key];

    if (str != nil) {
        if ([str isEqualToString: @"true"]) {
            *value = YES;
        }
        else if ([str isEqualToString: @"false"]) {
            *value = NO;
        }
        else {
            return NO;
        }

        return YES;
    }
    else {
        return NO;
    }
}



@interface  MNConfigData()

-(void) dealloc;

/* MNURLDownloader protocol */

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data;
-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error;

@end


@implementation MNConfigData

@synthesize smartFoxAddr     = _smartFoxAddr;
@synthesize smartFoxPort     = _smartFoxPort;
@synthesize blueBoxAddr      = _blueBoxAddr;
@synthesize blueBoxPort      = _blueBoxPort;
@synthesize smartConnect     = _smartConnect;
@synthesize webServerURL     = _webServerURL;
@synthesize facebookAPIKey   = _facebookAPIKey;
@synthesize facebookAppId    = _facebookAppId;
@synthesize facebookSSOMode  = _facebookSSOMode;
@synthesize launchTrackerUrl = _launchTrackerUrl;
@synthesize installTrackerUrl = _installTrackerUrl;
@synthesize shutdownTrackerUrl = _shutdownTrackerUrl;
@synthesize beaconTrackerUrl = _beaconTrackerUrl;
@synthesize enterForegroundTrackerUrl = _enterForegroundTrackerUrl;
@synthesize enterBackgroundTrackerUrl = _enterBackgroundTrackerUrl;
@synthesize gameVocabularyVersion = _gameVocabularyVersion;
@synthesize tryFastResumeMode = _tryFastResumeMode;
@synthesize allowReadWiFiMAC  = _allowReadWiFiMAC;
@synthesize useInstallIdInsteadOfUDID = _useInstallIdInsteadOfUDID;

-(id) initWithConfigRequest:(NSURLRequest*) configRequest {
    self = [super init];

    if (self != nil) {
        _configRequest = [configRequest retain];

        _loaded = NO;
        _downloader = [[MNURLDownloader alloc] init];
    }

    return self;
}

-(void) dealloc {
    [_downloader release];
    [_smartFoxAddr release];
    [_blueBoxAddr release];
    [_webServerURL release];
    [_facebookAPIKey release]; 
    [_facebookAppId release]; 
    [_launchTrackerUrl release];
    [_installTrackerUrl release];
    [_shutdownTrackerUrl release];
    [_beaconTrackerUrl release];
    [_enterForegroundTrackerUrl release];
    [_enterBackgroundTrackerUrl release];
    [_gameVocabularyVersion release];
    [_allowReadWiFiMAC release];
    [_configRequest release];

    [super dealloc];
}

-(BOOL) isLoaded {
    return _loaded;
}

-(void) clear {
    [_downloader cancel];
    _loaded = NO;
    self.smartFoxAddr   = nil;
    self.smartFoxPort   = 0;
    self.blueBoxAddr    = nil;
    self.blueBoxPort    = 0;
    self.smartConnect   = NO;
    self.webServerURL   = nil;
    self.facebookAPIKey = nil;
    self.facebookAppId  = nil;
    self.facebookSSOMode = 0;
    self.launchTrackerUrl = nil;
    self.installTrackerUrl = nil;
    self.shutdownTrackerUrl = nil;
    self.beaconTrackerUrl = nil;
    self.enterForegroundTrackerUrl = nil;
    self.enterBackgroundTrackerUrl = nil;
    self.gameVocabularyVersion = nil;
    self.tryFastResumeMode = 0;
    self.allowReadWiFiMAC = nil;
    self.useInstallIdInsteadOfUDID = 0;
}

-(void) loadWithDelegate:(id<MNConfigDataDelegate>) delegate {
    _loaded   = NO;
    _delegate = delegate;

    [_downloader loadRequest: _configRequest delegate: self];
}

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    NSString* str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSDictionary* params;
    BOOL ok;

    ok = str != nil;

    if (ok) {
        params = MNDictionaryFromKeyValueText(str);

        ok = params != nil;
    }

    NSString* strParam;
    NSInteger intParam;
    BOOL      boolParam;

    if (ok) {
        ok = MNConfigDataGetParamString(&strParam,params,MNConfigParamSmartFoxServerAddr);
    }

    if (ok) {
        self.smartFoxAddr = strParam;

        ok = MNConfigDataGetParamInteger(&intParam,params,MNConfigParamSmartFoxServerPort);
    }

    if (ok) {
        self.smartFoxPort = intParam;

        ok = MNConfigDataGetParamString(&strParam,params,MNConfigParamBlueBoxServerAddr);
    }

    if (ok) {
        self.blueBoxAddr = strParam;

        ok = MNConfigDataGetParamInteger(&intParam,params,MNConfigParamBlueBoxServerPort);
    }

    if (ok) {
        self.blueBoxPort = intParam;

        ok = MNConfigDataGetParamBoolean(&boolParam,params,MNConfigParamSmartConnectMode);
    }

    if (ok) {
        self.smartConnect = boolParam;

        ok = MNConfigDataGetParamString(&strParam,params,MNConfigParamMultiNetWebServerURL);
    }

    if (ok) {
        self.webServerURL = strParam;

        ok = MNConfigDataGetParamString(&strParam,params,MNConfigParamFacebookApiKey);
    }

    if (ok) {
        self.facebookAPIKey = strParam;

        ok = MNConfigDataGetParamString(&strParam,params,MNConfigParamFacebookAppId);
    }

    if (ok) {
        self.facebookAppId = strParam;

        if (!MNConfigDataGetParamInteger(&_facebookSSOMode,params,MNConfigParamFacebookSSOMode)) {
            _facebookSSOMode = 0;
        }

        self.launchTrackerUrl          = (NSString*)[params objectForKey: MNConfigParamLaunchTrackerUrl];
        self.installTrackerUrl         = (NSString*)[params objectForKey: MNConfigParamInstallTrackerUrl];
        self.shutdownTrackerUrl        = (NSString*)[params objectForKey: MNConfigParamShutdownTrackerUrl];
        self.beaconTrackerUrl          = (NSString*)[params objectForKey: MNConfigParamBeaconTrackerUrl];
        self.enterForegroundTrackerUrl = (NSString*)[params objectForKey: MNConfigParamEnterForegroundTrackerUrl];
        self.enterBackgroundTrackerUrl = (NSString*)[params objectForKey: MNConfigParamEnterBackgroundTrackerUrl];
        self.gameVocabularyVersion     = (NSString*)[params objectForKey: MNConfigParamGameVocabularyVersion];

        if (!MNConfigDataGetParamInteger(&_tryFastResumeMode,params,MNConfigParamTryFastResumeMode)) {
            _tryFastResumeMode = 0;
        }

        self.allowReadWiFiMAC = (NSString*)[params objectForKey: MNConfigParamAllowReadWiFiMAC];

        if (!MNConfigDataGetParamInteger(&_useInstallIdInsteadOfUDID,params,MNConfigParamUseInstallIdInsteadOfUDID)) {
            _useInstallIdInsteadOfUDID = 0;
        }

        _loaded = YES;

        [_delegate mnConfigDataLoaded: self];
    }
    else {
        [_delegate mnConfigDataLoadDidFailWithError: @"Configuration loading failed"];
    }

    [str release];
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    [_delegate mnConfigDataLoadDidFailWithError: error.message];
}

@end
