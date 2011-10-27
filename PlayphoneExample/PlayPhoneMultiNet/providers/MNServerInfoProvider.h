//
//  MNServerInfoProvider.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNSession.h"

#define MNServerInfoServerTimeInfoKey (1)

/**
 * @brief "Server information" delegate protocol.
 *
 * By implementing methods of MNServerInfoProviderDelegate protocol, the delegate can handle
 * server information retrieval notifications.
 */
@protocol MNServerInfoProviderDelegate<NSObject>
@optional

/**
 * This message is sent when server information has been successfully retrieved.
 * @param key describes a kind of the retrieved server data
 * @param value server data
 */
-(void) serverInfoWithKey:(NSInteger) key received:(NSString*) value;

/**
 * This message is sent when server information retrieval failed.
 * @param key describes a kind of the server data
 * @param error error message
 */
-(void) serverInfoWithKey:(NSInteger) key requestFailedWithError:(NSString*) error;
@end

/**
 * @brief "Server information" MultiNet provider.
 *
 * "Server information" provider allows to retrieve server information.
 */
@interface MNServerInfoProvider : NSObject<MNSessionDelegate> {
@private

	MNSession*       _session;
	MNDelegateArray* _delegates;
}

/**
 * Initializes and return newly allocated MNServerInformationProvider object.
 * @param session MultiNet session instance
 * @return initialized object or nil if the object couldn't be created.
 */
-(id) initWithSession:(MNSession*) session;

/**
 * Starts server information retrieval operation.
 * @param key describes a kind of the server information
 */
-(void) requestServerInfoItem:(NSInteger) key;

/**
 * Adds delegate
 * @param delegate an object conforming to MNServerInfoProviderDelegate protocol
 */
-(void) addDelegate:(id<MNServerInfoProviderDelegate>) delegate;

/**
 * Removes delegate
 * @param delegate an object to remove from current list of delegates
 */
-(void) removeDelegate:(id<MNServerInfoProviderDelegate>) delegate;
@end
