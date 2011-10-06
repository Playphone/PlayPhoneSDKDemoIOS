//
//  MNAppHostCallInfo.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 12/29/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* MNAppHostCallCommandConnect;
extern NSString* MNAppHostCallCommandReconnect;
extern NSString* MNAppHostCallCommandGoBack;
extern NSString* MNAppHostCallCommandLogout;
extern NSString* MNAppHostCallCommandSendPrivateMessage;
extern NSString* MNAppHostCallCommandSendPublicMessage;
extern NSString* MNAppHostCallCommandJoinBuddyRoom;
extern NSString* MNAppHostCallCommandJoinAutoRoom;
extern NSString* MNAppHostCallCommandPlayGame;
extern NSString* MNAppHostCallCommandLoginFacebook;
extern NSString* MNAppHostCallCommandResumeFacebook;
extern NSString* MNAppHostCallCommandLogoutFacebook;
extern NSString* MNAppHostCallCommandShowFacebookPublishDialog;
extern NSString* MNAppHostCallCommandShowFacebookPermissionDialog;
extern NSString* MNAppHostCallCommandImportAddressBook;
extern NSString* MNAppHostCallCommandGetAddressBookData;
extern NSString* MNAppHostCallCommandNewBuddyRoom;
extern NSString* MNAppHostCallCommandStartRoomGame;
extern NSString* MNAppHostCallCommandGetContext;
extern NSString* MNAppHostCallCommandGetRoomUserList;
extern NSString* MNAppHostCallCommandGetGameResults;
extern NSString* MNAppHostCallCommandLeaveRoom;
extern NSString* MNAppHostCallCommandImportUserPhoto;
extern NSString* MNAppHostCallCommandSetRoomUserStatus;
extern NSString* MNAppHostCallCommandNavBarShow;
extern NSString* MNAppHostCallCommandNavBarHide;
extern NSString* MNAppHostCallCommandScriptEval;
extern NSString* MNAppHostCallCommandWebViewReload;
extern NSString* MNAppHostCallCommandVarSave;                 // cannot be intercepted via mnSessionAppHostCallReceived:
extern NSString* MNAppHostCallCommandVarsClear;               // cannot be intercepted via mnSessionAppHostCallReceived:
extern NSString* MNAppHostCallCommandVarsGet;                 // cannot be intercepted via mnSessionAppHostCallReceived:
extern NSString* MNAppHostCallCommandVoid;
extern NSString* MNAppHostCallCommandSetHostParam;            // cannot be intercepted via mnSessionAppHostCallReceived:
extern NSString* MNAppHostCallCommandPluginMessageSubscribe;
extern NSString* MNAppHostCallCommandPluginMessageUnSubscribe;
extern NSString* MNAppHostCallCommandPluginMessageSend;
extern NSString* MNAppHostCallCommandSendHttpRequest;         // cannot be intercepted via mnSessionAppHostCallReceived:
extern NSString* MNAppHostCallCommandSetGameResults;
extern NSString* MNAppHostCallCommandExecUICommand;
extern NSString* MNAppHostCallCommandAddSourceDomain;         // cannot be intercepted via mnSessionAppHostCallReceived:
extern NSString* MNAppHostCallCommandRemoveSourceDomain;      // cannot be intercepted via mnSessionAppHostCallReceived:
extern NSString* MNAppHostCallCommandAppIsInstalledQuery;
extern NSString* MNAppHostCallCommandAppTryLaunch;
extern NSString* MNAppHostCallCommandAppShowInMarket;

@interface MNAppHostCallInfo : NSObject
{
    @private

    NSString     *_commandName;
    NSDictionary *_commandParams;
}

@property(readonly) NSString*     commandName;
@property(readonly) NSDictionary* commandParams;

+(id) mnAppHostCallInfoWithCommand:(NSString*) command andParams:(NSDictionary*) params;
-(id) initWithCommand:(NSString*) command andParams:(NSDictionary*) params;

@end
