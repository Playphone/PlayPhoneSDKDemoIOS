//
//  MNVItemsProvider.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/10/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <sys/time.h>
#import <Foundation/Foundation.h>

#import "TouchXML.h"

#import "MNTools.h"
#import "MNDelegateArray.h"
#import "MNGameVocabulary.h"
#import "MNWSXmlTools.h"
#import "MNVItemsProvider.h"

static NSString* MNVItemsProviderPluginName = @"com.playphone.mn.vi";
static NSString* MNVItemsProviderVocabularyFileName = @"MNVItemsProvider.xml";
static NSString* MNVItemsProviderMessageFieldSeparator = @"\t";
static NSString* MNVItemsProviderMessageLineSeparator = @"\n";
static NSString* MNVItemsProviderImageUrlFormat = @"%@/data_game_item_image.php?game_id=%d&game_item_id=%d";

#define PLUGIN_MESSAGE_CMD_PREFIX_LEN   (1)

static BOOL parsePlayerVItemInfoField (int* vItemId, MNVItemCount* count, NSString* message, NSString* fieldSeparator) {
    NSRange   separatorRange = [message rangeOfString: fieldSeparator];

    if (separatorRange.location != NSNotFound) {
        NSString* idStr;
        NSString* countStr;

        idStr    = [message substringToIndex: separatorRange.location];
        countStr = [message substringFromIndex: separatorRange.location + separatorRange.length];

        return MNStringScanInteger(vItemId,idStr) && MNStringScanLongLong(count,countStr);
    }
    else {
        return NO;
    }
}

static BOOL parseTransactionResultHeader (NSString*             message,
                                          MNVItemTransactionId* serverTransactionId,
                                          MNVItemTransactionId* clientTransactionId,
                                          MNUserId*             corrUserId,
                                          NSUInteger*           headerLength) {
    NSRange headerSeparatorRange = [message rangeOfString: MNVItemsProviderMessageLineSeparator];

    if (headerSeparatorRange.location == NSNotFound) {
        return NO; // invalid message - header absent
    }

    NSArray* headerFields = [[message substringToIndex: headerSeparatorRange.location] componentsSeparatedByString: MNVItemsProviderMessageFieldSeparator];

    if ([headerFields count] == 3 &&
        MNStringScanLongLong(clientTransactionId,[headerFields objectAtIndex: 0]) &&
        MNStringScanLongLong(serverTransactionId,[headerFields objectAtIndex: 1]) &&
        MNStringScanLongLong(corrUserId,[headerFields objectAtIndex: 2])) {
        *headerLength = headerSeparatorRange.location + headerSeparatorRange.length;

        return YES;
    }
    else {
        return NO; // invalid message - invalid header
    }
}

static NSMutableArray* parsePlayerVItemsListMessage (NSString* message, BOOL useTransactionItems, NSString* lineSeparator, NSString* fieldSeparator) {
    NSArray* vItemsInfoArray = [message componentsSeparatedByString: lineSeparator];
    NSUInteger index = 0;
    NSUInteger count = [vItemsInfoArray count];

    BOOL            ok     = YES;
    NSMutableArray* result = [NSMutableArray arrayWithCapacity: count];

    while (index < count && ok) {
        NSString* info = [vItemsInfoArray objectAtIndex: index];

        if ([info length] > 0) {
            int          vItemId;
            MNVItemCount vItemCount;

            if (parsePlayerVItemInfoField(&vItemId,&vItemCount,info,fieldSeparator)) {
                if (useTransactionItems) {
                    [result addObject: [[[MNTransactionVItemInfo alloc] initWithId: vItemId andDelta: vItemCount] autorelease]];
                }
                else {
                    [result addObject: [[[MNPlayerVItemInfo alloc] initWithId: vItemId andCount: vItemCount] autorelease]];
                }
            }
            else {
                ok = NO;
            }
        }

        index++;
    }

    if (ok) {
        return result;
    }
    else {
        return nil;
    }
}

static MNVItemTransactionId generateStartClientTransactionId () {
    struct timeval currentTime;

    gettimeofday(&currentTime,NULL);

    return (MNVItemTransactionId)currentTime.tv_sec * 1000 + currentTime.tv_usec / 1000;
}

@implementation MNGameVItemInfo

@synthesize vItemId = _id;
@synthesize name    = _name;
@synthesize model   = _model;
@synthesize description = _description;
@synthesize params  = _params;

-(id) initWithId:(int) vItemId name:(NSString*) name andModel:(NSUInteger) model {
    self = [super init];

    if (self != nil) {
        _id    = vItemId;
        _name  = [name retain];
        _model = model;
        _description = [[NSString alloc] init];
        _params      = [[NSString alloc] init];
    }

    return self;
}

-(void) dealloc {
    [_name release];
    [_description release];
    [_params release];

    [super dealloc];
}

@end


@implementation MNPlayerVItemInfo

@synthesize vItemId = _id;
@synthesize count   = _count;

-(id) initWithId:(int) vItemId andCount:(MNVItemCount) count {
    self = [super init];

    if (self != nil) {
        _id    = vItemId;
        _count = count;
    }

    return self;
}

@end


@implementation  MNTransactionVItemInfo

@synthesize vItemId = _id;
@synthesize delta   = _delta;

-(id) initWithId:(int) vItemId andDelta:(MNVItemCount) delta {
    self = [super init];

    if (self != nil) {
        _id    = vItemId;
        _delta = delta;
    }

    return self;
}

@end


@implementation MNVItemsTransactionInfo

@synthesize clientTransactionId = _clientTransactionId;
@synthesize serverTransactionId = _serverTransactionId;
@synthesize corrUserId          = _corrUserId;
@synthesize transactionVItems   = _vItems;

-(id) initWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              serverTransactionId:(MNVItemTransactionId) serverTransactionId
                       corrUserId:(MNUserId) corrUserId
                        andVItems:(NSArray*) vItems {
    self = [super init];

    if (self != nil) {
        _clientTransactionId = clientTransactionId;
        _serverTransactionId = serverTransactionId;
        _corrUserId          = corrUserId;
        _vItems              = [vItems retain];
    }

    return self;
}

-(void) dealloc {
    [_vItems release];

    [super dealloc];
}

@end

@interface MNVItemsMutableTransactionInfo : MNVItemsTransactionInfo {
}

-(id) initWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              serverTransactionId:(MNVItemTransactionId) serverTransactionId
                       corrUserId:(MNUserId) corrUserId
                        andVItems:(NSArray*) vItems;

-(void) addVItemInfo:(MNPlayerVItemInfo*) vItem;
@end

@implementation MNVItemsMutableTransactionInfo

-(id) initWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              serverTransactionId:(MNVItemTransactionId) serverTransactionId
                       corrUserId:(MNUserId) corrUserId
                        andVItems:(NSArray*) vItems {
    self = [super initWithClientTransactionId: clientTransactionId
                          serverTransactionId: serverTransactionId
                                   corrUserId: corrUserId
                                    andVItems: [NSMutableArray arrayWithArray: vItems]];

    return self;
}

-(void) addVItemInfo:(MNPlayerVItemInfo*) vItem {
    [(NSMutableArray*)_vItems addObject: vItem];
}

-(void) setVItems:(NSMutableArray*) vItems {
    [_vItems release];
    _vItems = [vItems retain];
}

@end


@implementation MNVItemsTransactionError

@synthesize clientTransactionId = _clientTransactionId;
@synthesize serverTransactionId = _serverTransactionId;
@synthesize corrUserId          = _corrUserId;
@synthesize failReasonCode      = _failReasonCode;
@synthesize errorMessage        = _errorMessage;

-(id) initWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              serverTransactionId:(MNVItemTransactionId) serverTransactionId
                       corrUserId:(MNUserId) corrUserId
                   failReasonCode:(NSInteger) failReasonCode
                  andErrorMessage:(NSString*) errorMessage {
    self = [super init];

    if (self != nil) {
        _clientTransactionId = clientTransactionId;
        _serverTransactionId = serverTransactionId;
        _corrUserId          = corrUserId;
        _failReasonCode      = failReasonCode;
        _errorMessage        = [errorMessage retain];
    }

    return self;
}

-(void) dealloc {
    [_errorMessage release];

    [super dealloc];
}

@end


static MNPlayerVItemInfo* getPlayerVItemInfoById (NSArray* vItems, int vItemId) {
    MNPlayerVItemInfo* vItem = nil;
    BOOL               found = NO;
    NSUInteger         index = 0;
    NSUInteger         count = [vItems count];

    while (index < count && !found) {
        vItem = [vItems objectAtIndex: index];

        if (vItem.vItemId == vItemId) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? vItem : nil;
}
    
@interface MNVItemsProvider()
-(void) processAddVItemsMessage:(NSString*) message;
-(void) processFailMessage:(NSString*) message;
-(MNPlayerVItemInfo*) playerVItemInfoRefById:(int) vItemId;
@end


@implementation MNVItemsProvider

-(id) initWithSession: (MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session           = session;
        _delegates         = [[MNDelegateArray alloc] init];
        _vItems            = [[NSMutableArray alloc] init];
        _vItemsOwnerUserId = MNUserIdUndefined;

        _cliTransactionId = generateStartClientTransactionId();

        [_session addDelegate: self];

        [[_session getGameVocabulary] addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [[_session getGameVocabulary] removeDelegate: self];
    [_session removeDelegate: self];

    [_vItems    release];
    [_delegates release];

    [super dealloc];
}

-(NSArray*) getGameVItemsList {
    NSMutableArray* vItems   = [NSMutableArray array];
    NSData*         fileData = [[_session getGameVocabulary] getFileData: MNVItemsProviderVocabularyFileName];

    if (fileData != nil) {
        NSError *error;
        CXMLDocument *document;

        document = [[CXMLDocument alloc] initWithData: fileData options: 0 error: &error];

        CXMLElement* listElement = MNWSXmlDocumentGetElementByPath(document,[NSArray arrayWithObjects: @"GameVocabulary", @"MNVItemsProvider", @"VItems", nil]);

        if (listElement != nil) {
            NSArray* items = MNWSXmlNodeParseItemList(listElement,@"entry");

            for (NSDictionary* itemData in items) {
                NSInteger itemId;

                if (MNStringScanInteger(&itemId,[itemData valueForKey: @"id"])) {
                    NSString* name   = [itemData valueForKey: @"name"];
                    NSInteger model  = MNStringScanIntegerWithDefValue([itemData valueForKey: @"model"],0);
                    NSString* desc   = [itemData valueForKey: @"desc"];
                    NSString* params = [itemData valueForKey: @"params"];

                    MNGameVItemInfo* vItem = [[[MNGameVItemInfo alloc] initWithId: itemId name: name andModel: model] autorelease];

                    vItem.description = desc != nil ? desc : @"";
                    vItem.params      = params != nil ? params : @"";

                    [vItems addObject: vItem];
                }
                else {
                    NSLog(@"warning: vitem data with invalid or absent vitem id ignored");
                }
            }
        }
        else {
            NSLog(@"warning: cannot find \"VItems\" element in game vocabulary");
        }

        [document release];
    }

    return vItems;
}

-(MNGameVItemInfo*) findGameVItemById:(int) vItemId {
    MNGameVItemInfo* vitem;

    NSArray*   vitems = [self getGameVItemsList];
    BOOL       found  = NO;
    NSUInteger index  = 0;
    NSUInteger count  = [vitems count];

    while (!found && index < count) {
        vitem = [vitems objectAtIndex: index];

        if (vitem.vItemId == vItemId) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? vitem : nil;
}

-(BOOL) isGameVItemsListNeedUpdate {
    return [[_session getGameVocabulary] getVocabularyStatus] > 0;
}

-(void) doGameVItemsListUpdate {
    MNGameVocabulary* gameVocabulary = [_session getGameVocabulary];

    if ([gameVocabulary getVocabularyStatus] != MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS) {
        [gameVocabulary startDownload];
    }
}

-(void) reqAddPlayerVItem:(int) vItemId count:(MNVItemCount) count andClientTransactionId:(MNVItemTransactionId) transactionId {
    if ([_session isUserLoggedIn] && [_session isOnline]) {
        [_session sendPlugin: MNVItemsProviderPluginName
                     message: [NSString stringWithFormat: @"A%llu\n%d\t%lld",transactionId,vItemId,count]];
    }
}

-(void) reqAddPlayerVItemTransaction:(NSArray*) transactionVItems andClientTransactionId:(MNVItemTransactionId) transactionId {
    if ([_session isUserLoggedIn] && [_session isOnline]) {
        NSUInteger count = [transactionVItems count];

        if (count > 0) {
            NSMutableString* message = [NSMutableString stringWithFormat: @"A%llu",transactionId];

            for (NSUInteger index = 0; index < count; index++) {
                MNTransactionVItemInfo* vItem = [transactionVItems objectAtIndex: index];

                [message appendFormat: @"\n%d\t%lld",vItem.vItemId,vItem.delta];
            }

            [_session sendPlugin: MNVItemsProviderPluginName message: message];
        }
    }
}

-(void) reqTransferPlayerVItem:(int) vItemId count:(MNVItemCount) count toPlayer:(MNUserId) playerId andClientTransactionId:(MNVItemTransactionId) transactionId {
    if ([_session isUserLoggedIn] && [_session isOnline]) {
        [_session sendPlugin: MNVItemsProviderPluginName
                     message: [NSString stringWithFormat: @"T%llu\t%llu\n%d\t%lld",transactionId,playerId,vItemId,count]];
    }
}

-(void) reqTransferPlayerVItemTransaction:(NSArray*) transactionVItems toPlayer:(MNUserId) playerId andClientTransactionId:(MNVItemTransactionId) transactionId {
    if ([_session isUserLoggedIn] && [_session isOnline]) {
        NSUInteger count = [transactionVItems count];

        if (count > 0) {
            NSMutableString* message = [NSMutableString stringWithFormat: @"T%llu\t%llu",transactionId,playerId];

            for (NSUInteger index = 0; index < count; index++) {
                MNTransactionVItemInfo* vItem = [transactionVItems objectAtIndex: index];

                [message appendFormat: @"\n%d\t%lld",vItem.vItemId,vItem.delta];
            }

            [_session sendPlugin: MNVItemsProviderPluginName message: message];
        }
    }
}

-(NSArray*) getPlayerVItemList {
    return _vItems;
}

-(MNVItemCount) getPlayerVItemCountById:(int) vItemId {
    MNPlayerVItemInfo* vItemInfo = getPlayerVItemInfoById(_vItems,vItemId);

    if (vItemInfo != nil) {
        return vItemInfo.count;
    }
    else {
        return 0;
    }
}

-(NSURL*) getVItemImageURL:(int) vItemId {
    NSString* webServerUrl = [_session getWebServerURL];

    if (webServerUrl != nil) {
        return [NSURL URLWithString:
                [NSString stringWithFormat: MNVItemsProviderImageUrlFormat,webServerUrl,[_session getGameId],vItemId]];
    }
    else {
        return nil;
    }
}

-(void) addDelegate:(id<MNVItemsProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNVItemsProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

/* private methods */
-(MNPlayerVItemInfo*) playerVItemInfoRefById:(int) vItemId {
    MNPlayerVItemInfo* vItem = getPlayerVItemInfoById(_vItems,vItemId);

    if (vItem == nil) {
        vItem = [[[MNPlayerVItemInfo alloc] initWithId: vItemId andCount: 0] autorelease];

        [_vItems addObject: vItem];
    }

    return vItem;
}

-(MNVItemsTransactionInfo*) applyTransactionWithServerTransactionId:(MNVItemTransactionId) srvTransactionId
                                                clientTransactionId:(MNVItemTransactionId) cliTransactionId
                                                         corrUserId:(MNUserId) corrUserId
                                                           andItems:(NSMutableArray*) vItemChanges {
    for (MNTransactionVItemInfo* vItemInfo in vItemChanges) {
        MNPlayerVItemInfo* currInfo = [self playerVItemInfoRefById: vItemInfo.vItemId];

        currInfo.count += vItemInfo.delta;
    }

    MNVItemsMutableTransactionInfo* transactionInfo =
     [[[MNVItemsMutableTransactionInfo alloc] initWithClientTransactionId: cliTransactionId
                                                      serverTransactionId: srvTransactionId
                                                               corrUserId: corrUserId
                                                                andVItems: nil] autorelease];

    [transactionInfo setVItems: vItemChanges];

    [_delegates beginCall];

    for (id<MNVItemsProviderDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(onVItemsTransactionCompleted:)]) {
            [delegate onVItemsTransactionCompleted: transactionInfo];
        }
    }

    [_delegates endCall];

    return transactionInfo;
}

-(MNVItemsTransactionInfo*) applyTransactionFromDictionary:(NSDictionary*) params vItemsItemSeparator:(NSString*) vItemsItemSeparator vItemsFieldSeparator:(NSString*) vItemsFieldSeparator {
    MNVItemTransactionId cliTransactionId = MNStringScanLongLongWithDefValue([params objectForKey: @"client_transaction_id"],0);
    MNVItemTransactionId srvTransactionId = MNStringScanLongLongWithDefValue([params objectForKey: @"server_transaction_id"],0);
    MNUserId             corrUserId       = MNStringScanLongLongWithDefValue([params objectForKey: @"corr_user_id"],0);
    NSString*            itemsToAdd       = [params objectForKey: @"items_to_add"];

    if (cliTransactionId < 0 || srvTransactionId < 0) {
        return nil;
    }

    NSMutableArray* vItemChanges = parsePlayerVItemsListMessage(itemsToAdd,YES,vItemsItemSeparator,vItemsFieldSeparator);

    if (vItemChanges != nil) {
        return [self applyTransactionWithServerTransactionId: srvTransactionId
                                         clientTransactionId: cliTransactionId
                                                  corrUserId: corrUserId
                                                    andItems: vItemChanges];
    }
    else {
        return nil;
    }
}

-(void) processAddVItemsMessage:(NSString*) message {
    MNVItemTransactionId serverTransactionId;
    MNVItemTransactionId clientTransactionId;
    MNUserId             corrUserId;
    NSUInteger           headerLength;

    if (!parseTransactionResultHeader(message,&serverTransactionId,&clientTransactionId,&corrUserId,&headerLength)) {
        return; // invalid message header
    }

    NSMutableArray* vItemChanges = parsePlayerVItemsListMessage([message substringFromIndex: headerLength],YES,MNVItemsProviderMessageLineSeparator,MNVItemsProviderMessageFieldSeparator);

    if (vItemChanges == nil) {
        return; // invalid message - on of the vitem lines is invalid
    }

    [self applyTransactionWithServerTransactionId:serverTransactionId
                              clientTransactionId:clientTransactionId
                                       corrUserId:corrUserId
                                         andItems:vItemChanges];
}

-(void) processFailMessage:(NSString*) message {
    MNVItemTransactionId serverTransactionId;
    MNVItemTransactionId clientTransactionId;
    MNUserId             corrUserId;
    NSUInteger           headerLength;

    if (!parseTransactionResultHeader(message,&serverTransactionId,&clientTransactionId,&corrUserId,&headerLength)) {
        return; // invalid message header
    }

    NSString* errorInfoStr   = [message substringFromIndex: headerLength];
    NSRange   separatorRange = [errorInfoStr rangeOfString: MNVItemsProviderMessageFieldSeparator];

    if (separatorRange.location == NSNotFound) {
        return; // invalid error info line format
    }

    NSInteger failReasonCode;

    if (!MNStringScanInteger(&failReasonCode,[errorInfoStr substringToIndex: separatorRange.location])) {
        return; // invalid fail reason code
    }

    MNVItemsTransactionError* transactionError = [[MNVItemsTransactionError alloc] initWithClientTransactionId: clientTransactionId
                                                                                           serverTransactionId: serverTransactionId
                                                                                                    corrUserId: corrUserId
                                                                                                failReasonCode: failReasonCode
                                                                                               andErrorMessage: [errorInfoStr substringFromIndex: separatorRange.location + separatorRange.length]];

    [_delegates beginCall];

    for (id<MNVItemsProviderDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector: @selector(onVItemsTransactionFailed:)]) {
            [delegate onVItemsTransactionFailed: transactionError];
        }
    }

    [_delegates endCall];

    [transactionError release];
}

/* MNGameVocabularyDelegate protocol */
-(void) mnGameVocabularyDownloadFinished:(int) downloadStatus {
    if (downloadStatus > 0) {
        [_delegates beginCall];

        for (id<MNVItemsProviderDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(onVItemsListUpdated)]) {
                [delegate onVItemsListUpdated];
            }
        }

        [_delegates endCall];
    }
}

/* MNSessionDelegate protocol */
-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (sender != nil || ![pluginName isEqualToString: MNVItemsProviderPluginName]) {
        return;
    }

    NSUInteger messageLen = [message length];

    if (messageLen == 0) {
        return;
    }

    unichar cmdChar = [message characterAtIndex: 0];

    switch (cmdChar) {
        case 'g': {
            // ignore this message, it was used in pre-1.4.0 to get latest available data version
        } break;

        case 'p': {
            _vItemsOwnerUserId = [_session getMyUserId];

            [_vItems release];
            _vItems = [parsePlayerVItemsListMessage([message substringFromIndex: PLUGIN_MESSAGE_CMD_PREFIX_LEN],NO,MNVItemsProviderMessageLineSeparator,MNVItemsProviderMessageFieldSeparator) retain];
        } break;

        case 'a': {
            [self processAddVItemsMessage: [message substringFromIndex: PLUGIN_MESSAGE_CMD_PREFIX_LEN]];
        } break;

        case 'f': {
            [self processFailMessage: [message substringFromIndex: PLUGIN_MESSAGE_CMD_PREFIX_LEN]];
        } break;

        default: {
        }
    }
}

-(void) mnSessionWebEventReceived:(NSString*) eventName withParam:(NSString*) eventParam andCallbackId:(NSString*) callbackId {
    if (![eventName isEqualToString: @"web.onUserDoAddItems"]) {
        return;
    }

    if (eventParam == nil) {
        return;
    }

    NSDictionary* params = MNCopyDictionaryWithGetRequestParamString(eventParam);

    [self applyTransactionFromDictionary: params vItemsItemSeparator: MNVItemsProviderMessageLineSeparator vItemsFieldSeparator: MNVItemsProviderMessageFieldSeparator];

    [params release];
}

-(void) mnSessionUserChangedTo:(MNUserId) userId {
    if (userId == MNUserIdUndefined || userId != _vItemsOwnerUserId) {
        _vItemsOwnerUserId = userId;
        [_vItems removeAllObjects];
    }
}

-(MNVItemTransactionId) getNewClientTransactionId {
    _cliTransactionId++;

    return _cliTransactionId;
}

@end
