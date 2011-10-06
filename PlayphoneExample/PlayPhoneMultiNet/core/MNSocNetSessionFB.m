//
//  MNSocNetSessionFB.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/16/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "FBConnect/FBConnect.h"

#import "MNMessageCodes.h"
#import "MNTools.h"

#import "MNSocNetSessionFB.h"

#define MNSocNetFBSingleSignOnDisabled (1)

static NSString* MNSocNetFBAccessTokenDefaultsKey    = @"FBAccessTokenKey";
static NSString* MNSocNetFBExpirationDateDefaultsKey = @"FBExpirationDateKey";

@interface MNSocNetFBPermissionDelegateWrapper : NSObject<FBDialogDelegate>
{
    @public

    id<MNSocNetFBPermissionDialogDelegate> _delegate;
}

@property (nonatomic,retain) id<MNSocNetFBPermissionDialogDelegate> delegate;

-(id) init;
-(void) dealloc;

/* FBDialogDelegate */
- (void)dialogDidComplete:(FBDialog *)dialog;
- (void)dialogDidNotComplete:(FBDialog *)dialog;
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error;

@end


@implementation MNSocNetFBPermissionDelegateWrapper

@synthesize delegate = _delegate;

-(id) init {
    self = [super init];

    if (self != nil) {
        _delegate = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];

    [super dealloc];
}

-(void) dialogDidComplete:(FBDialog*)dialog {
    id<MNSocNetFBPermissionDialogDelegate> tmpDelegate = _delegate;
    
    self.delegate = nil;

    [tmpDelegate socNetFBPermissionDialogDidSucceed];
}

-(void) dialogDidNotComplete:(FBDialog*)dialog {
    id<MNSocNetFBPermissionDialogDelegate> tmpDelegate = _delegate;
    
    self.delegate = nil;
    
    [tmpDelegate socNetFBPermissionDialogDidCancel];
}

-(void) dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
    id<MNSocNetFBPermissionDialogDelegate> tmpDelegate = _delegate;

    self.delegate = nil;

    [tmpDelegate socNetFBPermissionDialogDidFailWithError: error];
}

@end


@interface MNSocNetFBStreamDelegateWrapper : NSObject<FBDialogDelegate>
{
@public
    
    id<MNSocNetFBStreamDialogDelegate> _delegate;
}

@property (nonatomic,retain) id<MNSocNetFBStreamDialogDelegate> delegate;

-(id) init;
-(void) dealloc;

/* FBDialogDelegate */
- (void)dialogDidComplete:(FBDialog *)dialog;
- (void)dialogDidNotComplete:(FBDialog *)dialog;
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error;

@end


@implementation MNSocNetFBStreamDelegateWrapper

@synthesize delegate = _delegate;

-(id) init {
    self = [super init];

    if (self != nil) {
        _delegate = nil;
    }

    return self;
}

-(void) dealloc {
    [_delegate release];

    [super dealloc];
}

-(void) dialogDidComplete:(FBDialog*)dialog {
    id<MNSocNetFBStreamDialogDelegate> tmpDelegate = _delegate;

    self.delegate = nil;

    [tmpDelegate socNetFBStreamDialogDidSucceed];
}

-(void) dialogDidNotComplete:(FBDialog*)dialog {
    id<MNSocNetFBStreamDialogDelegate> tmpDelegate = _delegate;

    self.delegate = nil;

    [tmpDelegate socNetFBStreamDialogDidCancel];
}

-(void) dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
    id<MNSocNetFBStreamDialogDelegate> tmpDelegate = _delegate;

    self.delegate = nil;

    [tmpDelegate socNetFBStreamDialogDidFailWithError: error];
}

@end


@interface MNFBSessionWrapper : NSObject<FBSessionDelegate,FBDialogDelegate>
{
    @public

    Facebook* _facebook;
    BOOL _connecting;
    id<MNSocNetFBDelegate> _delegate;
    MNSocNetSessionFB* _session;

    MNSocNetFBStreamDelegateWrapper*     _streamDelegateWrapper;
    MNSocNetFBPermissionDelegateWrapper* _permissionDelegateWrapper;
}

-(id) initWithSocNetSessionFB:(MNSocNetSessionFB*) session andDelegate:(id<MNSocNetFBDelegate>) delegate;
-(void) dealloc;

-(void) showStreamDialogWithPrompt:(NSString*) prompt
                        attachment:(NSString*) attachment
                          targetId:(NSString*) targetId
                       actionLinks:(NSString*) actionLinks
                       andDelegate:(id<MNSocNetFBStreamDialogDelegate>) delegate;

-(void) showPermissionDialogWithPermission:(NSString*) permission
                               andDelegate:(id<MNSocNetFBPermissionDialogDelegate>) delegate;

/* FBSessionDelegate protocol*/

- (void)fbDidLogin;
- (void)fbDidNotLogin:(BOOL)cancelled;
- (void)fbDidLogout;
@end


@implementation MNFBSessionWrapper

-(id) initWithSocNetSessionFB:(MNSocNetSessionFB*) session andDelegate:(id<MNSocNetFBDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _session    = session;
        _facebook   = nil;
        _delegate   = delegate;
        _connecting = NO;

        _streamDelegateWrapper     = [[MNSocNetFBStreamDelegateWrapper alloc] init];
        _permissionDelegateWrapper = [[MNSocNetFBPermissionDelegateWrapper alloc] init];
    }

    return self;
}

-(void) dealloc {
    [_facebook release];
    [_streamDelegateWrapper release];
    [_permissionDelegateWrapper release];
    [super dealloc];
}

-(void) showStreamDialogWithPrompt:(NSString*) prompt
                        attachment:(NSString*) attachment
                          targetId:(NSString*) targetId
                       actionLinks:(NSString*) actionLinks
                       andDelegate:(id<MNSocNetFBStreamDialogDelegate>) delegate {
    if (_facebook != nil && _streamDelegateWrapper.delegate == nil) {
        _streamDelegateWrapper.delegate = delegate;

        [_facebook dialog: @"stream.publish" 
                andParams: [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             prompt, @"message", attachment, @"attachment",
                             actionLinks, @"actionLinks", targetId, @"targetId", nil]
              andDelegate: _streamDelegateWrapper];
    }
}

-(void) showPermissionDialogWithPermission:(NSString*) permission
                               andDelegate:(id<MNSocNetFBPermissionDialogDelegate>) delegate {
    if (_facebook != nil && _permissionDelegateWrapper.delegate == nil) {
        _permissionDelegateWrapper.delegate = delegate;

        [_facebook dialog: @"permissions.request"
                andParams: [NSMutableDictionary dictionaryWithObjectsAndKeys: permission, @"perms", nil]
              andDelegate: _permissionDelegateWrapper];
    }
}

- (void)fbDidLogin {
    _connecting = NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[_facebook accessToken] forKey:MNSocNetFBAccessTokenDefaultsKey];
    [defaults setObject:[_facebook expirationDate] forKey:MNSocNetFBExpirationDateDefaultsKey];

    [defaults synchronize];

    [_delegate socNetFBLoginOk: _session];
}

- (void)fbDidLogout {
    _connecting = NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:MNSocNetFBAccessTokenDefaultsKey];
    [defaults removeObjectForKey:MNSocNetFBExpirationDateDefaultsKey];

    [defaults synchronize];

    [_delegate socNetFBLoggedOut];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    _connecting = NO;

    if (cancelled) {
        [_delegate socNetFBLoginCanceled];
    }
    else {
        [_delegate socNetFBLoginFailed];
    }
}

@end


static BOOL isFacebookUrl (NSURL* url) {
    NSString* urlString = [url absoluteString];

    return [urlString hasPrefix: @"fb"];
}

@implementation MNSocNetSessionFB

-(id) initWithDelegate:(id<MNSocNetFBDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _fbSessionWrapper = [[MNFBSessionWrapper alloc] initWithSocNetSessionFB: self andDelegate: delegate];
        _fbAppId          = nil;
        _fbUrlToHandle    = nil;
    }

    return self;
}

-(void) dealloc {
    [_fbUrlToHandle release];
    [_fbAppId release];
    [_fbSessionWrapper release];
    [super dealloc];
}

-(void) setFBAppId:(NSString*) appId {
    if (_fbAppId != nil && ![appId isEqualToString: _fbAppId]) {
        NSLog(@"WARNING: facebook appid changed during app runtime");
    }

    [_fbAppId release];

    _fbAppId = [appId retain];

    if (_fbSessionWrapper->_facebook == nil) {
        _fbSessionWrapper->_facebook = [[Facebook alloc] initWithAppId: _fbAppId];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        if ([defaults objectForKey:MNSocNetFBAccessTokenDefaultsKey] && [defaults objectForKey:MNSocNetFBExpirationDateDefaultsKey]) {
            _fbSessionWrapper->_facebook.accessToken    = [defaults objectForKey:MNSocNetFBAccessTokenDefaultsKey];
            _fbSessionWrapper->_facebook.expirationDate = [defaults objectForKey:MNSocNetFBExpirationDateDefaultsKey];
        }

        if (_fbUrlToHandle != nil) {
            NSURL* url = [_fbUrlToHandle retain];

            [_fbUrlToHandle release];
            _fbUrlToHandle = nil;

            [_fbSessionWrapper->_facebook handleOpenURL: url];

            [url release];
        }
    }
}

-(BOOL) handleOpenURL:(NSURL*) url {
#if MNSocNetFBSingleSignOnDisabled
    return NO;
#else
    if (_fbSessionWrapper->_facebook != nil) {
        return [_fbSessionWrapper->_facebook handleOpenURL: url];
    }
    else {
        if (!isFacebookUrl(url)) {
            return NO;
        }

        if (_fbUrlToHandle == nil) {
            _fbUrlToHandle = [url copy];
        }
        else {
            NSLog(@"WARNING: facebook handleOpenURL missed");
        }

        return YES;
    }
#endif
}

-(BOOL) connectWithPermissions:(NSArray*) permissions andFillErrorMessage:(NSString**) error {
    if (_fbSessionWrapper->_facebook == nil) {
        if (error != NULL) {
            *error = [NSString stringWithString: MNLocalizedString(@"Facebook API key and/or session proxy URL is invalid or not set",MNMessageCodeFacebookAPIKeyOrSessionProxyURLIsInvalidOrNotSetError)];
        }

        return NO;
    }

    if (_fbSessionWrapper->_connecting) {
        if (error != NULL) {
            *error = [NSString stringWithString: MNLocalizedString(@"Facebook connection already have been initiated",MNMessageCodeFacebookConnectionAlreadyInitiatedError)];
        }

        return NO;
    }

    _fbSessionWrapper->_connecting = YES;

#if MNSocNetFBSingleSignOnDisabled
    [_fbSessionWrapper->_facebook authorizeWithFBAppAuth: NO safariAuth: NO permissions: (permissions != nil ? permissions : [NSArray array]) delegate: _fbSessionWrapper];
#else
    [_fbSessionWrapper->_facebook authorize: (permissions != nil ? permissions : [NSArray array]) delegate: _fbSessionWrapper];
#endif

    return YES;
}

-(BOOL) resumeAndFillErrorMessage:(NSString**) error {
    return [self connectWithPermissions: nil andFillErrorMessage: error];
}

-(void) logout {
    [_fbSessionWrapper->_facebook logout: _fbSessionWrapper];

    _fbSessionWrapper->_connecting = NO;
}

-(BOOL) isConnected {
    return [_fbSessionWrapper->_facebook isSessionValid];
}

-(MNSocNetUserId) getUserId {
    return MNSocNetUserIdUndefined;
}

-(NSString*) getSessionKey {
    if ([self isConnected]) {
        return @"";
    }
    else {
        return nil;
    }
}

-(NSString*) getSessionSecret {
    if ([self isConnected]) {
        return _fbSessionWrapper->_facebook.accessToken;
    }
    else {
        return nil;
    }
}

-(BOOL) didUserStoreCredentials {
    return [self isConnected] && _fbSessionWrapper->_facebook.expirationDate != nil;
}

-(Facebook*) getFacebook {
    return _fbSessionWrapper->_facebook;
}

-(void) showStreamDialogWithPrompt:(NSString*) prompt
                        attachment:(NSString*) attachment
                          targetId:(NSString*) targetId
                       actionLinks:(NSString*) actionLinks
                       andDelegate:(id<MNSocNetFBStreamDialogDelegate>) delegate {
    [_fbSessionWrapper showStreamDialogWithPrompt: prompt attachment: attachment targetId: targetId actionLinks: actionLinks andDelegate: delegate];
}

-(void) showPermissionDialogWithPermission:(NSString*) permission
                               andDelegate:(id<MNSocNetFBPermissionDialogDelegate>) delegate {
    [_fbSessionWrapper showPermissionDialogWithPermission: permission andDelegate: delegate];
}

@end
