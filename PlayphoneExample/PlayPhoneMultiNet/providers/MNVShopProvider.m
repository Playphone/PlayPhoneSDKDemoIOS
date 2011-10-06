//
//  MNVShopProvider.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/17/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TouchXML.h"

#import "MNTools.h"
#import "MNDelegateArray.h"
#import "MNGameVocabulary.h"
#import "MNWSXmlTools.h"
#import "MNVShopInAppPurchase.h"
#import "MNVShopProvider.h"

static NSString* MNVShopProviderVocabularyFileName = @"MNVShopProvider.xml";
static NSString* MNVShopProviderImageUrlFormat = @"%@/data_game_vshoppack_image.php?game_id=%d&gameshoppack_id=%d";
static NSString* MNVShopPurchaseSilentWSURLPath = @"user_ajax_proc_silent_purchase.php";

static void MNVShopWriteLog(NSString* message) {
    NSLog(@"MNVShopProvider: %@",message);
}

static NSString* mnStringWithIntList (NSArray* array) {
    NSMutableString* result = [NSMutableString string];
    NSUInteger index;
    NSUInteger count = [array count];

    if (count > 0) {
        [result appendFormat: @"%d",[((NSNumber*)[array objectAtIndex: 0]) intValue]];

        for (index = 1; index < count; index++) {
            [result appendFormat: @",%d",[((NSNumber*)[array objectAtIndex: index]) intValue]];
        }
    }

    return result;
}

// Internal interface of MNVItemsProvider
@interface MNVItemsProvider()
-(MNVItemsTransactionInfo*) applyTransactionFromDictionary:(NSDictionary*) params vItemsItemSeparator:(NSString*) vItemsItemSeparator vItemsFieldSeparator:(NSString*) vItemsFieldSeparator;
@end

// Internal interface of MNVShopProvider
@interface MNVShopProvider()
-(void) dispatchCheckoutSucceededForTransaction:(MNVItemsTransactionInfo*) transactionInfo;
@end


@implementation MNVShopProviderCheckoutVShopPackSuccessInfo

@synthesize transaction = _transaction;

-(id) initWithTransactionInfo:(MNVItemsTransactionInfo*) transaction {
    self = [super init];

    if (self != nil) {
        _transaction = [transaction retain];
    }

    return self;
}

@end


@implementation MNVShopProviderCheckoutVShopPackFailInfo

@synthesize errorCode           = _errorCode;
@synthesize errorMessage        = _errorMessage;
@synthesize clientTransactionId = _clientTransactionid;

-(id) initWithErrorCode:(int) errorCode errorMessage:(NSString*) errorMessage andClientTransactionId:(MNVItemTransactionId) clientTransactionId {
    self = [super init];

    if (self != nil) {
        _errorCode           = errorCode;
        _errorMessage        = [errorMessage retain];
        _clientTransactionid = clientTransactionId;
    }

    return self;
}

@end


@implementation MNVShopDeliveryInfo

@synthesize vItemId = _vItemId;
@synthesize amount  = _amount;

-(id) initWithVItemId:(int)vItemId andAmount:(long long)amount {
    self = [super init];

    if (self != nil) {
        _vItemId = vItemId;
        _amount  = amount;
    }

    return self;
}

@end

@implementation MNVShopPackInfo

@synthesize packId         = _packId;
@synthesize name           = _name;
@synthesize model          = _model;
@synthesize description    = _description;
@synthesize appParams      = _appParams;
@synthesize sortPos        = _sortPos;
@synthesize categoryId     = _categoryId;
@synthesize delivery       = _delivery;
@synthesize priceItemId    = _priceItemId;
@synthesize priceValue     = _priceValue;

-(id) initWithId:(int) packId andName:(NSString*) name {
    self = [super init];

    if (self != nil) {
        _packId      = packId;
        _name        = [name retain];
        _model       = 0;
        _description = [[NSString alloc] init];
        _appParams   = [[NSString alloc] init];
        _sortPos     = 0;
        _categoryId  = 0;
        _delivery    = nil;
        _priceItemId = 0;
        _priceValue  = 0;
    }

    return self;
}

-(void) dealloc {
    [_name release];
    [_description release];
    [_appParams release];
    [_delivery release];

    [super dealloc];
}

@end


@implementation MNVShopCategoryInfo

@synthesize categoryId = _categoryId;
@synthesize name       = _name;
@synthesize sortPos    = _sortPos;

-(id) initWithId:(int) categoryId andName:(NSString*) name {
    self = [super init];

    if (self != nil) {
        _categoryId = categoryId;
        _name       = [name retain];
        _sortPos    = 0;
    }

    return self;
}

-(void) dealloc {
    [_name release];

    [super dealloc];
}

@end


@implementation MNVShopProvider

-(id) initWithSession: (MNSession*) session andVItemsProvider:(MNVItemsProvider*) vItemsProvider {
    self = [super init];

    if (self != nil) {
        _session        = session;
        _vItemsProvider = [vItemsProvider retain];
        _inAppPurchase  = [[MNVShopInAppPurchase alloc] initWithSession: session vShopProvider: self andVItemsProvider: _vItemsProvider];
        _requestHelper  = [[MNVShopPurchaseWSRequestHelper alloc] initWithSession: session andDelegate: self];
        _delegates      = [[MNDelegateArray alloc] init];

        [_session addDelegate: self];

        [[_session getGameVocabulary] addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [_requestHelper cancelAllWSRequests];
    [_requestHelper release];
    [_inAppPurchase release];
    [_vItemsProvider release];

    [[_session getGameVocabulary] removeDelegate: self];
    [_session removeDelegate: self];

    [_delegates release];

    [super dealloc];
}

-(NSArray*) getVShopPackList {
    NSMutableArray* packs    = [NSMutableArray array];
    NSData*         fileData = [[_session getGameVocabulary] getFileData: MNVShopProviderVocabularyFileName];

    if (fileData != nil) {
        NSError *error;
        CXMLDocument *document;

        document = [[CXMLDocument alloc] initWithData: fileData options: 0 error: &error];

        CXMLElement* listElement = MNWSXmlDocumentGetElementByPath(document,[NSArray arrayWithObjects: @"GameVocabulary", @"MNVShopProvider", @"VShopPacks", nil]);

        if (listElement != nil) {
            NSArray* packsData = MNWSXmlNodeParseItemList(listElement,@"entry");

            for (NSDictionary* packData in packsData) {
                NSInteger packId;

                if (MNStringScanInteger(&packId,[packData valueForKey: @"id"])) {
                    NSString* name   = [packData valueForKey: @"name"];
                    NSString* desc   = [packData valueForKey: @"desc"];
                    NSString* params = [packData valueForKey: @"params"];

                    MNVShopPackInfo* packInfo = [[[MNVShopPackInfo alloc] initWithId: packId andName: name != nil ? name : @""] autorelease];

                    packInfo.model = MNStringScanIntegerWithDefValue([packData valueForKey: @"model"],0);

                    packInfo.description    = desc != nil ? desc : @"";
                    packInfo.appParams      = params != nil ? params : @"";
                    packInfo.sortPos        = MNStringScanIntegerWithDefValue([packData valueForKey: @"sortPos"],0);
                    packInfo.categoryId     = MNStringScanIntegerWithDefValue([packData valueForKey: @"categoryId"],0);

                    int       deliveryItemId = MNStringScanIntegerWithDefValue([packData valueForKey: @"deliveryItemId"],0);
                    long long deliveryAmount = MNStringScanLongLongWithDefValue([packData valueForKey: @"deliveryItemAmount"],0);

                    packInfo.delivery = [NSArray arrayWithObjects: [[[MNVShopDeliveryInfo alloc] initWithVItemId: deliveryItemId andAmount: deliveryAmount] autorelease], nil];

                    packInfo.priceItemId    = MNStringScanIntegerWithDefValue([packData valueForKey: @"priceItemId"],0);
                    packInfo.priceValue     = MNStringScanLongLongWithDefValue([packData valueForKey: @"priceValue"],0);

                    [packs addObject: packInfo];
                }
                else {
                    NSLog(@"warning: vshop package data with invalid or absent package id ignored");
                }
            }
        }
        else {
            NSLog(@"warning: cannot find \"VShopPacks\" element in game vocabulary");
        }

        [document release];
    }

    return packs;
}

-(MNVShopPackInfo*) findVShopPackById:(int) vShopPackId {
    MNVShopPackInfo* pack;

    NSArray*   packs = [self getVShopPackList];
    BOOL       found = NO;
    NSUInteger index = 0;
    NSUInteger count = [packs count];

    while (!found && index < count) {
        pack = [packs objectAtIndex: index];

        if (pack.packId == vShopPackId) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? pack : nil;
}

-(NSArray*) getVShopCategoryList {
    NSMutableArray* categories = [NSMutableArray array];
    NSData*         fileData   = [[_session getGameVocabulary] getFileData: MNVShopProviderVocabularyFileName];

    if (fileData != nil) {
        NSError *error;
        CXMLDocument *document;

        document = [[CXMLDocument alloc] initWithData: fileData options: 0 error: &error];

        CXMLElement* listElement = MNWSXmlDocumentGetElementByPath(document,[NSArray arrayWithObjects: @"GameVocabulary", @"MNVShopProvider", @"VShopCategories", nil]);

        if (listElement != nil) {
            NSArray* categoriesData = MNWSXmlNodeParseItemList(listElement,@"entry");

            for (NSDictionary* categoryData in categoriesData) {
                NSInteger categoryId;

                if (MNStringScanInteger(&categoryId,[categoryData valueForKey: @"id"])) {
                    NSString* name   = [categoryData valueForKey: @"name"];

                    MNVShopCategoryInfo* categoryInfo = [[[MNVShopCategoryInfo alloc] initWithId: categoryId andName: name != nil ? name : @""] autorelease];

                    categoryInfo.sortPos = MNStringScanIntegerWithDefValue([categoryData valueForKey: @"sortPos"],0);

                    [categories addObject: categoryInfo];
                }
                else {
                    NSLog(@"warning: vshop category data with invalid or absent category id ignored");
                }
            }
        }
        else {
            NSLog(@"warning: cannot find \"VShopCategories\" element in game vocabulary");
        }

        [document release];
    }

    return categories;
}

-(MNVShopCategoryInfo*) findVShopCategoryById:(int) vShopCategoryId {
    MNVShopCategoryInfo* category;

    NSArray*   categories = [self getVShopCategoryList];
    BOOL       found = NO;
    NSUInteger index = 0;
    NSUInteger count = [categories count];

    while (!found && index < count) {
        category = [categories objectAtIndex: index];

        if (category.categoryId == vShopCategoryId) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? category : nil;
}

-(BOOL) isVShopInfoNeedUpdate {
    return [[_session getGameVocabulary] getVocabularyStatus] > 0;
}

-(void) doVShopInfoUpdate {
    MNGameVocabulary* gameVocabulary = [_session getGameVocabulary];

    if ([gameVocabulary getVocabularyStatus] != MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS) {
        [gameVocabulary startDownload];
    }
}

-(NSURL*) getVShopPackImageURL:(int) packId {
    NSString* webServerUrl = [_session getWebServerURL];

    if (webServerUrl != nil) {
        return [NSURL URLWithString:
                [NSString stringWithFormat: MNVShopProviderImageUrlFormat,webServerUrl,[_session getGameId],packId]];
    }
    else {
        return nil;
    }
}

-(void) dispatchCheckoutFailedEventWithErrorCode:(int) errorCode errorMessage:(NSString*) errorMessage andClientTransactionId:(MNVItemTransactionId) clientTransactionId {
    MNVShopProviderCheckoutVShopPackFailInfo* info =
    [[MNVShopProviderCheckoutVShopPackFailInfo alloc] initWithErrorCode: errorCode
                                                           errorMessage: errorMessage
                                                 andClientTransactionId: clientTransactionId];

    MN_DELEGATE_ARRAY_CALL_ARG1(MNVShopProviderDelegate,_delegates,onCheckoutVShopPackFail,info);

    [info release];
}

-(void) dispatchCheckoutSucceededForTransaction:(MNVItemsTransactionInfo*) transactionInfo {
    MNVShopProviderCheckoutVShopPackSuccessInfo* info = [[MNVShopProviderCheckoutVShopPackSuccessInfo alloc] initWithTransactionInfo: transactionInfo];

    MN_DELEGATE_ARRAY_CALL_ARG1(MNVShopProviderDelegate,_delegates,onCheckoutVShopPackSuccess,info);

    [info release];
}

-(void) execCheckoutVShopPacks:(NSArray*) packIdArray packCount:(NSArray*) packCount clientTransactionId:(MNVItemTransactionId) clientTransactionId {
    NSString* packIdStr    = mnStringWithIntList(packIdArray);
    NSString* packCountStr = mnStringWithIntList(packCount);

    [_session execAppCommand: @"jumpToBuyVShopPackRequestDialogSimple"
                   withParam: [NSString stringWithFormat: @"pack_id=%@&buy_count=%@&client_transaction_id=%lld",packIdStr,packCountStr,clientTransactionId]];
}

-(void) procCheckoutVShopPacksSilent:(NSArray*) packIdArray packCount:(NSArray*) packCount clientTransactionId:(MNVItemTransactionId) clientTransactionId {
    NSString* webServerUrl = [_session getWebServerURL];

    if (webServerUrl != nil) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       mnStringWithIntList(packIdArray),@"proc_pack_id",
                                       mnStringWithIntList(packCount),@"proc_pack_count",
                                       [NSString stringWithFormat: @"%lld",clientTransactionId],@"proc_client_transaction_id",
                                       nil];

        [_requestHelper sendWSRequestToWS: [NSString stringWithFormat: @"%@/%@",webServerUrl,MNVShopPurchaseSilentWSURLPath]
                               withParams: params
                      clientTransactionId: clientTransactionId];
    }
    else {
        [self dispatchCheckoutFailedEventWithErrorCode: MN_VSHOP_PROVIDER_ERROR_CODE_NETWORK_ERROR errorMessage: @"checkout endpoint is unreachable" andClientTransactionId: clientTransactionId];
    }
}

-(void) addDelegate:(id<MNVShopProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNVShopProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

/* MNGameVocabularyDelegate protocol */
-(void) mnGameVocabularyDownloadFinished:(int) downloadStatus {
    if (downloadStatus > 0) {
        [_delegates beginCall];

        for (id<MNVShopProviderDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(onVShopInfoUpdated)]) {
                [delegate onVShopInfoUpdated];
            }
        }

        [_delegates endCall];
    }
}

/* MNSessionDelegate protocol */

-(void) mnSessionExecUICommandReceived:(NSString*) cmdName withParam:(NSString*) cmdParam {
    BOOL ok = NO;

    if ([cmdName isEqualToString: @"onVShopNeedShowDashboard"]) {
        MN_DELEGATE_ARRAY_CALL_NOARG(MNVShopProviderDelegate,_delegates,showDashboard);

        return;
    }
    else if ([cmdName isEqualToString: @"onVShopNeedHideDashboard"]) {
        MN_DELEGATE_ARRAY_CALL_NOARG(MNVShopProviderDelegate,_delegates,hideDashboard);

        return;
    }
    else if ([cmdName isEqualToString: @"afterBuyVShopPackRequestSuccess"]) {
        ok = YES;
    }
    else if ([cmdName isEqualToString: @"afterBuyVShopPackRequestFail"]) {
    }
    else {
        return;
    }

    NSDictionary* params = MNCopyDictionaryWithGetRequestParamString(cmdParam);

    if (ok) {
        MNVItemsTransactionInfo* transactionInfo = [_vItemsProvider applyTransactionFromDictionary: params vItemsItemSeparator: @"\n" vItemsFieldSeparator: @"\t"];

        [self dispatchCheckoutSucceededForTransaction: transactionInfo];
    }
    else {
        int errorCode = MNStringScanIntegerWithDefValue
                         ([params objectForKey: @"error_code"],MN_VSHOP_PROVIDER_ERROR_CODE_UNDEFINED);
        NSString* errorMessage  = [params objectForKey: @"error_message"];
        MNVItemTransactionId cliTransactionId = MNStringScanLongLongWithDefValue
                                                 ([params objectForKey: @"client_transaction_id"],0);

        [self dispatchCheckoutFailedEventWithErrorCode: errorCode errorMessage: errorMessage andClientTransactionId: cliTransactionId];
    }

    [params release];
}

/* MNVShopPurchaseWSRequestHelperDelegate protocol */

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithNetworkError:(NSString*) error {
    [self dispatchCheckoutFailedEventWithErrorCode: MN_VSHOP_PROVIDER_ERROR_CODE_NETWORK_ERROR errorMessage: error andClientTransactionId: clientTransactionId];
}

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithXMLParseError:(NSString*) error {
    [self dispatchCheckoutFailedEventWithErrorCode: MN_VSHOP_PROVIDER_ERROR_CODE_XML_PARSE_ERROR errorMessage: error andClientTransactionId: clientTransactionId];
}

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithXMLStructureError:(NSString*) error {
    [self dispatchCheckoutFailedEventWithErrorCode: MN_VSHOP_PROVIDER_ERROR_CODE_XML_STRUCTURE_ERROR errorMessage: error andClientTransactionId: clientTransactionId];
}

-(void) mnVShopPurchaseWSRequestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId didFailWithWSError:(NSString*) error code:(int) errorCode {
    [self dispatchCheckoutFailedEventWithErrorCode: errorCode errorMessage: error andClientTransactionId: clientTransactionId];
}

-(BOOL) mnVShopPurchaseWSRequestBeginParsingForUserId:(MNUserId) userId {
    return userId == [_session getMyUserId];
}

-(BOOL) mnVShopPurchaseWSRequestProcessFinishTransactionCommand:(NSString*) transactionId {
    MNVShopWriteLog(@"unexpected 'finish transaction' command received");

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
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                srvTransactionId,@"server_transaction_id",
                                cliTransactionId,@"client_transaction_id",
                                itemsToAdd,@"items_to_add",
                                nil];

        MNVItemsTransactionInfo* transactionInfo = [_vItemsProvider applyTransactionFromDictionary: params
                                                                               vItemsItemSeparator: @","
                                                                              vItemsFieldSeparator: @":"];

        MNVShopProviderCheckoutVShopPackSuccessInfo* info = [[MNVShopProviderCheckoutVShopPackSuccessInfo alloc] initWithTransactionInfo: transactionInfo];

        MN_DELEGATE_ARRAY_CALL_ARG1(MNVShopProviderDelegate,_delegates,onCheckoutVShopPackSuccess,info);

        [info release];
    }
    else {
        MNVShopWriteLog(@"incorrect format of 'post transaction' ws command");
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
        MNVShopWriteLog(@"event name is undefined in 'post sys event' ws command");
    }

    return YES;
}

-(BOOL) mnVShopPurchaseWSRequestProcessPostPluginMessageCommand:(NSString*) pluginName
                                                  pluginMessage:(NSString*) pluginMessage {
    if (pluginName != nil && pluginMessage != nil) {
        [_session sendPlugin: pluginName message: pluginMessage];
    }
    else {
        MNVShopWriteLog(@"plugin name or message is undefined in 'post plugin message' ws command");
    }

    return YES;
}

@end
