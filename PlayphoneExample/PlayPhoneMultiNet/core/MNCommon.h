/*
 *  MNCommon.h
 *  MultiNet client
 *
 *  Created by Sergey Prokhorchuk on 5/27/09.
 *  Copyright 2009 PlayPhone. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "MNConst.h"

#define MNLobbyRoomIdUndefined    (-1)
#define MNSocNetUserIdUndefined   (-1)

#define MNDeviceTypeiPhoneiPod (1000)

#define MNSocNetIdFaceBook (1)

extern NSString* MNClientAPIVersion;

typedef long long MNUserId;
typedef long long MNSocNetUserId;

#define MN_CREDENTIALS_WIPE_NONE (0)
#define MN_CREDENTIALS_WIPE_USER (1)
#define MN_CREDENTIALS_WIPE_ALL  (2)

