//
//  MNUserCredentials.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 8/12/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNCommon.h"
#import "MNVarStorage.h"

@interface MNUserCredentials : NSObject
{
    @private

    MNUserId _userId;
    NSString* _userName;
    NSString* _userAuthSign;
    NSDate* _lastLoginTime;
    NSString* _userAuxInfoText;
}

@property (nonatomic,assign) MNUserId userId;
@property (nonatomic,retain) NSString* userName;
@property (nonatomic,retain) NSString* userAuthSign;
@property (nonatomic,retain) NSDate* lastLoginTime;
@property (nonatomic,retain) NSString* userAuxInfoText;

+(MNUserCredentials*) mnUserCredentialsWithId:(MNUserId) userId
                      name:(NSString*) name
                      authSign:(NSString*) authSign
                      lastLoginTime:(NSDate*) lastLoginTime
                      andAuxInfoText:(NSString*) auxInfoText;

-(id) initWithId:(MNUserId) userId
      name:(NSString*) name
      authSign:(NSString*) authSign
      lastLoginTime:(NSDate*) lastLoginTime
      andAuxInfoText:(NSString*) auxInfoText;
-(void) dealloc;

@end

extern NSArray* MNUserCredentialsLoad (MNVarStorage* varStorage);
extern void MNUserCredentialsWipeByUserId (MNVarStorage* varStorage, MNUserId userId);
extern void MNUserCredentialsWipeAll (MNVarStorage* varStorage);
extern void MNUserCredentialsUpdateUser (MNVarStorage* varStorage,MNUserId userId, NSString* userName, NSString* userAuthSign, NSDate* lastLoginTime, NSString* userAuxInfoText);
extern MNUserCredentials* MNUserCredentialsGetMostRecentlyLoggedUserCredentials (MNVarStorage* varStorage);
extern MNUserCredentials* MNUserCredentialsGetByUserId (MNVarStorage* varStorage, MNUserId userId);
