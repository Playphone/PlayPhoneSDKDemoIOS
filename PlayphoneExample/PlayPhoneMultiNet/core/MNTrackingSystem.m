//
//  MNTrackingSystem.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MNTools.h"
#import "MNCommon.h"
#import "MNSession.h"
#import "MNSessionInternal.h"

#import "MNTrackingSystem.h"

#define MNTrackingRunLoopTimeoutInSeconds (5)

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

@interface MNTrackingUrlTemplate : NSObject
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
}

-(id) initWithUrlTemplate:(NSString*) urlTemplate andTrackingVariables:(NSDictionary*) trackingVariables;
-(BOOL) sendSimpleRequestWithSession:(MNSession*) session;
-(BOOL) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData withSession:(MNSession*) session;

-(void) prepareUrlTemplate:(NSString*) urlTemplate usingTrackingVariables:(NSDictionary*) trackingVariables;
-(void) clearData;

@end


@implementation MNTrackingUrlTemplate

-(id) initWithUrlTemplate:(NSString*) urlTemplate andTrackingVariables:(NSDictionary*) trackingVariables {
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

        [self prepareUrlTemplate: urlTemplate usingTrackingVariables: trackingVariables];
    }

    return self;
}

-(void) dealloc {
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

        if (metaVarName != nil) {
            value = [trackingVariables objectForKey: metaVarName];

            if (value != nil) {
                MNPostRequestBodyAddParam(postBodyData,name,value,NO,YES);
            }
            else if ([metaVarName isEqualToString: @"mn_user_sid"]) {
                if (userSIdVars == nil) {
                    userSIdVars = [[NSMutableArray alloc] init];
                }

                [userSIdVars addObject: name];
            }
            else if ([metaVarName isEqualToString: @"mn_user_id"]) {
                if (userIdVars == nil) {
                    userIdVars = [[NSMutableArray alloc] init];
                }

                [userIdVars addObject: name];
            }
            else if ([metaVarName isEqualToString: @"bt_beacon_action_name"]) {
                if (beaconActionVars == nil) {
                    beaconActionVars = [[NSMutableArray alloc] init];
                }

                [beaconActionVars addObject: name];
            }
            else if ([metaVarName isEqualToString: @"bt_beacon_data"]) {
                if (beaconDataVars == nil) {
                    beaconDataVars = [[NSMutableArray alloc] init];
                }

                [beaconDataVars addObject: name];
            }
            else if ([metaVarName isEqualToString: @"ls_foreground_count"]) {
                if (enterForegroundCountVars == nil) {
                    enterForegroundCountVars = [[NSMutableArray alloc] init];
                }

                [enterForegroundCountVars addObject: name];
            }
            else if ([metaVarName isEqualToString: @"ls_foreground_time"]) {
                if (foregroundTimeVars == nil) {
                    foregroundTimeVars = [[NSMutableArray alloc] init];
                }

                [foregroundTimeVars addObject: name];
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
        NSString* enterForegrountCountStr = [NSString stringWithFormat: @"%u",[session getForegroundSwitchCount]];
        NSString* foregroundTimeStr = [NSString stringWithFormat: @"%llu", (unsigned long long)[session getForegroundTime]];

        if (userSid == nil) {
            userSid = @"";
        }

        for (NSString* varName in userSIdVars) {
            MNPostRequestBodyAddParam(completeData,varName,userSid,NO,YES);
        }

        for (NSString* varName in userIdVars) {
            MNPostRequestBodyAddParam(completeData,varName,userIdStr,NO,YES);
        }

        for (NSString* varName in beaconActionVars) {
            MNPostRequestBodyAddParam(completeData,varName,beaconActionStr,NO,YES);
        }

        for (NSString* varName in beaconDataVars) {
            MNPostRequestBodyAddParam(completeData,varName,beaconDataStr,NO,YES);
        }

        for (NSString* varName in enterForegroundCountVars) {
            MNPostRequestBodyAddParam(completeData,varName,enterForegrountCountStr,NO,YES);
        }

        for (NSString* varName in foregroundTimeVars) {
            MNPostRequestBodyAddParam(completeData,varName,foregroundTimeStr,NO,YES);
        }
    }

    [request setHTTPBody: completeData];

    [self retain];

    [[NSURLConnection connectionWithRequest: request delegate: self] retain];

    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self autorelease];
    [connection autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self autorelease];
    [connection autorelease];
}

@end


@interface MNTrackingSystem()
-(void) setupTrackingVariablesForSession:(MNSession*) session;
@end


@implementation MNTrackingSystem

-(id) initWithSession:(MNSession*) session {
    self = [super init];

    if (self != nil) {
        _beaconUrlTemplate   = nil;
        _shutdownUrlTemplate = nil;
        _launchTracked       = NO;
        _enterForegroundUrlTemplate = nil;
        _enterBackgroundUrlTemplate = nil;

        [self setupTrackingVariablesForSession: session];
    }

    return self;
}

-(void) dealloc {
    [_trackingVariables release];
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

    _trackingVariables = [[NSMutableDictionary alloc] init];

    [_trackingVariables setObject: [device uniqueIdentifier] forKey: @"tv_udid"];
// [_trackingVariables setObject: [device systemName] forKey: @"tv_device_name"]; 
    [_trackingVariables setObject: [device model] forKey: @"tv_device_type"];
    [_trackingVariables setObject: [device systemVersion] forKey: @"tv_os_version"];

    if (countryCode != nil) {
        [_trackingVariables setObject: countryCode forKey: @"tv_country_code"];
    }

    if (language != nil) {
        [_trackingVariables setObject: language forKey: @"tv_language_code"];
    }

    [_trackingVariables setObject: [NSString stringWithFormat: @"%d",[session getGameId]] forKey: @"mn_game_id"];
    [_trackingVariables setObject: [NSString stringWithFormat: @"%d",MNDeviceTypeiPhoneiPod] forKey: @"mn_dev_type"];
    [_trackingVariables setObject: MNGetDeviceIdMD5() forKey: @"mn_dev_id"];
    [_trackingVariables setObject: MNClientAPIVersion forKey: @"mn_client_ver"];
    [_trackingVariables setObject: [locale localeIdentifier] forKey: @"mn_client_locale"];

    NSString* version = MNGetAppVersionExternal();

    if (version != nil) {
        [_trackingVariables setObject: version forKey: @"mn_app_ver_ext"];
    }

    version = MNGetAppVersionInternal();

    if (version != nil) {
        [_trackingVariables setObject: version forKey: @"mn_app_ver_int"];
    }

    [_trackingVariables setObject: [NSString stringWithFormat: @"%lld",(long long)[session getLaunchTime]] forKey: @"mn_launch_time"];
    [_trackingVariables setObject: [session getLaunchId] forKey: @"mn_launch_id"];

    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    NSString* timeZoneInfo = [NSString stringWithFormat: @"%d+%@+%@",[timeZone secondsFromGMT],[timeZone abbreviation],[[timeZone name] stringByReplacingOccurrencesOfString: @"," withString: @"-"]];

    [_trackingVariables setObject: [[timeZoneInfo stringByReplacingOccurrencesOfString: @"," withString: @"-"]
                                    stringByReplacingOccurrencesOfString: @"|" withString: @" "] forKey: @"mn_tz_info"];
}

-(void) trackLaunchWithUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session {
    if (_launchTracked) {
        return;
    }

    MNTrackingUrlTemplate* _launchTrackingUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate andTrackingVariables: _trackingVariables];

    [_launchTrackingUrlTemplate sendSimpleRequestWithSession: session];
    [_launchTrackingUrlTemplate autorelease];
    _launchTracked = YES;
}

-(void) setShutdownUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session {
    [_shutdownUrlTemplate release];

    _shutdownUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate andTrackingVariables: _trackingVariables];
}

-(void) trackShutdownForSession:(MNSession*) session {
    [_shutdownUrlTemplate sendSimpleRequestWithSession: session];

    runRunLoopOnce();
}

-(void) setBeaconUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session {
    [_beaconUrlTemplate release];

    _beaconUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate andTrackingVariables: _trackingVariables];
}

-(void) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData andSession:(MNSession*) session {
    [_beaconUrlTemplate sendBeacon: beaconAction data: beaconData withSession: session];
}

-(void) setEnterForegroundUrlTemplate:(NSString*) urlTemplate {
    [_enterForegroundUrlTemplate release];

    _enterForegroundUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate andTrackingVariables: _trackingVariables];
}

-(void) setEnterBackgroundUrlTemplate:(NSString*) urlTemplate {
    [_enterBackgroundUrlTemplate release];

    _enterBackgroundUrlTemplate = [[MNTrackingUrlTemplate alloc] initWithUrlTemplate: urlTemplate andTrackingVariables: _trackingVariables];
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
