//
//  MNErrorInfo.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 9/15/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNErrorInfo.h"

@implementation MNErrorInfo

@synthesize actionCode = _actionCode;
@synthesize errorMessage = _errorMessage;

+(id) errorInfoWithActionCode:(NSInteger) actionCode andErrorMessage:(NSString*) errorMessage {
    return [[[MNErrorInfo alloc] initWithActionCode: actionCode andErrorMessage: errorMessage] autorelease];
}

-(id) initWithActionCode:(NSInteger) actionCode andErrorMessage:(NSString*) errorMessage {
    self = [super init];

    if (self != nil) {
        self.actionCode   = actionCode;
        self.errorMessage = errorMessage;
    }

    return self;
}

-(void) dealloc {
    [_errorMessage release];

    [super dealloc];
}

@end
