/*
 *  MNConst.h
 *  MultiNet client
 *
 *  Created by Sergey Prokhorchuk on 5/27/09.
 *  Copyright 2009 PlayPhone. All rights reserved.
 *
 */

/**
 * Constants describing player status
 */
enum {
    MN_USER_STATUS_UNDEFINED = 0,
    MN_USER_PLAYER = 1,
    MN_USER_CHATER = 100
};

#define MN_USER_ACCOUNT_STATUS_GUEST         (0)
#define MN_USER_ACCOUNT_STATUS_PROVISIONAL  (10)
#define MN_USER_ACCOUNT_STATUS_NORMAL      (100)

#define MNSmartFoxUserIdUndefined (-1)
#define MNSmartFoxRoomIdUndefined (-1)
#define MNUserIdUndefined         (0)

/**
 * Constants describing MultiNet session state
 */
enum {
    MN_OFFLINE       = 0,   /**< MultiNet session is inactive */
    MN_CONNECTING    = 1,   /**< MultiNet login procedure is in progress */
    MN_LOGGEDIN      = 50,  /**< MultiNet session is active, user is in lobby room */
    MN_IN_GAME_WAIT  = 100, /**< MultiNet session is active, user is waiting for other players in game room */
    MN_IN_GAME_START = 110, /**< MultiNet session is active, countdown in progress */
    MN_IN_GAME_PLAY  = 120, /**< MultiNet session is active, game is in progress */
    MN_IN_GAME_END   = 180  /**< MultiNet session is active, game have been ended recently */
};

