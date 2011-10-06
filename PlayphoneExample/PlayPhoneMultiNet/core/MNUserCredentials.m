//
//  MNUserCredentials.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 8/12/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNTools.h"
#import "MNUserCredentials.h"

//static NSString* MNUserCredentialsDefaultsKey = @"MNDevUsers";
#define MNUserCredentialsVarPrefix    @"cred."
#define MNUserCredentialsVarWildCard  @"*"
#define MNUserCredentialsVarSeparator @"."

static NSString* MNUserCredentialsFieldUserId = @"user_id";
static NSString* MNUserCredentialsFieldUserName = @"user_name";
static NSString* MNUserCredentialsFieldUserAuthSign = @"user_auth_sign";
static NSString* MNUserCredentialsFieldLastLoginTime = @"user_last_login_time";
static NSString* MNUserCredentialsFieldUserAuxInfoText = @"user_aux_info_text";

@implementation MNUserCredentials

@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize userAuthSign = _userAuthSign;
@synthesize lastLoginTime = _lastLoginTime;
@synthesize userAuxInfoText = _userAuxInfoText;

+(MNUserCredentials*) mnUserCredentialsWithId:(MNUserId) userId
                      name:(NSString*) name
                      authSign:(NSString*) authSign
                      lastLoginTime:(NSDate*) lastLoginTime
                      andAuxInfoText:(NSString*) auxInfoText {
    MNUserCredentials* credentials = [[MNUserCredentials alloc] initWithId: userId name: name authSign: authSign lastLoginTime: lastLoginTime andAuxInfoText: auxInfoText];

    return [credentials autorelease];
}

-(id) initWithId:(MNUserId) userId
      name:(NSString*) name
      authSign:(NSString*) authSign
      lastLoginTime:(NSDate*) lastLoginTime
      andAuxInfoText:(NSString*) auxInfoText {
    self = [super init];

    if (self != nil) {
        self.userId = userId;
        self.userName = name;
        self.userAuthSign = authSign;
        self.lastLoginTime = lastLoginTime;
        self.userAuxInfoText = auxInfoText;
    }

    return self;
}

-(void) dealloc {
    [_userName release];
    [_userAuthSign release];
    [_lastLoginTime release];
    [_userAuxInfoText release];

    [super dealloc];
}

@end

static BOOL parseCredentialsVar (NSString* varName, MNUserId* userId, NSString** fieldName) {
    if (![varName hasPrefix: MNUserCredentialsVarPrefix]) {
        NSLog(@"note: variable with unexpected prefix found, check credentials selection mask");

        return NO;
    }

    NSString* userIdFieldSubstr = [varName substringFromIndex: [MNUserCredentialsVarPrefix length]];
    NSRange dotCharRange = [userIdFieldSubstr rangeOfString: MNUserCredentialsVarSeparator];

    if (dotCharRange.location == NSNotFound) {
        NSLog(@"note: variable with broken name structure found in credentials");

        return NO;
    }

    if (!MNStringScanLongLong(userId,[userIdFieldSubstr substringToIndex: dotCharRange.location])) {
        NSLog(@"note: invalid user id found in credentials");

        return NO;
    }

    *fieldName = [userIdFieldSubstr substringFromIndex: dotCharRange.location + 1];

    return YES;
}

#define MNUserCredentialsAverageUserCount (1)

NSArray* MNUserCredentialsLoad (MNVarStorage* varStorage) {
    NSMutableDictionary* usersDictionary = [[NSMutableDictionary alloc] initWithCapacity: MNUserCredentialsAverageUserCount];
    NSDictionary* credentialsVars = [varStorage dictionaryWithVariablesByMask: @"cred.*"];

    for (NSString* var in credentialsVars) {
        MNUserId userId;
        NSString* fieldName;

        if (parseCredentialsVar(var,&userId,&fieldName)) {
            NSNumber* num = [NSNumber numberWithLongLong: userId];
            MNUserCredentials* credentials = [usersDictionary objectForKey: num];

            if (credentials == nil) {
                credentials = [MNUserCredentials mnUserCredentialsWithId: userId name: nil authSign: nil lastLoginTime: nil andAuxInfoText: nil];

                [usersDictionary setObject: credentials forKey: num];
            }

            if ([fieldName isEqualToString: MNUserCredentialsFieldUserId]) {
                /* skip entry */
            }
            else if ([fieldName isEqualToString: MNUserCredentialsFieldUserName]) {
                credentials.userName = [credentialsVars objectForKey: var];
            }
            else if ([fieldName isEqualToString: MNUserCredentialsFieldUserAuthSign]) {
                credentials.userAuthSign = [credentialsVars objectForKey: var];
            }
            else if ([fieldName isEqualToString: MNUserCredentialsFieldLastLoginTime]) {
                long long timeInterval;

                if (MNStringScanLongLong(&timeInterval,[credentialsVars objectForKey: var])) {
                    credentials.lastLoginTime = [NSDate dateWithTimeIntervalSince1970: timeInterval];
                }
            }
            else if ([fieldName isEqualToString: MNUserCredentialsFieldUserAuxInfoText]) {
                credentials.userAuxInfoText = [credentialsVars objectForKey: var];
            }
        }
    }

    NSMutableArray* result = [NSMutableArray arrayWithCapacity: [usersDictionary count]];

    for (id key in usersDictionary) {
        [result addObject: [usersDictionary objectForKey: key]];
    }

    [usersDictionary release];

    return result;
}

void MNUserCredentialsWipeByUserId (MNVarStorage* varStorage, MNUserId userId) {
    NSString* varMask = [NSString stringWithFormat: MNUserCredentialsVarPrefix @"%lld" MNUserCredentialsVarSeparator MNUserCredentialsVarWildCard, userId];

    [varStorage removeVariablesByMask: varMask];
}

void MNUserCredentialsWipeAll (MNVarStorage* varStorage) {
    [varStorage removeVariablesByMask: MNUserCredentialsVarPrefix MNUserCredentialsVarWildCard];
}

void MNUserCredentialsUpdateUser (MNVarStorage* varStorage,MNUserId userId, NSString* userName, NSString* userAuthSign, NSDate* lastLoginTime, NSString* userAuxInfoText) {
    NSString* credPrefix = [NSString stringWithFormat: MNUserCredentialsVarPrefix @"%lld" MNUserCredentialsVarSeparator, userId];

    [varStorage setValue: [NSString stringWithFormat: @"%lld", userId] forVariable: [NSString stringWithFormat: @"%@%@",credPrefix,MNUserCredentialsFieldUserId]];

    if (userName != nil) {
        [varStorage setValue: userName forVariable: [NSString stringWithFormat: @"%@%@",credPrefix,MNUserCredentialsFieldUserName]];
    }

    if (userAuthSign != nil) {
        [varStorage setValue: userAuthSign forVariable: [NSString stringWithFormat: @"%@%@",credPrefix,MNUserCredentialsFieldUserAuthSign]];
    }

    if (lastLoginTime != nil) {
        long long timeValue = (long long)[lastLoginTime timeIntervalSince1970];

        [varStorage setValue: [NSString stringWithFormat: @"%lld", timeValue] forVariable: [NSString stringWithFormat: @"%@%@",credPrefix,MNUserCredentialsFieldLastLoginTime]];
    }

    if (userAuxInfoText != nil) {
        [varStorage setValue: userAuxInfoText forVariable: [NSString stringWithFormat: @"%@%@",credPrefix,MNUserCredentialsFieldUserAuxInfoText]];
    }
}

extern MNUserCredentials* MNUserCredentialsGetMostRecentlyLoggedUserCredentials (MNVarStorage* varStorage) {
    NSArray* allCredentials = MNUserCredentialsLoad(varStorage);
    NSDate* mostRecentLoginTime = nil;
    MNUserCredentials* mostRecentCredentials = nil;

    for (MNUserCredentials* credentials in allCredentials) {
        if (mostRecentLoginTime == nil || [credentials.lastLoginTime compare: mostRecentLoginTime] == NSOrderedDescending) {
            mostRecentLoginTime = credentials.lastLoginTime;
            mostRecentCredentials = credentials;
        }
    }

    return mostRecentCredentials;
}

extern MNUserCredentials* MNUserCredentialsGetByUserId (MNVarStorage* varStorage, MNUserId userId) {
    NSArray* allCredentials = MNUserCredentialsLoad(varStorage);
    MNUserCredentials* result;
    NSUInteger index = 0;
    NSUInteger count = [allCredentials count];
    BOOL       found = NO;

    while (!found && index < count) {
        result = [allCredentials objectAtIndex: index];

        if (result.userId == userId) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? result : nil;
}
