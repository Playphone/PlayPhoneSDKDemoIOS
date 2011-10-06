//
//  MNVShopWSRequest.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import "TouchXML.h"

#import "MNTools.h"
#import "MNWSXmlTools.h"

#import "MNVShopWSRequest.h"

#define MNVShopWSRequestDefaultErrorCode (100)

@interface MNVShopWSRequestInfo : NSObject {
@private
    MNURLDownloader*     _downloader;
    MNVItemTransactionId _clientTransactionId;
}

@property (nonatomic,retain) MNURLDownloader*     downloader;
@property (nonatomic,assign) MNVItemTransactionId clientTransactionId;

-(id) init;
-(void) dealloc;

@end


@implementation MNVShopWSRequestInfo

@synthesize downloader          = _downloader;
@synthesize clientTransactionId = _clientTransactionId;

-(id) init {
    self = [super init];

    if (self != nil) {
        _downloader          = nil;
        _clientTransactionId = 0;
    }

    return self;
}

-(void) dealloc {
    [_downloader release];

    [super dealloc];
}

@end


@implementation MNVShopWSRequestSet

-(id) initWithMNVShopWSRequestSetDelegate:(id<MNVShopWSRequestSetDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _delegate = delegate;
        _requests = [[NSMutableSet alloc] init];
    }

    return self;
}

-(void) dealloc {
    [self cancelAll];
    [_requests release];

    [super dealloc];
}

-(void) sendRequestWithURL:(NSString*) url andParams:(NSMutableDictionary*) params clientTransactionId:(MNVItemTransactionId) clientTransactionId {
    MNURLDownloader*      downloader  = [[MNURLDownloader alloc] init];
    MNVShopWSRequestInfo* requestInfo = [[MNVShopWSRequestInfo alloc] init];

    requestInfo.downloader          = downloader;
    requestInfo.clientTransactionId = clientTransactionId;

    [_requests addObject: requestInfo];

    [downloader loadRequest: MNGetURLRequestWithPostMethod([NSURL URLWithString: url],params) delegate: self];
    [downloader release];
    [requestInfo release];
}

-(void) cancelAll {
    for (MNVShopWSRequestInfo* requestInfo in _requests) {
        [requestInfo.downloader cancel];
    }

    [_requests removeAllObjects];
}

-(MNVShopWSRequestInfo*) requestInfoByDownloader:(MNURLDownloader*) downloader {
    for (MNVShopWSRequestInfo* requestInfo in _requests) {
        if (requestInfo.downloader == downloader) {
            return requestInfo;
        }
    }

    return nil;
}

-(MNVShopWSRequestInfo*) completeDownload:(MNURLDownloader*) downloader {
    MNVShopWSRequestInfo* requestInfo = [[[self requestInfoByDownloader: downloader] retain] autorelease];

//    [[downloader retain] autorelease]; // to prevent downloader from been deallocated right now

    if (requestInfo != nil) {
        [_requests removeObject: requestInfo];
    }

    return requestInfo;
}

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    MNVShopWSRequestInfo* requestInfo = [self completeDownload: downloader];

    [_delegate mnVShopWSRequestSet: self
    requestWithClientTransactionId: requestInfo == nil ? 0 : requestInfo.clientTransactionId
                 didFinishWithData: data];
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    MNVShopWSRequestInfo* requestInfo = [self completeDownload: downloader];

    [_delegate mnVShopWSRequestSet: self
    requestWithClientTransactionId: requestInfo == nil ? 0 : requestInfo.clientTransactionId
                  didFailWithError: error.message];
}

@end


@implementation  MNVShopPurchaseWSRequestHelper

-(id) initWithSession:(MNSession*) session andDelegate:(id<MNVShopPurchaseWSRequestHelperDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _session  = session;
        _delegate = delegate;
        _requestSet = [[MNVShopWSRequestSet alloc] initWithMNVShopWSRequestSetDelegate: self];
    }

    return  self;
}

-(void) dealloc {
    [_requestSet release];

    [super dealloc];
}

-(void) sendWSRequestToWS:(NSString*) wsUrl withParams:(NSDictionary*) params clientTransactionId:(MNVItemTransactionId) clientTransactionId {
    NSString* userSId = [_session getMySId];

    if (userSId == nil) {
        [_delegate mnVShopPurchaseWSRequestWithClientTransactionId: clientTransactionId didFailWithNetworkError: @"user is not logged in"];

        return;
    }

    NSMutableDictionary* wsParams = [[NSMutableDictionary alloc] initWithDictionary: params];

    [wsParams setObject: [NSString stringWithFormat: @"%d",[_session getGameId]] forKey: @"ctx_game_id"];
    [wsParams setObject: [NSString stringWithFormat: @"%d",[_session getDefaultGameSetId]] forKey: @"ctx_gameset_id"];
    [wsParams setObject: [NSString stringWithFormat: @"%lld",[_session getMyUserId]] forKey: @"ctx_user_id"];
    [wsParams setObject: userSId forKey: @"ctx_user_sid"];
    [wsParams setObject: MNGetDeviceIdMD5() forKey: @"ctx_dev_id"];
    [wsParams setObject: [NSString stringWithFormat: @"%d", MNDeviceTypeiPhoneiPod] forKey: @"ctx_dev_type"];
    [wsParams setObject: MNClientAPIVersion forKey: @"ctx_client_ver"];

    [_requestSet sendRequestWithURL: wsUrl andParams: wsParams clientTransactionId: clientTransactionId];

    [wsParams release];
}

-(void) sendWSRequestToWS:(NSString*) wsUrl withParams:(NSDictionary*) params {
    [self sendWSRequestToWS:wsUrl withParams: params clientTransactionId: 0];
}

-(void) cancelAllWSRequests {
    [_requestSet cancelAll];
}

-(BOOL) processWSCmdFinishTransaction:(CXMLElement*) cmdElement {
    NSString* transactionId = nil;

    CXMLElement* transactionIdElement = MNWSXmlNodeGetFirstChildElement(cmdElement);

    if ([[transactionIdElement name] isEqualToString: @"srcTransactionId"]) {
        transactionId = [transactionIdElement stringValue];
    }

    return [_delegate mnVShopPurchaseWSRequestProcessFinishTransactionCommand: transactionId];
}

-(BOOL) processWSCmdPostVItemTransaction:(CXMLElement*) cmdElement {
    NSString* clientTransactionIdStr = nil;
    NSString* serverTransactionIdStr = nil;
    NSString* vItemsToAddStr         = nil;

    CXMLElement* currElement = MNWSXmlNodeGetFirstChildElement(cmdElement);

    while (currElement != nil) {
        NSString* name = [currElement name];

        if ([name isEqualToString: @"clientTransactionId"]) {
            clientTransactionIdStr = [currElement stringValue];
        }
        else if ([name isEqualToString: @"serverTransactionId"]) {
            serverTransactionIdStr = [currElement stringValue];
        }
        else if ([name isEqualToString: @"itemsToAdd"]) {
            vItemsToAddStr = [currElement stringValue];
        }

        currElement = MNWSXmlNodeGetNextSiblingElement(currElement);
    }

    return [_delegate mnVShopPurchaseWSRequestProcessPostVItemTransactionCommandWithSrvTransactionId: serverTransactionIdStr
                                                                                    cliTransactionId: clientTransactionIdStr
                                                                                          itemsToAdd: vItemsToAddStr];
}

-(BOOL) processWSCmdPostSysEvent:(CXMLElement*) cmdElement {
    NSString* eventName  = nil;
    NSString* eventParam = nil;
    NSString* callbackId = nil;

    CXMLElement* currElement = MNWSXmlNodeGetFirstChildElement(cmdElement);

    while (currElement != nil) {
        NSString* name = [currElement name];

        if ([name isEqualToString: @"eventName"]) {
            eventName = [currElement stringValue];
        }
        else if ([name isEqualToString: @"eventParam"]) {
            eventParam = [currElement stringValue];
        }
        else if ([name isEqualToString: @"callbackId"]) {
            callbackId = [currElement stringValue];
        }

        currElement = MNWSXmlNodeGetNextSiblingElement(currElement);
    }

    return [_delegate mnVShopPurchaseWSRequestProcessPostSysEventCommandWithName: eventName param: eventParam callbackId: callbackId];
}

-(BOOL) processWSCmdPostPluginMessage:(CXMLElement*) cmdElement {
    NSString* pluginName    = nil;
    NSString* pluginMessage = nil;

    CXMLElement* currElement = MNWSXmlNodeGetFirstChildElement(cmdElement);

    while (currElement != nil) {
        NSString* name = [currElement name];

        if ([name isEqualToString: @"pluginName"]) {
            pluginName = [currElement stringValue];
        }
        else if ([name isEqualToString: @"pluginMessage"]) {
            pluginMessage = [currElement stringValue];
        }

        currElement = MNWSXmlNodeGetNextSiblingElement(currElement);
    }

    return [_delegate mnVShopPurchaseWSRequestProcessPostPluginMessageCommand: pluginName pluginMessage: pluginMessage];
}

/* MNVShopWSRequestSetDelegate protocol */
-(void)     mnVShopWSRequestSet:(MNVShopWSRequestSet*) requestSet
 requestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              didFinishWithData:(NSData*) data {
    NSError      *error;
    CXMLDocument *document;

    document = [[CXMLDocument alloc] initWithData: data options: 0 error: &error];

    if (document == nil) {
        [_delegate mnVShopPurchaseWSRequestWithClientTransactionId: clientTransactionId didFailWithXMLParseError: [error localizedDescription]];

        return;
    }

    CXMLNode* rootElement = [document rootElement];

    if ([[rootElement name] isEqualToString: @"responseData"]) {
        CXMLElement* cmdElement = MNWSXmlNodeGetFirstChildElement(rootElement);
        NSString*    cmdName    = [cmdElement name];

        if ([cmdName isEqualToString: @"ctxUserId"]) {
            MNUserId recvUserId;

            if (MNStringScanLongLong(&recvUserId,[cmdElement stringValue])) {
                if ([_delegate mnVShopPurchaseWSRequestBeginParsingForUserId: recvUserId]) {
                    BOOL cont = YES;

                    cmdElement = MNWSXmlNodeGetNextSiblingElement(cmdElement);

                    while (cmdElement != nil && cont) {
                        NSString* cmdName = [cmdElement name];

                        if      ([cmdName isEqualToString: @"finishTransaction"]) {
                            cont = [self processWSCmdFinishTransaction: cmdElement];
                        }
                        else if ([cmdName isEqualToString: @"postVItemTransaction"]) {
                            cont = [self processWSCmdPostVItemTransaction: cmdElement];
                        }
                        else if ([cmdName isEqualToString: @"postSysEvent"]) {
                            cont = [self processWSCmdPostSysEvent: cmdElement];
                        }
                        else if ([cmdName isEqualToString: @"postPluginMessage"]) {
                            cont = [self processWSCmdPostPluginMessage: cmdElement];
                        }
                        else {
                            NSLog(@"vshop ws response contains unsupported command (%@)",cmdName);
                        }

                        cmdElement = MNWSXmlNodeGetNextSiblingElement(cmdElement);
                    }
                }
            }
            else {
                [_delegate mnVShopPurchaseWSRequestWithClientTransactionId: clientTransactionId didFailWithXMLStructureError: @"ws response contains incorrect 'ctxUserId' element"];
            }
        }
        else if ([cmdName isEqualToString: @"errorMessage"]) {
            int       errorCode     = MNVShopWSRequestDefaultErrorCode;
            CXMLNode* errorCodeNode = [cmdElement attributeForName: @"code"];

            if (errorCodeNode != nil) {
                errorCode = MNStringScanIntegerWithDefValue([errorCodeNode stringValue],MNVShopWSRequestDefaultErrorCode);
            }

            [_delegate mnVShopPurchaseWSRequestWithClientTransactionId: clientTransactionId didFailWithWSError: [cmdElement stringValue] code: errorCode];
        }
        else {
            [_delegate mnVShopPurchaseWSRequestWithClientTransactionId: clientTransactionId didFailWithXMLStructureError: @"ws response data does not contain neither 'ctxUserId' nor 'errorMessage' element"];
        }
    }
    else {
        [_delegate mnVShopPurchaseWSRequestWithClientTransactionId: clientTransactionId didFailWithXMLStructureError: @"ws response document element is not 'responseData'"];
    }

    [document release];
}

-(void)     mnVShopWSRequestSet:(MNVShopWSRequestSet*) requestSet
 requestWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
               didFailWithError:(NSString*) error {
    [_delegate mnVShopPurchaseWSRequestWithClientTransactionId: clientTransactionId didFailWithNetworkError: error];
}

@end
