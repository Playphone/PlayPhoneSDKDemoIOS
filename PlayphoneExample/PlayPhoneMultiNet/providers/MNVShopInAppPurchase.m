//
//  MNVShopInAppPurchase.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 6/23/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "TouchXML.h"

#import "MNTools.h"
#import "MNURLDownloader.h"
#import "MNWSXmlTools.h"
#import "MNVItemsProvider.h"
#import "MNVShopInAppPurchase.h"

NSString* MNVShopInAppPurchaseWSURLPath = @"user_ajax_proc_app_purchase.php";

static void MNVShopInAppPurchaseWriteLog(NSString* message) {
    NSLog(@"MNVShopInAppPurchase: %@",message);
}

// Internal interface of MNVItemsProvider
@interface MNVItemsProvider()
-(MNVItemsTransactionInfo*) applyTransactionFromDictionary:(NSDictionary*) params vItemsItemSeparator:(NSString*) vItemsItemSeparator vItemsFieldSeparator:(NSString*) vItemsFieldSeparator;
@end

// Internal interface of MNVShopProvider
@interface MNVShopProvider()
-(void) dispatchCheckoutSucceededForTransaction:(MNVItemsTransactionInfo*) transactionInfo;
@end

@implementation MNVShopInAppPurchase

-(id) initWithSession:(MNSession*) session vShopProvider:(MNVShopProvider*) vShopProvider andVItemsProvider:(MNVItemsProvider*) vItemsProvider {
    self = [super init];

    if (self != nil) {
        _session         = [session retain];
        _requestHelper   = [[MNVShopPurchaseWSRequestHelper alloc] initWithSession: session andDelegate: self];
        _vItemsProvider  = vItemsProvider;
        _vShopProvider   = vShopProvider;
        _knownProductIds = [[NSMutableSet alloc] init];
        _pendingPayments = [[NSMutableDictionary alloc] init];

        [_session addDelegate: self];

        [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    }

    return self;
}

-(void) dealloc {
    [_session removeDelegate: self];
    [_requestHelper cancelAllWSRequests];
    [_requestHelper release];
    [_session release];

    [_pendingPayments release];
    [_knownProductIds release];

    [super dealloc];
}

-(void) sendWSRequestWithParams:(NSMutableDictionary*) params {
    NSString* webServerUrl = [_session getWebServerURL];

    if (webServerUrl != nil) {
        [_requestHelper sendWSRequestToWS: [NSString stringWithFormat: @"%@/%@",webServerUrl,MNVShopInAppPurchaseWSURLPath] withParams: params];
    }
}

-(void) sendSystemEvent:(NSString*) name withParams:(NSDictionary*) params {
    NSString* encodedParams = MNGetRequestStringFromParams(params);

    [_session postSysEvent: name withParam: encodedParams andCallbackId: nil];
}

-(void) sendPurchaseSucceededWSRequest:(SKPaymentTransaction*) transaction {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   transaction.transactionIdentifier, @"proc_transaction_id",
                                   @"0",@"proc_transaction_status",
                                   MNDataGetBase64String(transaction.transactionReceipt),@"proc_transaction_receipt",
                                   transaction.payment.productIdentifier,@"proc_transaction_app_store_item_id",
                                   [NSString stringWithFormat: @"%d",transaction.payment.quantity],@"proc_transaction_purchase_amount",
                                   nil];

    [self sendSystemEvent: @"sys.onAppPurchaseWillSendTransactionDoneNotify"
               withParams: [NSDictionary dictionaryWithObjectsAndKeys:
                             transaction.transactionIdentifier, @"transactionId",
                             transaction.payment.productIdentifier,@"transactionPurchaseItemId",
                             [NSString stringWithFormat: @"%d",transaction.payment.quantity],@"transactionPurchaseItemCound",
                             nil]];

    [self sendWSRequestWithParams: params];
}

-(void) sendPurchaseFailedWSRequest:(SKPaymentTransaction*) transaction {
    NSString* errorCodeStr = [NSString stringWithFormat: @"%d",[transaction.error code]];

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   transaction.transactionIdentifier, @"proc_transaction_id",
                                   @"-1",@"proc_transaction_status",
                                   transaction.payment.productIdentifier,@"proc_transaction_app_store_item_id",
                                   errorCodeStr,@"proc_transaction_error_code",
                                   [transaction.error domain],@"proc_transaction_error_domain",
                                   [transaction.error localizedDescription],@"proc_transaction_error_message",
                                   nil];

    [self sendSystemEvent: @"sys.onAppPurchaseWillSendTransactionFailNotify"
               withParams: [NSDictionary dictionaryWithObjectsAndKeys:
                             transaction.transactionIdentifier, @"transactionId",
                             transaction.payment.productIdentifier,@"transactionPurchaseItemId",
                             [NSString stringWithFormat: @"%d",transaction.payment.quantity],@"transactionPurchaseItemCound",
                             errorCodeStr,@"errorCode",
                             [transaction.error localizedDescription],@"errorMessage",
                             nil]];

    [self sendWSRequestWithParams: params];
}

-(void) sendPurchasePendingWSRequest:(SKPaymentTransaction*) transaction {
    [self sendSystemEvent: @"sys.onAppPurchaseTransactionPendingNotify"
               withParams: [NSDictionary dictionaryWithObjectsAndKeys:
                            transaction.transactionIdentifier, @"transactionId",
                            transaction.payment.productIdentifier,@"transactionPurchaseItemId",
                            [NSString stringWithFormat: @"%d",transaction.payment.quantity],@"transactionPurchaseItemCound",
                            nil]];
}

-(void) updateTransactionQueue:(NSArray*) transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case (SKPaymentTransactionStatePurchased) : {
                [self sendPurchaseSucceededWSRequest: transaction];
            } break;

            case (SKPaymentTransactionStateFailed) : {
                [self sendPurchaseFailedWSRequest: transaction];
            } break;

            case (SKPaymentTransactionStatePurchasing) : {
                [self sendPurchasePendingWSRequest: transaction];
            } break;

            case (SKPaymentTransactionStateRestored)   : {
                // ignore
            } break;

            default: {
                NSLog(@"unexpected transaction state (%d) in transaction queue",transaction.transactionState);
            }
        }
    }
}

-(void) addPaymentForProduct:(NSString*) productId andCount:(MNVItemCount) count {
    SKMutablePayment* payment = [SKMutablePayment paymentWithProductIdentifier: productId];

    payment.quantity = count;

    [[SKPaymentQueue defaultQueue] addPayment: payment];
}

-(void) makePendingPaymentsForProduct:(NSString*) productId {
    NSMutableArray* pendingPaymentsForProduct = [_pendingPayments objectForKey: productId];

    if (pendingPaymentsForProduct != nil) {
        for (NSNumber* count in pendingPaymentsForProduct) {
            [self addPaymentForProduct: productId andCount: [count longLongValue]];
        }
    }

    [_pendingPayments removeObjectForKey: productId];
}

-(void) addPendingPaymentForProduct:(NSString*) productId andCount:(MNVItemCount) count {
    NSMutableArray* pendingPaymentsForProduct = [_pendingPayments objectForKey: productId];

    if (pendingPaymentsForProduct != nil) {
        [pendingPaymentsForProduct addObject: [NSNumber numberWithLongLong: count]];
    }
    else {
        [_pendingPayments setObject: [NSMutableArray arrayWithObject: [NSNumber numberWithLongLong: count]] forKey: productId];

        SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: productId]];

        request.delegate = self;

        [request start];
    }
}

/* SKPaymentQueueObserver protocol */
-(void) paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*) transactions {
    if (![_session isOnline]) {
        // ignore updates, will process them after connection to server will be eastablished
        return;
    }

    [self updateTransactionQueue: transactions];
}

- (void)request:(SKRequest*) request didFailWithError:(NSError*) error {
    [request autorelease];
}

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*) response {
    for (SKProduct* product in response.products) {
        NSString* productId = product.productIdentifier;

        [_knownProductIds addObject: productId];

        [self makePendingPaymentsForProduct: productId];
    }

    //NOTE: payment will fail and system will be notified
    for (NSString* productId in response.invalidProductIdentifiers) {
        [self makePendingPaymentsForProduct: productId];
    }

    [request autorelease];
}

static BOOL isLoggedIn (NSUInteger status) {
    return status != MN_OFFLINE && status != MN_CONNECTING;
}

/* MNSessionDelegate protocol */
-(void) mnSessionStatusChangedTo:(NSUInteger) newStatus from:(NSUInteger) oldStatus {
    if (isLoggedIn(newStatus)) {
        if (!isLoggedIn(oldStatus)) {
            [self updateTransactionQueue: [[SKPaymentQueue defaultQueue] transactions]];
        }
    }
    else {
        if (isLoggedIn(oldStatus)) {
            // user logged out, transactions will not be finished anyway, so cancel all pending request.
            // payments will be (re)processes next time user login
            [_requestHelper cancelAllWSRequests];
        }
    }
}

-(void) mnSessionWebEventReceived:(NSString*) eventName withParam:(NSString*) eventParam andCallbackId:(NSString*) callbackId {
    if (![eventName isEqualToString: @"web.doAppPurchaseStartTransaction"]) {
        return;
    }

    if (![SKPaymentQueue canMakePayments]) {
        return;
    }

    NSDictionary* params = MNCopyDictionaryWithGetRequestParamString(eventParam);
    NSString*     productId    = [params objectForKey: @"transactionPurchaseItemId"];
    MNVItemCount  productCount = MNStringScanLongLongWithDefValue([params objectForKey: @"transactionPurchaseItemCount"],0);

    if (productId == nil || productCount <= 0) {
        MNVShopInAppPurchaseWriteLog(@"invalid product id or count in 'start app purchase' event");
        return;
    }

    if ([_knownProductIds containsObject: productId]) {
        [self addPaymentForProduct: productId andCount: productCount];
    }
    else {
        [self addPendingPaymentForProduct: productId andCount: productCount];
    }
}

-(SKPaymentTransaction*) findTransactionById:(NSString*) transactionId {
    NSArray* transactions = ([SKPaymentQueue defaultQueue]).transactions;

    BOOL       found = NO;
    NSUInteger index = 0;
    NSUInteger count = [transactions count];
    SKPaymentTransaction* transaction = nil;

    while (!found && index < count) {
        transaction = [transactions objectAtIndex: index];

        if ([transaction.transactionIdentifier isEqualToString: transactionId]) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? transaction : nil;
}

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithNetworkError:(NSString*) error {
    MNVShopInAppPurchaseWriteLog([NSString stringWithFormat: @"purchase ws request failed with network error: %@",error]);
}

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithXMLParseError:(NSString*) error {
    MNVShopInAppPurchaseWriteLog([NSString stringWithFormat: @"ws response is not a valid xml data: %@",error]);
}

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithXMLStructureError:(NSString*) error {
    MNVShopInAppPurchaseWriteLog([NSString stringWithFormat: @"ws response has incorrect or unsupported structure: %@",error]);
}

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithWSError:(NSString*) error code:(int) errorCode {
    MNVShopInAppPurchaseWriteLog([NSString stringWithFormat: @"ws error: %@ (with code %d)",error,errorCode]);
}

-(BOOL) mnVShopPurchaseWSRequestBeginParsingForUserId:(MNUserId) userId {
    return userId == [_session getMyUserId];
}

-(BOOL) mnVShopPurchaseWSRequestProcessFinishTransactionCommand:(NSString*) transactionId {
    if (transactionId != nil) {
        SKPaymentTransaction* transaction = [self findTransactionById: transactionId];

        if (transaction != nil) {
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        }
        else {
            MNVShopInAppPurchaseWriteLog(@"unknown transaction in 'finish transaction' ws command");
        }
    }
    else {
        MNVShopInAppPurchaseWriteLog(@"invalid transaction id value in 'finish transaction' ws command");
    }

    return YES;
}

-(BOOL) mnVShopPurchaseWSRequestProcessPostVItemTransactionCommandWithSrvTransactionId:(NSString*) srvTransactionId
                                                                      cliTransactionId:(NSString*) cliTransactionId
                                                                            itemsToAdd:(NSString*) itemsToAdd {
    MNVItemTransactionId clientTransactionIdValue;
    MNVItemTransactionId serverTransactionIdValue;

    if (MNStringScanLongLong(&clientTransactionIdValue,cliTransactionId) &&
        MNStringScanLongLong(&serverTransactionIdValue,srvTransactionId) &&
        itemsToAdd != nil) {
        NSDictionary* transactionParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           cliTransactionId, @"client_transaction_id",
                                           srvTransactionId, @"server_transaction_id",
                                           @"0",@"corr_user_id",
                                           itemsToAdd,@"items_to_add",
                                           nil];

        MNVItemsTransactionInfo* transactionInfo = [_vItemsProvider applyTransactionFromDictionary: transactionParams vItemsItemSeparator: @"," vItemsFieldSeparator: @":"];

        if (transactionInfo != nil) {
            [_vShopProvider dispatchCheckoutSucceededForTransaction: transactionInfo];
        }
        else {
            MNVShopInAppPurchaseWriteLog(@"transaction cannot be processed by vItemsProvider");
        }
    }
    else {
        MNVShopInAppPurchaseWriteLog(@"incorrect format of 'post transaction' ws command");
    }

    return YES;
}

-(BOOL) mnVShopPurchaseWSRequestProcessPostSysEventCommandWithName:(NSString*) cmdName
                                                             param:(NSString*) cmdParam
                                                        callbackId:(NSString*) callbackId {
    if (cmdName != nil) {
        [_session postSysEvent: cmdName withParam: cmdParam == nil ? @"" : cmdParam andCallbackId: callbackId];
    }
    else {
        MNVShopInAppPurchaseWriteLog(@"event name is undefined in 'post sys event' ws command");
    }

    return YES;
}

-(BOOL) mnVShopPurchaseWSRequestProcessPostPluginMessageCommand:(NSString*) pluginName
                                                  pluginMessage:(NSString*) pluginMessage {
    if (pluginName != nil && pluginMessage != nil) {
        [_session sendPlugin: pluginName message: pluginMessage];
    }
    else {
        MNVShopInAppPurchaseWriteLog(@"plugin name or message is undefined in 'post plugin message' ws command");
    }

    return YES;
}

@end
