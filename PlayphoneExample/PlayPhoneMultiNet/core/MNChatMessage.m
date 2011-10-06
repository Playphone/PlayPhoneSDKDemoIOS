//
//  MNChatMessage.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/25/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNChatMessage.h"

@implementation MNChatMessage

@synthesize sender = _sender;
@synthesize message = _message;
@synthesize privateMessage = _privateMessage;

-(id) initWithParams:(NSString*) message sender:(MNUserInfo*) sender privateMessage:(BOOL) privateMessage {
    self = [super init];

    if (self != nil) {
        self.message = message;
        self.sender = sender;
        self.privateMessage = privateMessage;
    }

    return self;
}

-(id) initWithPrivateMessage:(NSString*) message sender:(MNUserInfo*) sender {
    return [self initWithParams: message sender: sender privateMessage: YES];
}

-(id) initWithPublicMessage:(NSString*) message sender:(MNUserInfo*) sender {
    return [self initWithParams: message sender: sender privateMessage: NO];
}

-(void) dealloc {
    [_message release];
    [_sender release];
    [super dealloc];
}

@end
