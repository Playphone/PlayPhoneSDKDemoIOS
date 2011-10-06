//
//  MNErrorInfo.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 9/15/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Action codes.
 */
enum {
    MNErrorInfoActionCodeUndefined          =   0, /**< Action unknown / unspecified  */

    MNErrorInfoActionCodeLogin              =  11, /**< Login action.                 */
    MNErrorInfoActionCodeConnect            =  12, /**< Connect action.               */

    MNErrorInfoActionCodeFBConnect          =  21, /**< FBConnect action.             */
    MNErrorInfoActionCodeFBResume           =  22, /**< FBResume action.              */

    MNErrorInfoActionCodePostGameResult     =  51, /**< Game results posting action.  */

    MNErrorInfoActionCodeJoinGameRoom       = 101, /**< Game room joining action.     */
    MNErrorInfoActionCodeCreateBuddyRoom    = 102, /**< Buddy room creation action.   */

    MNErrorInfoActionCodeLeaveRoom          = 111, /**< Leaving room action.          */

    MNErrorInfoActionCodeSetUserStatus      = 121, /**< User status changing action.  */

    MNErrorInfoActionCodeStartBuddyRoomGame = 151, /**< Buddy room game start action. */
    MNErrorInfoActionCodeStopRoomGame       = 152, /**< Room game stop action.        */
    MNErrorInfoActionCodeLoadConfig         = 401, /**< Config loading action.        */

    MNErrorInfoActionCodeOtherMinValue      = 1001
};

/**
 * @brief Error information object
 */
@interface MNErrorInfo : NSObject {
    @private

    NSInteger _actionCode;
    NSString* _errorMessage;
}

/**
 * Action which caused error
 */
@property (nonatomic,assign) NSInteger actionCode;

/**
 * Error message
 */
@property (retain)           NSString* errorMessage;

/**
 * Creates and returns object with specified parameters.
 * @param actionCode action which caused error
 * @param errorMessage error message
 * @return A new object or nil if the object couldn't be created.
 */
+(id) errorInfoWithActionCode:(NSInteger) actionCode andErrorMessage:(NSString*) errorMessage;

/**
 * Initializes a newly allocated object with specified parameters.
 * @param actionCode action which caused error
 * @param errorMessage error message
 * @return An initialized object or nil if the object couldn't be initialized.
 */
-(id) initWithActionCode:(NSInteger) actionCode andErrorMessage:(NSString*) errorMessage;

/**
 * Destroys MNErrorInfo object and releases all acquired resources.
 */
-(void) dealloc;

@end
