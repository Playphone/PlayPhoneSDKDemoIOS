//
//  MNURLDownloader.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/5/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MNURLDownloaderErrorStatusSystemError (-1)

@interface MNURLDownloaderError : NSObject
{
@private

NSInteger _httpStatus;
NSString* _message;
}

@property (nonatomic,assign) NSInteger httpStatus;
@property (nonatomic,retain) NSString* message;

+(id) errorWithHttpStatus:(NSInteger) status andMessage:(NSString*) message;
-(id) initWithHttpStatus:(NSInteger) status andMessage:(NSString*) message;

@end


@protocol MNURLDownloaderDelegate;

@interface MNURLDownloader : NSObject {
@private

NSURLConnection*            _connection;
id<MNURLDownloaderDelegate> _delegate;
NSMutableData*              _data;
}

-(id) init;
-(void) loadUrl:(NSURL*) url delegate:(id<MNURLDownloaderDelegate>) delegate;
-(void) loadRequest:(NSURLRequest*) request delegate:(id<MNURLDownloaderDelegate>) delegate;
-(void) cancel;

-(BOOL) isLoading;

@end


@protocol MNURLDownloaderDelegate<NSObject>

-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data;
-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error;

@end
