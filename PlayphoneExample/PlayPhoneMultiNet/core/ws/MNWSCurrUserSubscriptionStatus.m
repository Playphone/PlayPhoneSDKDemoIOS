//
//  MNWSCurrUserSubscriptionStatus.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import "MNWSCurrUserSubscriptionStatus.h"

@implementation MNWSCurrUserSubscriptionStatus

-(NSNumber*) getHasSubscription {
    return [self getBooleanValue :@"has_subscription"];
}

-(NSString*) getOffersAvailable {
    return [self getValueByName :@"offers_available"];
}

-(NSNumber*) getIsSubscriptionAvailable {
    return [self getBooleanValue :@"is_subscription_available"];
}


@end

