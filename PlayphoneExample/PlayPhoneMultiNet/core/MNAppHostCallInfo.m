//
//  MNAppHostCallInfo.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 12/29/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNAppHostCallInfo.h"

NSString* MNAppHostCallCommandConnect = @"apphost_connect.php";
NSString* MNAppHostCallCommandReconnect = @"apphost_reconnect.php";
NSString* MNAppHostCallCommandGoBack = @"apphost_goback.php";
NSString* MNAppHostCallCommandLogout = @"apphost_logout.php";
NSString* MNAppHostCallCommandSendPrivateMessage = @"apphost_sendmess.php";
NSString* MNAppHostCallCommandSendPublicMessage = @"apphost_chatmess.php";
NSString* MNAppHostCallCommandJoinBuddyRoom = @"apphost_joinbuddyroom.php";
NSString* MNAppHostCallCommandJoinAutoRoom = @"apphost_joinautoroom.php";
NSString* MNAppHostCallCommandPlayGame = @"apphost_playgame.php";
NSString* MNAppHostCallCommandLoginFacebook = @"apphost_sn_facebook_login.php";
NSString* MNAppHostCallCommandResumeFacebook = @"apphost_sn_facebook_resume.php";
NSString* MNAppHostCallCommandLogoutFacebook = @"apphost_sn_facebook_logout.php";
NSString* MNAppHostCallCommandShowFacebookPublishDialog = @"apphost_sn_facebook_dialog_publish_show.php";
NSString* MNAppHostCallCommandShowFacebookPermissionDialog = @"apphost_sn_facebook_dialog_permission_req_show.php";
NSString* MNAppHostCallCommandImportAddressBook = @"apphost_do_user_ab_import.php";
NSString* MNAppHostCallCommandGetAddressBookData = @"apphost_get_user_ab_data.php";
NSString* MNAppHostCallCommandNewBuddyRoom = @"apphost_newbuddyroom.php";
NSString* MNAppHostCallCommandStartRoomGame = @"apphost_start_room_game.php";
NSString* MNAppHostCallCommandGetContext = @"apphost_get_context.php";
NSString* MNAppHostCallCommandGetRoomUserList = @"apphost_get_room_userlist.php";
NSString* MNAppHostCallCommandGetGameResults = @"apphost_get_game_results.php";
NSString* MNAppHostCallCommandLeaveRoom = @"apphost_leaveroom.php";
NSString* MNAppHostCallCommandImportUserPhoto = @"apphost_do_photo_import.php";
NSString* MNAppHostCallCommandSetRoomUserStatus = @"apphost_set_room_user_status.php";
NSString* MNAppHostCallCommandNavBarShow = @"apphost_navbar_show.php";
NSString* MNAppHostCallCommandNavBarHide = @"apphost_navbar_hide.php";
NSString* MNAppHostCallCommandScriptEval = @"apphost_script_eval.php";
NSString* MNAppHostCallCommandWebViewReload = @"apphost_webview_reload.php";
NSString* MNAppHostCallCommandVarSave = @"apphost_var_save.php";
NSString* MNAppHostCallCommandVarsClear = @"apphost_vars_clear.php";
NSString* MNAppHostCallCommandVarsGet = @"apphost_vars_get.php";
NSString* MNAppHostCallCommandVoid = @"apphost_void.php";
NSString* MNAppHostCallCommandSetHostParam = @"apphost_set_host_param.php";
NSString* MNAppHostCallCommandPluginMessageSubscribe = @"apphost_plugin_message_subscribe.php";
NSString* MNAppHostCallCommandPluginMessageUnSubscribe = @"apphost_plugin_message_unsubscribe.php";
NSString* MNAppHostCallCommandPluginMessageSend = @"apphost_plugin_message_send.php";
NSString* MNAppHostCallCommandSendHttpRequest = @"apphost_http_request.php";
NSString* MNAppHostCallCommandSetGameResults = @"apphost_set_game_results.php";
NSString* MNAppHostCallCommandExecUICommand = @"apphost_exec_ui_command.php";
NSString* MNAppHostCallCommandAddSourceDomain = @"apphost_add_source_domain.php";
NSString* MNAppHostCallCommandRemoveSourceDomain = @"apphost_remove_source_domain.php";
NSString* MNAppHostCallCommandAppIsInstalledQuery = @"apphost_app_is_installed.php";
NSString* MNAppHostCallCommandAppTryLaunch = @"apphost_app_try_launch.php";
NSString* MNAppHostCallCommandAppShowInMarket = @"apphost_app_show_in_market.php";

@implementation MNAppHostCallInfo

@synthesize commandName   = _commandName;
@synthesize commandParams = _commandParams;

+(id) mnAppHostCallInfoWithCommand:(NSString*) command andParams:(NSDictionary*) params {
    return [[[MNAppHostCallInfo alloc] initWithCommand: command andParams: params] autorelease];
}

-(id) initWithCommand:(NSString*) command andParams:(NSDictionary*) params {
    self = [super init];

    if (self != nil) {
        _commandName   = [command retain];
        _commandParams = [params  retain];
    }

    return self;
}

-(void) dealloc {
    [_commandName   release];
    [_commandParams release];

    [super dealloc];
}

@end
