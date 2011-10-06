//
//  MNWSCurrUserSubscriptionStatus.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/27/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MNWSRequest.h"

@interface MNWSCurrUserSubscriptionStatus : MNWSGenericItem {
}

-(NSNumber*) getHasSubscription;
-(NSString*) getOffersAvailable;
-(NSNumber*) getIsSubscriptionAvailable;

@end

