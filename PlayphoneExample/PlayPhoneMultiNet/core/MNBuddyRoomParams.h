//
//  MNBuddyRoomParams.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/1/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNBuddyRoomParams : NSObject {
    NSString* _roomName;
    NSInteger _gameSetId;
    NSString* _toUserIdList;
    NSString* _toUserSFIdList;
    NSString* _inviteText;
}

@property (nonatomic,retain) NSString* roomName;
@property (nonatomic,assign) NSInteger gameSetId;
@property (nonatomic,retain) NSString* toUserIdList;
@property (nonatomic,retain) NSString* toUserSFIdList;
@property (nonatomic,retain) NSString* inviteText;

-(id) init;
-(void) dealloc;

@end

