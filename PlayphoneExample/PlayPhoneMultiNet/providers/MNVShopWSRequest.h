//
//  MNVShopWSRequest.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNURLDownloader.h"
#import "MNVItemsProvider.h"

@protocol MNVShopWSRequestSetDelegate;

@interface MNVShopWSRequestSet : NSObject<MNURLDownloaderDelegate> {
@private
    id<MNVShopWSRequestSetDelegate> _delegate;
    NSMutableSet*                   _requests;
}

-(id) initWithMNVShopWSRequestSetDelegate:(id<MNVShopWSRequestSetDelegate>) delegate;
-(void) sendRequestWithURL:(NSString*) url andParams:(NSMutableDictionary*) params clientTransactionId:(MNVItemTransactionId) clientTransactionId;
-(void) cancelAll;

@end


@protocol MNVShopWSRequestSetDelegate<NSObject>
-(void)     mnVShopWSRequestSet:(MNVShopWSRequestSet*) requestSet
 requestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              didFinishWithData:(NSData*) data;

-(void)     mnVShopWSRequestSet:(MNVShopWSRequestSet*) requestSet
 requestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
               didFailWithError:(NSString*) error;
@end


@protocol MNVShopPurchaseWSRequestHelperDelegate<NSObject>
-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithNetworkError:(NSString*) error;
-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithXMLParseError:(NSString*) error;
-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithXMLStructureError:(NSString*) error;
-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithWSError:(NSString*) error code:(int) errorCode;
-(BOOL) mnVShopPurchaseWSRequestBeginParsingForUserId:(MNUserId) userId;
-(BOOL) mnVShopPurchaseWSRequestProcessFinishTransactionCommand:(NSString*) transactionId;
-(BOOL) mnVShopPurchaseWSRequestProcessPostVItemTransactionCommandWithSrvTransactionId:(NSString*) srvTransactionId
                                                                      cliTransactionId:(NSString*) cliTransactionId
                                                                            itemsToAdd:(NSString*) itemsToAdd;
-(BOOL) mnVShopPurchaseWSRequestProcessPostSysEventCommandWithName:(NSString*) cmdName
                                                             param:(NSString*) cmdParam
                                                        callbackId:(NSString*) callbackId;
-(BOOL) mnVShopPurchaseWSRequestProcessPostPluginMessageCommand:(NSString*) pluginName
                                                  pluginMessage:(NSString*) pluginMessage;
@end


@interface MNVShopPurchaseWSRequestHelper : NSObject<MNVShopWSRequestSetDelegate> {
@private
    MNSession*                                 _session;
    MNVShopWSRequestSet*                       _requestSet;
    id<MNVShopPurchaseWSRequestHelperDelegate> _delegate;
}

-(id) initWithSession:(MNSession*) session andDelegate:(id<MNVShopPurchaseWSRequestHelperDelegate>) delegate;
-(void) sendWSRequestToWS:(NSString*) wsUrl withParams:(NSDictionary*) params;
-(void) sendWSRequestToWS:(NSString*) wsUrl withParams:(NSDictionary*) params clientTransactionId:(MNVItemTransactionId) transactionId;
-(void) cancelAllWSRequests;

@end
