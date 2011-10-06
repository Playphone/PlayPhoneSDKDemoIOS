//
//  MNVShopProvider.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/17/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"
#import "MNGameVocabulary.h"
#import "MNVShopWSRequest.h"
#import "MNVItemsProvider.h"

#define MN_VSHOP_PROVIDER_ERROR_CODE_NO_ERROR            (0)
#define MN_VSHOP_PROVIDER_ERROR_CODE_CANCEL              (-999)
#define MN_VSHOP_PROVIDER_ERROR_CODE_UNDEFINED           (-998)
#define MN_VSHOP_PROVIDER_ERROR_CODE_XML_PARSE_ERROR     (-997)
#define MN_VSHOP_PROVIDER_ERROR_CODE_XML_STRUCTURE_ERROR (-996)
#define MN_VSHOP_PROVIDER_ERROR_CODE_NETWORK_ERROR       (-995)

@class MNVShopProviderCheckoutVShopPackSuccessInfo;
@class MNVShopProviderCheckoutVShopPackFailInfo;

/**
 * @brief "virtual shop" provider delegate protocol.
 *
 * By implementing methods of MNVShopProviderDelegate protocol, the delegate can respond to
 * events related to virtual shop.
 */
@protocol MNVShopProviderDelegate<NSObject>

@optional

/**
 * This message is sent when the virtual shop information has been updated as a result of MNVShopProvider's
 * doVShopInfoUpdate call.
 */
-(void) onVShopInfoUpdated;

/**
 * This message is sent when the virtual shop asks to show dashboard
 */
-(void) showDashboard;

/**
 * This message is sent when the virtual shop asks to hide dashboard
 */
-(void) hideDashboard;

/**
 * This message is sent when purchase operation was completed successfully
 */
-(void) onCheckoutVShopPackSuccess:(MNVShopProviderCheckoutVShopPackSuccessInfo*) result;

/**
 * This message is sent when purchase operation failed
 */
-(void) onCheckoutVShopPackFail:(MNVShopProviderCheckoutVShopPackFailInfo*) result;

@end


/**
 * @brief Completed purchase information object
 */
@interface MNVShopProviderCheckoutVShopPackSuccessInfo : NSObject {
@private
    MNVItemsTransactionInfo* _transaction;
}

@property (nonatomic,retain) MNVItemsTransactionInfo* transaction;

-(id) initWithTransactionInfo:(MNVItemsTransactionInfo*) transaction;

@end

/**
 * @brief Failed purchase information object
 */
@interface MNVShopProviderCheckoutVShopPackFailInfo : NSObject {
@private
    int                  _errorCode;
    NSString*            _errorMessage;
    MNVItemTransactionId _clientTransactionid;
}

@property (nonatomic,assign) int                  errorCode;
@property (nonatomic,retain) NSString*            errorMessage;
@property (nonatomic,assign) MNVItemTransactionId clientTransactionId;

-(id) initWithErrorCode:(int) errorCode errorMessage:(NSString*) errorMessage andClientTransactionId:(MNVItemTransactionId) clientTransactionId;

@end


/**
 * @brief Virtual shop delivery information object
 */
@interface MNVShopDeliveryInfo : NSObject {
@private

    int       _vItemId;
    long long _amount;
}

/**
 * Identifier of virtual item which will be delivered.
 */
@property (nonatomic,assign) int        vItemId;

/**
 * Amount of virtual items which will be delivered.
 */
@property (nonatomic,assign) long long  amount;

-(id) initWithVItemId:(int) vItemId andAmount:(long long) amount;
@end


/**
 * @brief Virtual shop package information object
 */
@interface MNVShopPackInfo : NSObject {
@private

    int          _packId;
    NSString*    _name;
    unsigned int _model;
    NSString*    _description;
    NSString*    _appParams;
    int          _sortPos;
    int          _categoryId;
    NSArray*     _delivery;
    int          _priceItemId;
    long long    _priceValue;
}

/**
 * Package identifier - unique identifier of shop package.
 */
@property (nonatomic,assign) int        packId;

/**
 * Package name.
 */
@property (nonatomic,retain) NSString*  name;

/**
 * Package model.
 */
@property (nonatomic,assign) unsigned int model;

/**
 * Package description.
 */
@property (nonatomic,retain) NSString*  description;

/**
 * Application-defined package parameters.
 */
@property (nonatomic,retain) NSString*  appParams;

/**
 * Position of this package in package list.
 */
@property (nonatomic,assign) int        sortPos;

/**
 * Category identifier.
 */
@property (nonatomic,assign) int        categoryId;

/**
 * Array of deliveries in this pack.
 */
@property (nonatomic,retain) NSArray*   delivery;

/**
 * Virtual currency item identifier, 0 if price is in real currency.
 */
@property (nonatomic,assign) int        priceItemId;

/**
 * Price.
 */
@property (nonatomic,assign) long long  priceValue;

/**
 * Initializes and return newly allocated object with shop package data.
 * @param packId package identifier
 * @param name package name
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) packId andName:(NSString*) name;

@end


/**
 * @brief Virtual shop category information object
 */
@interface MNVShopCategoryInfo : NSObject {
@private

    int          _categoryId;
    NSString*    _name;
    int          _sortPos;
}

/**
 * Category identifier - unique identifier of shop category.
 */
@property (nonatomic,assign) int        categoryId;

/**
 * Category name.
 */
@property (nonatomic,retain) NSString*  name;

/**
 * Position of this category in category list.
 */
@property (nonatomic,assign) int        sortPos;

/**
 * Initializes and return newly allocated object with shop category data.
 * @param categoryId category identifier
 * @param name category name
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithId:(int) categoryId andName:(NSString*) name;

@end


@class MNVShopInAppPurchase;

/**
 * @brief "Virtual shop" MultiNet provider.
 *
 * "Virtual shop" provider provides virtual shop support.
 */
@interface MNVShopProvider : NSObject<MNSessionDelegate,MNGameVocabularyDelegate,MNVShopPurchaseWSRequestHelperDelegate> {
@private

    MNSession*                       _session;
    MNDelegateArray*                 _delegates;
    MNVShopInAppPurchase*            _inAppPurchase;
    MNVShopPurchaseWSRequestHelper*  _requestHelper;
    MNVItemsProvider*                _vItemsProvider;
}

/**
 * Initializes and return newly allocated MNVShopProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession: (MNSession*) session andVItemsProvider:(MNVItemsProvider*) vItemsProvider;

/**
 * Returns list of all available shop packages.
 * @return array of shop packages. Elements of array are MNVShopPackInfo objects.
 */
-(NSArray*) getVShopPackList;

/**
 * Returns virtual shop package information by package id.
 * @return virtual shop package information or nil if there is no such package.
 */
-(MNVShopPackInfo*) findVShopPackById:(int) vShopPackId;

/**
 * Returns list of all available categories.
 * @return array of shop categories. Elements of array are MNVShopCategoryInfo objects.
 */
-(NSArray*) getVShopCategoryList;

/**
 * Returns virtual shop category information by category id.
 * @return virtual shop category information or nil if there is no such category.
 */
-(MNVShopCategoryInfo*) findVShopCategoryById:(int) vShopCategoryId;

/**
 * Returns state of virtual shop data.
 * @return YES if newer virtual shop data is available on server, NO - otherwise.
 */
-(BOOL) isVShopInfoNeedUpdate;

/**
 * Starts virtual shop info update. On successfull completion delegate's onVShopInfoUpdated method
 * will be called.
 */
-(void) doVShopInfoUpdate;

/**
 * Returns URL of virtual shop package
 * @return image URL
 */
-(NSURL*) getVShopPackImageURL:(int) packId;

/**
 * Starts checkout operation
 * @param packIdArray array of pack identifiers
 * @param packCount array of pack count
 * @param clientTransaction client transaction
 */
-(void) execCheckoutVShopPacks:(NSArray*) packIdArray packCount:(NSArray*) packCount clientTransactionId:(MNVItemTransactionId) clientTransactionId;

/**
 * Starts checkout operation in UI-less mode
 * @param packIdArray array of pack identifiers
 * @param packCount array of pack count
 * @param clientTransaction client transaction
 */
-(void) procCheckoutVShopPacksSilent:(NSArray*) packIdArray packCount:(NSArray*) packCount clientTransactionId:(MNVItemTransactionId) clientTransactionId;

/**
 * Adds delegate
 * @param delegate an object conforming to MNVShopProviderDelegate protocol
 */
-(void) addDelegate:(id<MNVShopProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNVShopProviderDelegate>) delegate;

@end
