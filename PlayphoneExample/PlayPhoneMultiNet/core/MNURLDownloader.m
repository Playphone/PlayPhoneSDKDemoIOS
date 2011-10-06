//
//  MNURLDownloader.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 1/5/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNURLDownloader.h"

#define MNURLDownloaderTimeout (30)

#define MNURLDownloaderHTTPErrorMinStatus (400) // 4xx (client errors) and 5xx (server errors)

static BOOL httpStatusMeansError (int status) {
    return status >= MNURLDownloaderHTTPErrorMinStatus;
}

@implementation MNURLDownloaderError

@synthesize httpStatus = _httpStatus;
@synthesize message    = _message;

+(id) errorWithHttpStatus:(NSInteger) status andMessage:(NSString*) message {
    return [[[MNURLDownloaderError alloc] initWithHttpStatus: status andMessage: message] autorelease];
}

-(id) initWithHttpStatus:(NSInteger) status andMessage:(NSString*) message {
    self = [super init];

    if (self != nil) {
        _httpStatus  = status;
        _message = [[NSString alloc] initWithString: message];
    }

    return self;
}

-(void) dealloc {
    [_message release];

    [super dealloc];
}

@end


@interface  MNURLDownloader()

-(void) releaseResources;
-(void) dealloc;

/* NSURLConnection delegate protocol */

-(void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response;
-(void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data;
-(void) connectionDidFinishLoading:(NSURLConnection*) connection;
-(void) connection:(NSURLConnection*) connection didFailWithError:(NSError*) error;
-(NSCachedURLResponse*) connection:(NSURLConnection*) connection willCacheResponse:(NSCachedURLResponse*) cachedResponse;

@end

@implementation MNURLDownloader

-(id) init {
    self = [super init];

    if (self != nil) {
        _connection = nil;
        _delegate   = nil;
        _data       = nil;
    }

    return self;
}

-(void) releaseResources {
    [_connection cancel];
    [_connection release];
    _connection = nil;

    [_data release];
    _data = nil;

    _delegate = nil;
}

-(void) dealloc {
    [self releaseResources];

    [super dealloc];
}

-(void) loadUrl:(NSURL*) url delegate:(id<MNURLDownloaderDelegate>) delegate {
    [self loadRequest: [NSURLRequest requestWithURL: url
                                     cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                     timeoutInterval: MNURLDownloaderTimeout]
          delegate: delegate];
}

-(void) loadRequest:(NSURLRequest*) request delegate:(id<MNURLDownloaderDelegate>) delegate {
    if (_connection != nil) {
        // download in progress

        [delegate downloader: self
            didFailWithError: [MNURLDownloaderError errorWithHttpStatus: MNURLDownloaderErrorStatusSystemError
                                                             andMessage: @"Download in progress"]];

        return;
    }

    _delegate   = delegate;
    _data       = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
}

-(void) cancel {
    [self releaseResources];
}

-(BOOL) isLoading {
    return _connection != nil;
}

-(void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response {
    int ok = YES;
    NSInteger status = MNURLDownloaderErrorStatusSystemError;
    NSString* errorMessage = nil;

    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

        status = [httpResponse statusCode];

        if (httpStatusMeansError(status)) {
            ok = NO;
            errorMessage = [NSString stringWithFormat: @"Download failed with http status %d", status];
        }
    }

    [_data setLength: 0];

    if (!ok) {
        id<MNURLDownloaderDelegate> delegate = _delegate;

        [self releaseResources];

        [delegate downloader: self didFailWithError: [MNURLDownloaderError errorWithHttpStatus: status andMessage: errorMessage]];
    }
}

-(void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data {
    [_data appendData: data];
}

-(void) connectionDidFinishLoading:(NSURLConnection*) connection {
    id<MNURLDownloaderDelegate> delegate = _delegate;
    NSData* data = [_data retain];

    [self releaseResources];

    [delegate downloader: self dataReady: data];

    [data release];
}

-(void) connection:(NSURLConnection*) connection didFailWithError:(NSError*) error {
    id<MNURLDownloaderDelegate> delegate = _delegate;

    [self releaseResources];

    [delegate downloader: self
        didFailWithError: [MNURLDownloaderError errorWithHttpStatus: MNURLDownloaderErrorStatusSystemError
                                                         andMessage: [error localizedDescription]]];
}

-(NSCachedURLResponse*) connection:(NSURLConnection*) connection willCacheResponse:(NSCachedURLResponse*) cachedResponse {
    return nil;
}

@end
