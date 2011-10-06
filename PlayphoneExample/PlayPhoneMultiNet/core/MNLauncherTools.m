//
//  MNLauncherTools.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 10/29/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MNLauncherTools.h"

static NSString* launcherInstanceId = @"playphone";

static NSString* checkURLSchemeSupportURLFormat = @"%@://blank";
static NSString* launcherURLSchemeFormat = @"com-%@-game-%d";

BOOL MNLauncherIsURLSchemeSupported (NSString* scheme) {
    return [[UIApplication sharedApplication] canOpenURL:
            [NSURL URLWithString: [NSString stringWithFormat: checkURLSchemeSupportURLFormat, scheme]]];
}

BOOL MNLauncherStartApp (NSString* scheme, NSString* params) {
    return [[UIApplication sharedApplication] openURL:
            [NSURL URLWithString: [NSString stringWithFormat: @"%@://%@",scheme,params]]];
}

BOOL MNLauncherIsLauncherURL (NSURL* url, NSInteger gameId) {
    NSString* urlScheme = [url scheme];
    NSString* launcherScheme = [[NSString alloc] initWithFormat: launcherURLSchemeFormat, launcherInstanceId, gameId];
    BOOL      isLauncherURL;

    isLauncherURL = [urlScheme isEqualToString: launcherScheme];

    if (!isLauncherURL) {
        NSUInteger urlSchemeLength      = [urlScheme length];
        NSUInteger launcherSchemeLength = [launcherScheme length];

        if (urlSchemeLength > launcherSchemeLength) {
            isLauncherURL = [urlScheme characterAtIndex: launcherSchemeLength] == '_' &&
                            [urlScheme hasPrefix: launcherScheme];
        }
    }

    [launcherScheme release];

    return isLauncherURL;
}

NSString* MNLauncherGetLaunchParams (NSURL* url) {
    if (url == nil) {
        return nil;
    }

    NSString* urlString  = [url absoluteString];
    NSRange   colonRange = [urlString rangeOfString: @":"];

    if (colonRange.location == NSNotFound) {
        return nil;
    }

    NSUInteger urlLength = [urlString length];
    NSUInteger location  = colonRange.location + colonRange.length;

    if (location < urlLength && [urlString characterAtIndex: location] == '/') {
        location++;

        if (location < urlLength && [urlString characterAtIndex: location] == '/') {
            location++;
        }
    }

    return  [urlString substringFromIndex: location];
}
