//
//  MNSocNetSessionFB.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/16/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNCommon.h"

@class Facebook;
@class MNFBSessionWrapper;

@protocol MNSocNetFBDelegate;
@protocol MNSocNetFBStreamDialogDelegate;
@protocol MNSocNetFBPermissionDialogDelegate;
@protocol MNSocNetFBGenericDialogDelegate;

@interface MNSocNetSessionFB : NSObject {
    @private

    MNFBSessionWrapper* _fbSessionWrapper;
    NSInteger           _gameId;
    NSString*           _fbAppId;
    NSURL*              _fbUrlToHandle;
    BOOL                _useSSO;
}

-(id) initWithGameId:(NSInteger) gameId andDelegate:(id<MNSocNetFBDelegate>) delegate;
-(void) dealloc;

-(void) setFBAppId:(NSString*) appId useSSO:(BOOL) useSSO;
-(BOOL) handleOpenURL:(NSURL*) url;

-(BOOL) connectWithPermissions:(NSArray*) permissions andFillErrorMessage:(NSString**) error;
-(BOOL) resumeAndFillErrorMessage:(NSString**) error;
-(void) logout;

-(void) extendAccessToken;

-(BOOL) isConnected;

-(MNSocNetUserId) getUserId;
-(NSString*) getSessionKey;
-(NSString*) getSessionSecret;
-(BOOL) didUserStoreCredentials;

-(Facebook*) getFacebook;

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

@end


@interface MNSocNetAuthTokenChangedEvent : NSObject {
@private
    NSString* _accessToken;
    NSDate*   _expirationDate;
    NSString* _errorMessage;
}

@property (nonatomic,retain) NSString* accessToken;
@property (nonatomic,retain) NSDate*   expirationDate;
@property (nonatomic,retain) NSString* errorMessage;

-(id) initWithToken:(NSString*) accessToken andExpirationDate:(NSDate*) expirationDate;
-(BOOL) isError;

@end


@protocol MNSocNetFBDelegate<NSObject>
-(void) socNetFBLoginOk:(MNSocNetSessionFB*) session;
-(void) socNetFBLoginCanceled;
-(void) socNetFBLoginFailed;
-(void) socNetFBLoggedOut;
-(void) socNetFBTokenStatusChangedWithData:(MNSocNetAuthTokenChangedEvent*) data;
@end

@protocol MNSocNetFBStreamDialogDelegate<NSObject>
-(void) socNetFBStreamDialogDidSucceed;
-(void) socNetFBStreamDialogDidCancel;
-(void) socNetFBStreamDialogDidFailWithError:(NSError*) error;
@end

@protocol MNSocNetFBPermissionDialogDelegate<NSObject>
-(void) socNetFBPermissionDialogDidSucceed;
-(void) socNetFBPermissionDialogDidCancel;
-(void) socNetFBPermissionDialogDidFailWithError:(NSError*) error;
@end

@protocol MNSocNetFBGenericDialogDelegate<NSObject>
-(void) socNetFBGenericDialogDidSucceedWithUrl:(NSURL*) url;
-(void) socNetFBGenericDialogDidCancelWithUrl:(NSURL*) url;
-(void) socNetFBGenericDialogDidFailWithError:(NSError*) error;
@end
