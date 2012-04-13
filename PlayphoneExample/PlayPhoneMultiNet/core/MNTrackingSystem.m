//
//  MNTrackingSystem.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MNTools.h"
#import "MNHardwareInfo.h"
#import "MNCommon.h"
#import "MNSession.h"
#import "MNSessionInternal.h"

#import "MNTrackingSystem.h"

#define MNTrackingRunLoopTimeoutInSeconds (5)

static NSString* MNInstallTrackerResponseTimestampVarName = @"app.install.track.done";
static NSString* MNInstallTrackerResponseTextVarName      = @"app.install.track.response";

static NSString* ngStringGetMetaVarName (NSString* string) {
    if ([string hasPrefix: @"{"] && [string hasSuffix: @"}"]) {
        return [string substringWithRange: NSMakeRange(1,[string length] - 2)];
    }
    else {
        return nil;
    }
}

static void runRunLoopOnce (void) {
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];

    [runLoop runMode: NSDefaultRunLoopMode beforeDate: [NSDate dateWithTimeIntervalSinceNow: MNTrackingRunLoopTimeoutInSeconds]];
}

static void setupTrackingVar (NSMutableDictionary* vars, NSString* name, NSString* value) {
    if (value == nil) {
        return;
    }
    
    [vars setObject: value forKey: name];
    [vars setObject: MNStringGetMD5String(value) forKey: [NSString stringWithFormat: @"@%@", name]];
}


@interface MNTrackingDynamicVar : NSObject {
@private

    NSString* _name;
    BOOL      _useHash;
}

@property (nonatomic,retain) NSString* name;
@property (nonatomic,assign) BOOL      useHash;

-(id) initWithName:(NSString*) name andHashUsage:(BOOL) useHash;

@end


@implementation MNTrackingDynamicVar

@synthesize name = _name;
@synthesize useHash = _useHash;

-(id) initWithName:(NSString *)name andHashUsage:(BOOL)useHash {
    self = [super init];
    
    if (self != nil) {
        _name    = [name retain];
        _useHash = useHash;
    }
    
    return self;
}

-(void) dealloc {
    [_name release];

    [super dealloc];
}
@end


static void addDynamicVars (NSMutableData* postData, NSArray* vars, NSString* value) {
    if (vars == nil) {
        return;
    }
    
    if (value == nil) {
        value = @"";
    }
    
    NSString* hashedValue = nil;
    
    for (MNTrackingDynamicVar* var in vars) {
        if (var.useHash) {
            if (hashedValue == nil) {
                hashedValue = MNStringGetMD5String(value);
            }
            
            MNPostRequestBodyAddParam(postData,var.name,hashedValue,NO,YES);
        }
        else {
            MNPostRequestBodyAddParam(postData,var.name,value,NO,YES);
        }
    }
}

@interface MNInstallTracker : NSObject<MNTrackingSystemDelegate>
{
@private

    MNSession* _session;
    BOOL       _requestInProgress;
    BOOL       _installTracked;
}

-(id)   init;
-(void) trackInstallWithUrlTemplate:(NSString*) urlTemplate
                   withTrackingVars:(NSDictionary*) trackingVars
                         forSession:(MNSession*) session;

@end


@interface MNTrackingUrlTemplate : NSObject<MNURLDownloaderDelegate>
{
@private

    NSString*       urlString;
    NSMutableData*  postBodyData;

    NSMutableArray* userSIdVars;
    NSMutableArray* userIdVars;
    NSMutableArray* beaconActionVars;
    NSMutableArray* beaconDataVars;
    NSMutableArray* enterForegroundCountVars;
    NSMutableArray* foregroundTimeVars;

    id<MNTrackingSystemDelegate> _delegate;
}

-(id) initWithUrlTemplate:(NSString*) urlTemplate
        trackingVariables:(NSDictionary*) trackingVariables
              andDelegate:(id<MNTrackingSystemDelegate>) delegate;
-(BOOL) sendSimpleRequestWithSession:(MNSession*) session;

-(BOOL) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData withSession:(MNSession*) session;
-(BOOL) sendBeacon:(NSString*) beaconAction
              data:(NSString*) beaconData
       withSession:(MNSession*) session
  andCallSeqNumber:(long) callSeqNumber;

-(void) prepareUrlTemplate:(NSString*) urlTemplate usingTrackingVariables:(NSDictionary*) trackingVariables;
-(void) clearData;

@end


@implementation MNAppBeaconResponse

@synthesize responseText  = _responseText;
@synthesize callSeqNumber = _callSeqNumber;

-(id) initWithResponseText:(NSString*) responseText andCallSeqNumber:(long) callSeqNumber {
    self = [super init];

    if (self != nil) {
        _responseText  = [responseText retain];
        _callSeqNumber = callSeqNumber;
    }

    return self;
}

-(void) dealloc {
    [_responseText release];

    [super dealloc];
}

@end


@implementation MNInstallTracker

-(id)   init {
    self = [super init];

    if (self != nil) {
        _session           = nil;
        _requestInProgress = NO;
        _installTracked    = NO;
    }

    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) shutdown {
    _session = nil;
}

-(void) trackInstallWithUrlTemplate:(NSString*) urlTemplate
                   withTrackingVars:(NSDictionary*) trackingVars
                         forSession:(MNSession*) session {
    if (_requestInProgress || _installTracked) {
        return;
    }

    NSString* timestamp = [session varStorageGetValueForVariable: MNInstallTrackerResponseTimestampVarName];

    if (timestamp != nil) {
        _installTracked = YES;

        return;
    }

    _requestInProgress = YES;
    _session           = session; // no retain

    MNTrackingUrlTemplate* _installTrackingUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate trackingVariables: trackingVars andDelegate: self];

    [_installTrackingUrlTemplate sendSimpleRequestWithSession: session];
    [_installTrackingUrlTemplate autorelease];
}

-(void) appBeaconDidReceiveResponse:(MNAppBeaconResponse*) response {
    NSString* responseText = response.responseText;

    if (responseText != nil) {
        if (_session != nil) {
            [_session varStorageSetValue: [NSString stringWithFormat: @"%lld",(long long)time(NULL)]
                             forVariable: MNInstallTrackerResponseTimestampVarName];

            [_session varStorageSetValue: MNGetURLEncodedString(responseText)
                             forVariable: MNInstallTrackerResponseTextVarName];

            _installTracked = YES;
        }
    }

    _requestInProgress = false;
    _session           = nil;
}

@end


@interface MNTrackingSystemDelegateWrapper : NSObject<MNTrackingSystemDelegate> {
@private
    id<MNTrackingSystemDelegate> _delegate;
}

@property (nonatomic,assign) id<MNTrackingSystemDelegate> delegate;

-(void) appBeaconDidReceiveResponse:(MNAppBeaconResponse*) response;

@end


@implementation MNTrackingSystemDelegateWrapper

@synthesize delegate = _delegate;

-(void) appBeaconDidReceiveResponse:(MNAppBeaconResponse*) response {
    [_delegate appBeaconDidReceiveResponse: response];
}

@end


@implementation MNTrackingUrlTemplate

-(id) initWithUrlTemplate:(NSString*) urlTemplate
        trackingVariables:(NSDictionary*) trackingVariables
              andDelegate:(id<MNTrackingSystemDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        urlString    = nil;
        postBodyData = nil;

        userSIdVars = nil;
        userIdVars  = nil;
        beaconActionVars = nil;
        beaconDataVars   = nil;
        enterForegroundCountVars = nil;
        foregroundTimeVars = nil;
        _delegate = [delegate retain];

        [self prepareUrlTemplate: urlTemplate usingTrackingVariables: trackingVariables];
    }

    return self;
}

-(void) dealloc {
    [_delegate release];
    [self clearData];

    [super dealloc];
}

-(void) clearData {
    [urlString release]; urlString = nil;
    [postBodyData release]; postBodyData = nil;
    [userSIdVars release]; userSIdVars = nil;
    [userIdVars release]; userIdVars = nil;
    [beaconActionVars release]; beaconActionVars = nil;
    [beaconDataVars release]; beaconDataVars = nil;
    [enterForegroundCountVars release]; enterForegroundCountVars = nil;
    [foregroundTimeVars release]; foregroundTimeVars = nil;
}

-(void) prepareUrlTemplate:(NSString*) urlTemplate usingTrackingVariables:(NSDictionary*) trackingVariables {
    NSRange  range = [urlTemplate rangeOfString: @"?"];
    NSArray* components;

    [self clearData];

    if (range.location == NSNotFound) {
        urlString  = [urlTemplate retain];
        components = nil;
    }
    else {
        urlString  = [[urlTemplate substringToIndex: range.location] retain];
        components = [[urlTemplate substringFromIndex: range.location + range.length] componentsSeparatedByString: @"&"];
    }

    postBodyData = [[NSMutableData alloc] init];

    for (NSString* component in components) {
        range = [component rangeOfString: @"="];

        NSString* name;
        NSString* value;

        if (range.location == NSNotFound) {
            name  = component;
            value = @"";
        }
        else {
            name  = [component substringToIndex: range.location];
            value = [component substringFromIndex: range.location + range.length];
        }

        NSString* metaVarName = ngStringGetMetaVarName(value);
        BOOL      useHashed   = [metaVarName hasPrefix: @"@"];
        NSString* dynVarName  = useHashed ? [metaVarName substringFromIndex: 1] : metaVarName;

        if (metaVarName != nil) {
            value = [trackingVariables objectForKey: metaVarName];

            if (value != nil) {
                MNPostRequestBodyAddParam(postBodyData,name,value,NO,YES);
            }
            else if ([dynVarName isEqualToString: @"mn_user_sid"]) {
                if (userSIdVars == nil) {
                    userSIdVars = [[NSMutableArray alloc] init];
                }

                [userSIdVars addObject: [[[MNTrackingDynamicVar alloc] initWithName: name andHashUsage: useHashed] autorelease]];
            }
            else if ([dynVarName isEqualToString: @"mn_user_id"]) {
                if (userIdVars == nil) {
                    userIdVars = [[NSMutableArray alloc] init];
                }

                [userIdVars addObject: [[[MNTrackingDynamicVar alloc] initWithName: name andHashUsage: useHashed] autorelease]];
            }
            else if ([dynVarName isEqualToString: @"bt_beacon_action_name"]) {
                if (beaconActionVars == nil) {
                    beaconActionVars = [[NSMutableArray alloc] init];
                }

                [beaconActionVars addObject: [[[MNTrackingDynamicVar alloc] initWithName: name andHashUsage: useHashed] autorelease]];
            }
            else if ([dynVarName isEqualToString: @"bt_beacon_data"]) {
                if (beaconDataVars == nil) {
                    beaconDataVars = [[NSMutableArray alloc] init];
                }

                [beaconDataVars addObject: [[[MNTrackingDynamicVar alloc] initWithName: name andHashUsage: useHashed] autorelease]];
            }
            else if ([dynVarName isEqualToString: @"ls_foreground_count"]) {
                if (enterForegroundCountVars == nil) {
                    enterForegroundCountVars = [[NSMutableArray alloc] init];
                }

                [enterForegroundCountVars addObject: [[[MNTrackingDynamicVar alloc] initWithName: name andHashUsage: useHashed] autorelease]];
            }
            else if ([dynVarName isEqualToString: @"ls_foreground_time"]) {
                if (foregroundTimeVars == nil) {
                    foregroundTimeVars = [[NSMutableArray alloc] init];
                }

                [foregroundTimeVars addObject: [[[MNTrackingDynamicVar alloc] initWithName: name andHashUsage: useHashed] autorelease]];
            }
            else {
                MNPostRequestBodyAddParam(postBodyData,name,@"",NO,NO);
            }
        }
        else {
            MNPostRequestBodyAddParam(postBodyData,name,value,NO,NO);
        }
    }
}

-(BOOL) sendSimpleRequestWithSession:(MNSession*) session {
    return [self sendBeacon: nil data: nil withSession: session];
}

-(BOOL) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData withSession:(MNSession*) session {
    return [self sendBeacon: beaconAction data: beaconData withSession: session andCallSeqNumber: 0];
}

-(BOOL) sendBeacon:(NSString*) beaconAction
              data:(NSString*) beaconData
       withSession:(MNSession*) session
  andCallSeqNumber:(long) callSeqNumber{
    if (urlString == nil) {
        return NO;
    }

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString]];

    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];

    NSMutableData* completeData;

    if (userSIdVars      == nil &&
        userIdVars       == nil &&
        beaconActionVars == nil &&
        beaconDataVars   == nil &&
        enterForegroundCountVars == nil &&
        foregroundTimeVars == nil) {
        completeData = postBodyData;
    }
    else {
        completeData = [NSMutableData dataWithData: postBodyData];

        NSString* userSid   = [session getMySId];
        MNUserId  userId    = session == nil ? MNUserIdUndefined : [session getMyUserId];
        NSString* userIdStr = userId == MNUserIdUndefined ? @"" : [NSString stringWithFormat: @"%llu",userId];
        NSString* beaconActionStr = beaconAction == nil ? @"" : beaconAction;
        NSString* beaconDataStr   = beaconData   == nil ? @"" : beaconData;
        NSString* enterForegroundCountStr = [NSString stringWithFormat: @"%u",[session getForegroundSwitchCount]];
        NSString* foregroundTimeStr = [NSString stringWithFormat: @"%llu", (unsigned long long)[session getForegroundTime]];

        if (userSid == nil) {
            userSid = @"";
        }

        addDynamicVars(completeData,userSIdVars,userSid);
        addDynamicVars(completeData,userIdVars,userIdStr);
        addDynamicVars(completeData,beaconActionVars,beaconActionStr);
        addDynamicVars(completeData,beaconDataVars,beaconDataStr);
        addDynamicVars(completeData,enterForegroundCountVars,enterForegroundCountStr);
        addDynamicVars(completeData,foregroundTimeVars,foregroundTimeStr);
    }

    [request setHTTPBody: completeData];

    [self retain];

    MNURLDownloader* downloader = [[MNURLDownloader alloc] init];

    if (callSeqNumber != 0) {
        downloader.userData = [NSNumber numberWithLong: callSeqNumber];
    }

    [downloader loadRequest: request delegate: self];

    return YES;
}

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    if (_delegate != nil) {
        NSString* responseText  = [[[NSString alloc] initWithBytes: [data bytes] length: [data length] encoding: NSUTF8StringEncoding] autorelease];
        NSNumber* callSeqNumber = (NSNumber*)downloader.userData;
        MNAppBeaconResponse* response = [[[MNAppBeaconResponse alloc] initWithResponseText: responseText andCallSeqNumber: (callSeqNumber == nil ? 0 : [callSeqNumber longValue])] autorelease];

        [_delegate appBeaconDidReceiveResponse: response];
    }

    [self autorelease];
    [downloader autorelease];
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    if (_delegate != nil) {
        NSNumber* callSeqNumber = (NSNumber*)downloader.userData;
        MNAppBeaconResponse* response = [[[MNAppBeaconResponse alloc] initWithResponseText: nil andCallSeqNumber: (callSeqNumber == nil ? 0 : [callSeqNumber longValue])] autorelease];

        [_delegate appBeaconDidReceiveResponse: response];
    }

    [self autorelease];
    [downloader autorelease];
}

@end


@interface MNTrackingSystem()
-(void) setupTrackingVariablesForSession:(MNSession*) session;
@end


@implementation MNTrackingSystem

-(id) initWithSession:(MNSession*) session andTrackingSystemDelegate:(id<MNTrackingSystemDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _beaconUrlTemplate   = nil;
        _shutdownUrlTemplate = nil;
        _launchTracked       = NO;
        _installTracker      = [[MNInstallTracker alloc] init];
        _enterForegroundUrlTemplate = nil;
        _enterBackgroundUrlTemplate = nil;

        _delegateWrapper = [[MNTrackingSystemDelegateWrapper alloc] init];

        _delegateWrapper.delegate = delegate;

        [self setupTrackingVariablesForSession: session];
    }

    return self;
}

-(void) dealloc {
    _delegateWrapper.delegate = nil;
    [_delegateWrapper release];
    [_trackingVariables release];
    [_installTracker shutdown];
    [_installTracker release];
    [_beaconUrlTemplate release];
    [_shutdownUrlTemplate release];
    [_enterForegroundUrlTemplate release];
    [_enterBackgroundUrlTemplate release];

    [super dealloc];
}

-(void) setupTrackingVariablesForSession:(MNSession*) session {
    UIDevice* device = [UIDevice currentDevice];
    NSLocale* locale = [NSLocale currentLocale];
    NSString* countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString* language    = [locale objectForKey: NSLocaleLanguageCode];
    NSString* wiFiMAC = nil;
    NSString* allowReadWiFiMAC = [session getConfigData].allowReadWiFiMAC;

    if (allowReadWiFiMAC != nil && ![allowReadWiFiMAC isEqualToString: @"0"]) {
        wiFiMAC = MNHardwareGetWiFiMACAddress();
    }

    _trackingVariables = [[NSMutableDictionary alloc] init];

    setupTrackingVar(_trackingVariables,@"tv_udid",[session getUniqueAppId]);
    setupTrackingVar(_trackingVariables,@"tv_udid2",@""); // not available on iOS
    setupTrackingVar(_trackingVariables,@"tv_mac_addr",wiFiMAC != nil ? wiFiMAC : @"");
    setupTrackingVar(_trackingVariables,@"tv_device_type",[device model]);
    setupTrackingVar(_trackingVariables,@"tv_os_version",[device systemVersion]);
    setupTrackingVar(_trackingVariables,@"tv_country_code",countryCode);
    setupTrackingVar(_trackingVariables,@"tv_language_code",language);

    setupTrackingVar(_trackingVariables,@"mn_game_id",[NSString stringWithFormat: @"%d",[session getGameId]]);
    setupTrackingVar(_trackingVariables,@"mn_dev_type",[NSString stringWithFormat: @"%d",MNDeviceTypeiPhoneiPod]);
    setupTrackingVar(_trackingVariables,@"mn_dev_id",MNStringGetMD5String([session getUniqueAppId]));
    setupTrackingVar(_trackingVariables,@"mn_client_ver",MNClientAPIVersion);
    setupTrackingVar(_trackingVariables,@"mn_client_locale",[locale localeIdentifier]);
    setupTrackingVar(_trackingVariables,@"mn_app_ver_ext",MNGetAppVersionExternal());
    setupTrackingVar(_trackingVariables,@"mn_app_ver_int",MNGetAppVersionInternal());
    setupTrackingVar(_trackingVariables,@"mn_launch_time",[NSString stringWithFormat: @"%lld",(long long)[session getLaunchTime]]);
    setupTrackingVar(_trackingVariables,@"mn_launch_id",[session getLaunchId]);
    setupTrackingVar(_trackingVariables,@"mn_install_id",[session getInstallId]);

    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    NSString* timeZoneInfo = [NSString stringWithFormat: @"%d+%@+%@",[timeZone secondsFromGMT],[timeZone abbreviation],[[timeZone name] stringByReplacingOccurrencesOfString: @"," withString: @"-"]];
    
    setupTrackingVar(_trackingVariables,@"mn_tz_info",[[timeZoneInfo stringByReplacingOccurrencesOfString: @"," withString: @"-"]
                                                       stringByReplacingOccurrencesOfString: @"|" withString: @" "]);

    NSDictionary* appExtParams = [session getAppExtParams];

    for (NSString* key in appExtParams) {
        setupTrackingVar(_trackingVariables,key,[appExtParams objectForKey: key]);
    }
}

-(void) trackLaunchWithUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session {
    if (_launchTracked) {
        return;
    }

    MNTrackingUrlTemplate* _launchTrackingUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate trackingVariables: _trackingVariables andDelegate: nil];

    [_launchTrackingUrlTemplate sendSimpleRequestWithSession: session];
    [_launchTrackingUrlTemplate autorelease];
    _launchTracked = YES;
}

-(void) trackInstallWithUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session {
    [_installTracker trackInstallWithUrlTemplate: urlTemplate withTrackingVars: _trackingVariables forSession: session];
}

-(void) setShutdownUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session {
    [_shutdownUrlTemplate release];

    _shutdownUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate trackingVariables: _trackingVariables andDelegate: nil];
}

-(void) trackShutdownForSession:(MNSession*) session {
    [_shutdownUrlTemplate sendSimpleRequestWithSession: session];

    runRunLoopOnce();
}

-(void) setBeaconUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session {
    [_beaconUrlTemplate release];

    _beaconUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate trackingVariables: _trackingVariables andDelegate: _delegateWrapper];
}

-(void) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData andSession:(MNSession*) session {
    [_beaconUrlTemplate sendBeacon: beaconAction data: beaconData withSession: session];
}

-(void) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData callSeqNumber:(long) callSeqNumber andSession:(MNSession*) session {
    [_beaconUrlTemplate sendBeacon: beaconAction data: beaconData withSession: session andCallSeqNumber: callSeqNumber];
}

-(void) setEnterForegroundUrlTemplate:(NSString*) urlTemplate {
    [_enterForegroundUrlTemplate release];

    _enterForegroundUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate trackingVariables: _trackingVariables andDelegate: nil];
}

-(void) setEnterBackgroundUrlTemplate:(NSString*) urlTemplate {
    [_enterBackgroundUrlTemplate release];

    _enterBackgroundUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate trackingVariables: _trackingVariables andDelegate: nil];
}

-(void) trackEnterForegroundForSession:(MNSession*) session {
    [_enterForegroundUrlTemplate sendSimpleRequestWithSession: session];
}

-(void) trackEnterBackgroundForSession:(MNSession*) session {
    [_enterBackgroundUrlTemplate sendSimpleRequestWithSession: session];

    runRunLoopOnce();
}

-(NSDictionary*) getTrackingVars {
    return _trackingVariables;
}

@end
