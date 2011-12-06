//
//  MNWSSessionSignedClientToken.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSSessionSignedClientToken : MNWSGenericItem {
}

-(NSString*) getClientTokenBody;
-(NSString*) getClientTokenSign;

@end

