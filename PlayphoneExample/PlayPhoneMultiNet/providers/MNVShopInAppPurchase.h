//
//  MNVShopInAppPurchase.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/23/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "MNSession.h"
#import "MNVItemsProvider.h"
#import "MNVShopProvider.h"
#import "MNVShopWSRequest.h"

@interface MNVShopInAppPurchase : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate,MNSessionDelegate,MNVShopPurchaseWSRequestHelperDelegate> {
    @private

    MNSession*                        _session;
    MNVShopPurchaseWSRequestHelper*   _requestHelper;
    MNVItemsProvider*                 _vItemsProvider;
    MNVShopProvider*                  _vShopProvider;
    NSMutableSet*                     _knownProductIds;
    NSMutableDictionary*              _pendingPayments;
}

-(id) initWithSession:(MNSession*) session vShopProvider:(MNVShopProvider*) vShopProvider andVItemsProvider:(MNVItemsProvider*) vItemsProvider;

@end
