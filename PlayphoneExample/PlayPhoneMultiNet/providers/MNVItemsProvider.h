//
//  MNVItemsProvider.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 7/10/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNGameVocabulary.h"
@class MNVItemsTransactionInfo;
@class MNVItemsTransactionError;

typedef long long MNVItemCount;
typedef long long MNVItemTransactionId;

/**
 * @brief "vItems" provider delegate protocol.
 *
 * By implementing methods of MNVItemsProviderDelegate protocol, the delegate can respond to
 * events related to virtual items.
 */
@protocol MNVItemsProviderDelegate<NSObject>

@optional

/**
 * This message is sent when the list of virtual items has been updated as a result of MNVItemsProvider's
 * doVItemsListUpdate call.
 */
-(void) onVItemsListUpdated;

/**
 * This message is sent when server completed virtual item(s) transaction for player.
 */
-(void) onVItemsTransactionCompleted:(MNVItemsTransactionInfo*) transaction;

/**
 * This message is sent when virtual item(s) transaction failed.
 */
-(void) onVItemsTransactionFailed:(MNVItemsTransactionError*) transactionError;

@end

/**
 * @brief Virtual item information object
 */
@interface MNGameVItemInfo : NSObject {
@private
    
    int        _id;
    NSString*  _name;
    NSUInteger _model;
    NSString*  _description;
    NSString*  _params;
}

/**
 * Virtual item identifier - unique identifier of virtual item.
 */
@property (nonatomic,assign) int        vItemId;

/**
 * Name of virtual item.
 */
@property (nonatomic,retain) NSString*  name;

/**
 * Virtual item model.
 */
@property (nonatomic,assign) NSUInteger model;

/**
 * Description of virtual item.
 */
@property (nonatomic,retain) NSString*  description;

/**
 * Parameters of virtual item.
 */
@property (nonatomic,retain) NSString*  params;

/**
 * Initializes and return newly allocated object with virtual item data.
 * @param vItemId virtual item identifier
 * @param name virtual item name
 * @param model virtual item model
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) vItemId name:(NSString*) name andModel:(NSUInteger) model;

@end


/**
 * @brief Player virtual item information object
 */
@interface MNPlayerVItemInfo : NSObject {
@private
    
    int          _id;
    MNVItemCount _count;
}

/**
 * Virtual item identifier - unique identifier of virtual item.
 */
@property (nonatomic,assign) int vItemId;

/**
 * Number of virtual items.
 */
@property (nonatomic,assign) MNVItemCount count;

/**
 * Initializes and return newly allocated object with player virtual item data.
 * @param vItemId virtual item identifier
 * @param count virtual item count
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) vItemId andCount:(MNVItemCount) count;

@end


/**
 * @brief Transaction virtual item information object
 */
@interface MNTransactionVItemInfo : NSObject {
@private

    int          _id;
    MNVItemCount _delta;
}

/**
 * Virtual item identifier - unique identifier of virtual item.
 */
@property (nonatomic,assign) int vItemId;

/**
 * Virtual items count difference.
 */
@property (nonatomic,assign) MNVItemCount delta;

/**
 * Initializes and return newly allocated object with player virtual item data.
 * @param vItemId virtual item identifier
 * @param delta virtual items count difference
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) vItemId andDelta:(MNVItemCount) delta;

@end

/**
 * @brief Virtual items transaction response object
 */
@interface MNVItemsTransactionInfo : NSObject {
@private

    MNVItemTransactionId _clientTransactionId;
    MNVItemTransactionId _serverTransactionId;
    MNUserId             _corrUserId;

@protected

    NSArray*             _vItems;
}

/**
 * Client transaction identifier.
 */
@property (nonatomic,readonly) MNVItemTransactionId clientTransactionId;

/**
 * Server transaction identifier.
 */
@property (nonatomic,readonly) MNVItemTransactionId serverTransactionId;

/**
 * Correspondent user identifier.
 */
@property (nonatomic,readonly) MNUserId             corrUserId;

/**
 * Array of virtual items changed by this transaction. count property of virtual item objects contain count of items which should
 * be added to current count of items.
 */
@property (nonatomic,readonly) NSArray*             transactionVItems;

/**
 * Initializes and return newly allocated object with transaction info.
 * @param clientTransactionId client transaction id
 * @param serverTransactionId server transaction id
 * @param corrUserId correspondent user identifier
 * @param vItems array of MNTransactionVItemInfo objects
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              serverTransactionId:(MNVItemTransactionId) serverTransactionId
                       corrUserId:(MNUserId) corrUserId
                        andVItems:(NSArray*) vItems;

@end


/**
 * @brief Virtual items transaction error object
 */
@interface MNVItemsTransactionError : NSObject {
@private

    MNVItemTransactionId _clientTransactionId;
    MNVItemTransactionId _serverTransactionId;
    MNUserId             _corrUserId;
    NSInteger            _failReasonCode;
    NSString*            _errorMessage;
}

/**
 * Client transaction identifier.
 */
@property (nonatomic,readonly) MNVItemTransactionId clientTransactionId;

/**
 * Server transaction identifier.
 */
@property (nonatomic,readonly) MNVItemTransactionId serverTransactionId;

/**
 * Correspondent user identifier.
 */
@property (nonatomic,readonly) MNUserId             corrUserId;

/**
 * Fail reason.
 */
@property (nonatomic,readonly) NSInteger            failReasonCode;

/**
 * Error message.
 */
@property (nonatomic,readonly) NSString*            errorMessage;

/**
 * Initializes and return newly allocated object with transaction error information.
 * @param clientTransactionId client transaction id
 * @param serverTransactionId server transaction id
 * @param corrUserId correspondent user identifier
 * @param failReasonCode fail reason
 * @param errorMessage error message
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithClientTransactionId:(MNVItemTransactionId) clientTransactionId
              serverTransactionId:(MNVItemTransactionId) serverTransactionId
                       corrUserId:(MNUserId) corrUserId
                   failReasonCode:(NSInteger) failReasonCode
                  andErrorMessage:(NSString*) errorMessage;

@end


/**
 * @brief "Virtual items" MultiNet provider.
 *
 * "Virtual items" provider provides virtual items support.
 */
@interface MNVItemsProvider : NSObject<MNSessionDelegate,MNGameVocabularyDelegate> {
@private
    
    MNSession*                       _session;
    MNDelegateArray*                 _delegates;

    NSMutableArray*                  _vItems;
    MNUserId                         _vItemsOwnerUserId;
    MNVItemTransactionId             _cliTransactionId;
}

/**
 * Initializes and return newly allocated MNVItemsProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session;

/**
 * Returns list of all available virtual items.
 * @return array of virtual items. Elements of array are MNVirtualItemInfo objects.
 */
-(NSArray*) getGameVItemsList;

/**
 * Returns game virtual item information by item id.
 * @return game virtual item information or nil if there is no such virtual item.
 */
-(MNGameVItemInfo*) findGameVItemById:(int) vItemId;

/**
 * Returns state of virtual items list.
 * @return YES if newer virtual items list is available on server, NO - otherwise.
 */
-(BOOL) isGameVItemsListNeedUpdate;

/**
 * Starts virtual items info update. On successfull completion delegate's onVItemsListUpdated method
 * will be called.
 */
-(void) doGameVItemsListUpdate;

/**
 * Asks server to add virtual item(s) to player.
 * @param vItemId virtual item identifier
 * @param count virtual items count
 * @param transactionId transaction identifier - non-zero positive value, which will be sent back by server in transaction response
 */
-(void) reqAddPlayerVItem:(int) vItemId count:(MNVItemCount) count andClientTransactionId:(MNVItemTransactionId) transactionId;

/**
 * Asks server to add virtual item(s) to player.
 * @param transactionVItems array of MNTransactionVItemInfo objects
 * @param transactionId transaction identifier - non-zero positive value, which will be sent back by server in transaction response
 */
-(void) reqAddPlayerVItemTransaction:(NSArray*) transactionVItems andClientTransactionId:(MNVItemTransactionId) transactionId;

/**
 * Asks server to transfer virtual item(s) between players.
 * @param vItemId virtual item identifier
 * @param count virtual items count
 * @param playerId identifier of player items will be transfered to
 * @param transactionId transaction identifier - non-zero positive value, which will be sent back by server in transaction response
 */
-(void) reqTransferPlayerVItem:(int) vItemId count:(MNVItemCount) count toPlayer:(MNUserId) playerId andClientTransactionId:(MNVItemTransactionId) transactionId;

/**
 * Asks server to transfer virtual item(s) between players.
 * @param transactionVItems array of MNTransactionVItemInfo objects
 * @param playerId identifier of player items will be transfered to
 * @param transactionId transaction identifier - non-zero positive value, which will be sent back by server in transaction response
 */
-(void) reqTransferPlayerVItemTransaction:(NSArray*) transactionVItems toPlayer:(MNUserId) playerId andClientTransactionId:(MNVItemTransactionId) transactionId;

/**
 * Returns list of player's virtual items.
 * @return array of virtual items. Elements of array are MNPlayerVItemInfo objects.
 */
-(NSArray*) getPlayerVItemList;

/**
 * Returns count of player's virtual items.
 * @return count of player's virtual items.
 */
-(MNVItemCount) getPlayerVItemCountById:(int) vItemId;

/**
 * Returns URL of virtual item image
 * @return image URL
 */
-(NSURL*) getVItemImageURL:(int) vItemId;

/**
 * Adds delegate
 * @param delegate an object conforming to MNVItemsProviderDelegate protocol
 */
-(void) addDelegate:(id<MNVItemsProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNVItemsProviderDelegate>) delegate;

/**
 * Generates new client transaction identifier
 * @return client transaction identifier
 */
-(MNVItemTransactionId) getNewClientTransactionId;

@end
