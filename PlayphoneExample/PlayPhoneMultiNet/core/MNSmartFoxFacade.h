//
//  MNSmartFoxFacade.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/20/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "external/SmartFox/Header/INFSmartFoxiPhoneClient.h"

#import "MNCommon.h"
#import "MNConfigData.h"

@protocol MNSmartFoxFacadeDelegate<NSObject>
-(void) onPreLoginSucceeded:(MNUserId) userId
        userName:(NSString*) userName
        userSID:(NSString*) sid
        lobbyRoomId:(NSInteger) lobbyRoomId
        userAuthSign:(NSString*) userAuthSign;
-(void) onLoginSucceeded;
-(void) onLoginFailed:(NSString*) error;
-(void) onConnectionLost;

-(void) mnConfigLoadStarted;
-(void) mnConfigDidLoad;
-(void) mnConfigLoadDidFailWithError:(NSString*) error;
@end

@class MNSmartFoxFacadeLoginInfo;
@class MNSmartFoxFacadeSessionInfo;
@class MNSmartFoxFacadeConnectActivity;

@interface MNSmartFoxFacade : NSObject<INFSmartFoxISFSEvents,MNConfigDataDelegate> {
    @private

    INFSmartFoxiPhoneClient *smartFox;

    MNSmartFoxFacadeLoginInfo* loginInfo;
    BOOL loginOnConfigLoaded;

    MNSmartFoxFacadeSessionInfo* sessionInfo;

    NSUInteger state;
    id<MNSmartFoxFacadeDelegate> delegate;
    id<INFSmartFoxISFSEvents> smartFoxDelegate;

    BOOL reconnectOnNetErrors;
    MNSmartFoxFacadeConnectActivity* connectActivity;

    @public

    MNConfigData* configData;
}

@property (nonatomic,retain) INFSmartFoxiPhoneClient* smartFox;
@property (nonatomic,assign) id<MNSmartFoxFacadeDelegate> delegate;
@property (nonatomic,assign) id<INFSmartFoxISFSEvents> smartFoxDelegate;
@property (nonatomic,assign) BOOL reconnectOnNetErrors;

-(id) initWithConfigRequest:(NSURLRequest*) configRequest;
-(void) dealloc;
-(void) loadConfig;
-(void) loginAs:(NSString*) userLogin withPassword:(NSString*) userPassword
        toZone:(NSString*) zone;
-(void) logout;
-(void) relogin;

-(void) restoreConnection;

-(BOOL) haveLoginInfo;
-(NSString*) getLoginInfoLogin;
-(void) updateLoginInfoWithLogin:(NSString*) login andPassword:(NSString*) password;

-(NSString*) getUserNameBySFId:(NSInteger) userSFId;

-(BOOL) isLoggedIn;

@end
