//
//  MNGameCookiesProvider.h
//  MultiNet client
//
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"

/**
 * @brief "Game cookies" delegate protocol.
 *
 * By implementing methods of MNGameCookiesProvider protocol, the delegate can handle
 * game cookies "stored/retrieved" notifications.
 */
@protocol MNGameCookiesProviderDelegate<NSObject>
@optional

/**
 * This message is sent when game cookie has been successfully retrieved.
 * @param key game cookie's key
 * @param cookie game cookie's data
 */
-(void) gameCookie:(NSInteger) key downloadSucceeded:(NSString*) cookie;

/**
 * This message is sent when game cookie retrieval failed.
 * @param key game cookie's key
 * @param error error message
 */
-(void) gameCookie:(NSInteger) key downloadFailedWithError:(NSString*) error;

/**
 * This message is sent when game cookie has been successfully stored.
 * @param key game cookie's key
 */
-(void) gameCookieUploadSucceeded:(NSInteger) key;

/**
 * This message is sent when game cookie uploading failed.
 * @param key game cookie's key
 * @param error error message
 */
-(void) gameCookie:(NSInteger) key uploadFailedWithError:(NSString*) error;
@end

/**
 * @brief "Game cookies" MultiNet provider.
 *
 * "ScoreProgress" provider provides ability to store small pieces of information
 * per player on server and retrieve it later.
 */
@interface MNGameCookiesProvider : NSObject<MNSessionDelegate> {
	@private

	MNSession*                      _session;
	MNDelegateArray*                _delegates;
}

+(id) MNGameCookiesProviderWithSession:(MNSession*) session;

/**
 * Initializes and return newly allocated MNGameCookiesProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession:(MNSession*) session;

/**
 * Starts cookie retrieval operation.
 * @param key key of cookie to retrieve
 */
-(void) downloadUserCookie:(NSInteger) key;

/**
 * Starts cookie upload operation.
 * @param key game cookie's key
 * @param cookie game cookie's data
 */
-(void) uploadUserCookieWithKey:(NSInteger) key andCookie:(NSString*) cookie;

/**
 * Adds delegate
 * @param delegate an object conforming to MNGameCookiesProviderDelegate protocol
 */
-(void) addDelegate:(id<MNGameCookiesProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNGameCookiesProviderDelegate>) delegate;
@end
