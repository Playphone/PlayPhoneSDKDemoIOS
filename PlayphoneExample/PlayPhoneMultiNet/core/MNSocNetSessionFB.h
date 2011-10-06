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

@interface MNSocNetSessionFB : NSObject {
    @private

    MNFBSessionWrapper* _fbSessionWrapper;
    NSString*           _fbAppId;
    NSURL*              _fbUrlToHandle;
}

-(id) initWithDelegate:(id<MNSocNetFBDelegate>) delegate;
-(void) dealloc;

-(void) setFBAppId:(NSString*) appId;
-(BOOL) handleOpenURL:(NSURL*) url;

-(BOOL) connectWithPermissions:(NSArray*) permissions andFillErrorMessage:(NSString**) error;
-(BOOL) resumeAndFillErrorMessage:(NSString**) error;
-(void) logout;

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

@end

@protocol MNSocNetFBDelegate<NSObject>
-(void) socNetFBLoginOk:(MNSocNetSessionFB*) session;
-(void) socNetFBLoginCanceled;
-(void) socNetFBLoginFailed;
-(void) socNetFBLoggedOut;
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
