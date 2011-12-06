//
//  MNWSSessionSignedClientToken.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSSessionSignedClientToken.h"

@implementation MNWSSessionSignedClientToken

-(NSString*) getClientTokenBody {
    return [self getValueByName :@"client_token_body"];
}

-(NSString*) getClientTokenSign {
    return [self getValueByName :@"client_token_sign"];
}


@end

