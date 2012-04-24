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


@interface MNSocNetFBGenericDialogDelegateWrapper : NSObject<FBDialogDelegate>
{
@public

    id<MNSocNetFBGenericDialogDelegate> _delegate;
}

@property (nonatomic,retain) id<MNSocNetFBGenericDialogDelegate> delegate;

-(id) init;
-(void) dealloc;

/* FBDialogDelegate */
- (void)dialogCompleteWithUrl:(NSURL*) url;
- (void)dialogDidNotCompleteWithUrl:(NSURL*) url;
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error;

@end


@implementation MNSocNetFBGenericDialogDelegateWrapper

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

- (void)dialogCompleteWithUrl:(NSURL*) url {
    id<MNSocNetFBGenericDialogDelegate> tmpDelegate = _delegate;

    self.delegate = nil;

    [tmpDelegate socNetFBGenericDialogDidSucceedWithUrl: url];
}

- (void)dialogDidNotCompleteWithUrl:(NSURL*) url {
    id<MNSocNetFBGenericDialogDelegate> tmpDelegate = _delegate;

    self.delegate = nil;

    [tmpDelegate socNetFBGenericDialogDidCancelWithUrl: url];
}

-(void) dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
    id<MNSocNetFBGenericDialogDelegate> tmpDelegate = _delegate;

    self.delegate = nil;

    [tmpDelegate socNetFBGenericDialogDidFailWithError: error];
}

@end


@interface MNFBSessionWrapper : NSObject<FBSessionDelegate,FBDialogDelegate>
{
    @public

    Facebook* _facebook;
    id<MNSocNetFBDelegate> _delegate;
    MNSocNetSessionFB* _session;

    MNSocNetFBStreamDelegateWrapper*        _streamDelegateWrapper;
    MNSocNetFBPermissionDelegateWrapper*    _permissionDelegateWrapper;
    MNSocNetFBGenericDialogDelegateWrapper* _genericDialogDelegateWrapper;
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

-(void) showGenericDialogWithAction:(NSString*) action
                             params:(NSDictionary*) params
                        andDelegate:(id<MNSocNetFBGenericDialogDelegate>) delegate;

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

        _streamDelegateWrapper        = [[MNSocNetFBStreamDelegateWrapper alloc] init];
        _permissionDelegateWrapper    = [[MNSocNetFBPermissionDelegateWrapper alloc] init];
        _genericDialogDelegateWrapper = [[MNSocNetFBGenericDialogDelegateWrapper alloc] init];
    }

    return self;
}

-(void) dealloc {
    [_facebook release];
    [_streamDelegateWrapper release];
    [_permissionDelegateWrapper release];
    [_genericDialogDelegateWrapper release];
    [super dealloc];
}

-(void) updateStoredToken:(NSString*) accessToken expiresAt:(NSDate*) expirationDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject: accessToken    forKey: MNSocNetFBAccessTokenDefaultsKey];
    [defaults setObject: expirationDate forKey: MNSocNetFBExpirationDateDefaultsKey];

    [defaults synchronize];
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
                             actionLinks, @"action_links", targetId, @"target_id", nil]
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

-(void) showGenericDialogWithAction:(NSString*) action
                             params:(NSDictionary*) params
                        andDelegate:(id<MNSocNetFBGenericDialogDelegate>) delegate {
    if (_facebook != nil && _genericDialogDelegateWrapper.delegate == nil) {
        _genericDialogDelegateWrapper.delegate = delegate;

        [_facebook dialog: action
                andParams: [NSMutableDictionary dictionaryWithDictionary: params]
              andDelegate: _genericDialogDelegateWrapper];
    }
}

- (void)fbDidLogin {
    [self updateStoredToken: [_facebook accessToken] expiresAt: [_facebook expirationDate]];

    [_delegate socNetFBLoginOk: _session];
}

- (void)fbDidLogout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:MNSocNetFBAccessTokenDefaultsKey];
    [defaults removeObjectForKey:MNSocNetFBExpirationDateDefaultsKey];

    [defaults synchronize];

    [_delegate socNetFBLoggedOut];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        [_delegate socNetFBLoginCanceled];
    }
    else {
        [_delegate socNetFBLoginFailed];
    }
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expirationDate {
    [self updateStoredToken: accessToken expiresAt: expirationDate];

    MNSocNetAuthTokenChangedEvent* data = [[[MNSocNetAuthTokenChangedEvent alloc]
                                            initWithToken: _facebook.accessToken
                                            andExpirationDate: _facebook.expirationDate] autorelease];

    [_delegate socNetFBTokenStatusChangedWithData: data];
}

- (void)fbSessionInvalidated {
    MNSocNetAuthTokenChangedEvent* data = [[[MNSocNetAuthTokenChangedEvent alloc]
                                            initWithToken: nil
                                            andExpirationDate: nil] autorelease];

    [_delegate socNetFBTokenStatusChangedWithData: data];
}

@end


static BOOL isFacebookUrl (NSURL* url) {
    NSString* urlString = [url absoluteString];

    return [urlString hasPrefix: @"fb"];
}

/* facebook application does not allow to use digits in url scheme suffix, */
/* so we need to encode game id into sequence of letter characters         */
/* the following scheme is used:  0 is encoded as 'a',  1 - as 'b',  ...,  */
/* 9 - as 'j'                                                              */

#define MNFB_INT64_MAX_STRLEN (19 + 1) // 19 digits plus sign

static NSString* encodeIntegerToUrlSchemeEncoding (NSInteger value) {
    BOOL isNegative = NO;
    char buffer[MNFB_INT64_MAX_STRLEN + 1]; // use buffer which is enough for even 64-bit ints

    if (value < 0) {
        isNegative = YES;
        value      = -value;
    }

    unsigned int offset = MNFB_INT64_MAX_STRLEN;

    buffer[offset] = '\0';

    while (value > 0 && offset > 0) {
        buffer[--offset] = 'a' + value % 10;
        value /= 10;
    }

    if (isNegative && offset > 0) {
        buffer[--offset] = '-';
    }

    return [NSString stringWithUTF8String: &buffer[offset]];
}
                                                  
static NSString* getUrlSchemeSuffixByGameId (NSInteger gameId) {
    return [NSString stringWithFormat: @"mn%@", encodeIntegerToUrlSchemeEncoding(gameId)];
}

@implementation MNSocNetSessionFB

-(id) initWithGameId:(NSInteger) gameId andDelegate:(id<MNSocNetFBDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _fbSessionWrapper = [[MNFBSessionWrapper alloc] initWithSocNetSessionFB: self andDelegate: delegate];
        _gameId           = gameId;
        _fbAppId          = nil;
        _fbUrlToHandle    = nil;
        _useSSO           = NO;
    }

    return self;
}

-(void) dealloc {
    [_fbUrlToHandle release];
    [_fbAppId release];
    [_fbSessionWrapper release];
    [super dealloc];
}

-(void) setFBAppId:(NSString*) appId useSSO:(BOOL) useSSO {
    if (_fbAppId != nil && ![appId isEqualToString: _fbAppId]) {
        NSLog(@"WARNING: facebook appid changed during app runtime");
    }

    [_fbAppId release];

    _fbAppId = [appId retain];
    _useSSO  = useSSO;

    if (_fbSessionWrapper->_facebook == nil) {
        if (_useSSO) {
            _fbSessionWrapper->_facebook = [[Facebook alloc] initWithAppId: _fbAppId
                                                           urlSchemeSuffix: getUrlSchemeSuffixByGameId(_gameId)
                                                               andDelegate: _fbSessionWrapper];
        }
        else {
            _fbSessionWrapper->_facebook = [[Facebook alloc] initWithAppId: _fbAppId andDelegate: _fbSessionWrapper];
        }

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

-(void) extendAccessToken {
    Facebook* fb = _fbSessionWrapper->_facebook;

    if (fb == nil) {
        NSLog(@"WARNING: extendAccessToken is called before facebook become available");

        return;
    }

    if ([fb shouldExtendAccessToken]) {
        [fb extendAccessToken];
    }
    else {
        MNSocNetAuthTokenChangedEvent* data = [[[MNSocNetAuthTokenChangedEvent alloc]
                                                initWithToken: fb.accessToken
                                                andExpirationDate: fb.expirationDate] autorelease];

        [_fbSessionWrapper->_delegate socNetFBTokenStatusChangedWithData: data];
    }
}

-(BOOL) handleOpenURL:(NSURL*) url {
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
}

-(BOOL) connectWithPermissions:(NSArray*) permissions andFillErrorMessage:(NSString**) error {
    if (_fbSessionWrapper->_facebook == nil) {
        if (error != NULL) {
            *error = [NSString stringWithString: MNLocalizedString(@"Facebook API key and/or session proxy URL is invalid or not set",MNMessageCodeFacebookAPIKeyOrSessionProxyURLIsInvalidOrNotSetError)];
        }

        return NO;
    }

    if (_useSSO) {
        [_fbSessionWrapper->_facebook authorize: (permissions != nil ? permissions : [NSArray array])];
    }
    else {
        [_fbSessionWrapper->_facebook authorizeWithFBAppAuth: NO safariAuth: NO permissions: (permissions != nil ? permissions : [NSArray array])];
    }

    return YES;
}

-(BOOL) resumeAndFillErrorMessage:(NSString**) error {
    return [self connectWithPermissions: nil andFillErrorMessage: error];
}

-(void) logout {
    [_fbSessionWrapper->_facebook logout: _fbSessionWrapper];
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

-(void) showGenericDialogWithAction:(NSString*) action
                             params:(NSDictionary*) params
                        andDelegate:(id<MNSocNetFBGenericDialogDelegate>) delegate {
    [_fbSessionWrapper showGenericDialogWithAction:(NSString*) action params: params andDelegate: delegate];
}

@end


@implementation MNSocNetAuthTokenChangedEvent

@synthesize accessToken    = _accessToken;
@synthesize expirationDate = _expirationDate;
@synthesize errorMessage   = _errorMessage;

-(id) initWithToken:(NSString*) accessToken andExpirationDate:(NSDate*) expirationDate {
    self = [super init];

    if (self != nil) {
        _accessToken    = [accessToken copy];
        _expirationDate = [expirationDate copy];
        _errorMessage   = nil;
    }

    return self;
}

-(BOOL) isError {
    return _errorMessage != nil;
}

-(void) dealloc {
    [_accessToken release];
    [_expirationDate release];
    [_errorMessage release];

    [super dealloc];
}

@end
