//
//  MNUIWebViewHttpReqQueue.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/20/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNTools.h"
#import "MNURLDownloader.h"
#import "MNUIWebViewHttpReqQueue.h"

static NSString* MNUIWebViewHttpReqJSCodeSubstVarResponseText = @"RESPONSE_TEXT";
static NSString* MNUIWebViewHttpReqJSCodeSubstVarResponseErrorText = @"RESPONSE_ERROR_TEXT";
static NSString* MNUIWebViewHttpReqJSCodeSubstVarResponseErrorCode = @"RESPONSE_ERROR_CODE";

@interface  MNUIWebViewHttpReqData : NSObject
{
    @private

    MNURLDownloader* _downloader;
    NSString*        _successJSCode;
    NSString*        _failJSCode;
    unsigned int     _flags;
}

@property (nonatomic,assign) MNURLDownloader* downloader;
@property (nonatomic,retain) NSString*        successJSCode;
@property (nonatomic,retain) NSString*        failJSCode;
@property (nonatomic,assign) unsigned int     flags;

-(id) initWithDownloader:(MNURLDownloader*) downloader
           successJSCode:(NSString*) successJSCode
              failJSCode:(NSString*) failJSCode
                andFlags:(unsigned int) flags;
-(void) dealloc;

@end

@implementation MNUIWebViewHttpReqData

@synthesize downloader    = _downloader;
@synthesize successJSCode = _successJSCode;
@synthesize failJSCode    = _failJSCode;
@synthesize flags         = _flags;

-(id) initWithDownloader:(MNURLDownloader*) downloader
           successJSCode:(NSString*) successJSCode
              failJSCode:(NSString*) failJSCode
                andFlags:(unsigned int) flags {
    self = [super init];

    if (self != nil) {
        _downloader    = downloader;
        _successJSCode = [[NSString alloc] initWithString: successJSCode];
        _failJSCode    = [[NSString alloc] initWithString: failJSCode];
        _flags         = flags;
    }

    return self;
}

-(void) dealloc {
    [_downloader cancel];
    [_downloader release];
    [_successJSCode release];
    [_failJSCode release];

    [super dealloc];
}

@end


@implementation MNUIWebViewHttpReqQueue

-(id) initWithDelegate:(id<MNUIWebViewHttpReqQueueDelegate>) delegate {
    self = [super init];

    if (self != nil) {
        _delegate = delegate;
        _requests = [[NSMutableArray alloc] init];
    }

    return self;
}

-(void) dealloc {
    [_requests release];

    [super dealloc];
}

-(void) addRequestWithUrl:(NSString*) url
               postParams:(NSString*) postBody
            successJSCode:(NSString*) successJSCode
               failJSCode:(NSString*) failJSCode
                 andFlags:(unsigned int) flags {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];

    if (postBody != nil) {
        [request setHTTPMethod: @"POST"];
        [request setValue: @"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
        [request setHTTPBody: [postBody dataUsingEncoding: NSUTF8StringEncoding]];
    }

    MNURLDownloader* downloader = [[MNURLDownloader alloc] init];

    [downloader loadRequest: request delegate: self];

    MNUIWebViewHttpReqData* req = [[MNUIWebViewHttpReqData alloc] initWithDownloader: downloader
                                                                       successJSCode: successJSCode
                                                                          failJSCode: failJSCode
                                                                            andFlags: flags];

    [_requests addObject: req];

    [req release];
    [request release];
}

-(BOOL) findReqDataByDownloader:(MNURLDownloader*) downloader index:(NSUInteger*) reqDataIndex {
    NSUInteger index;
    NSUInteger count = [_requests count];

    for (index = 0; index < count; index++) {
        MNUIWebViewHttpReqData* reqData = [_requests objectAtIndex: index];

        if (reqData.downloader == downloader) {
            *reqDataIndex = index;

            return YES;
        }
        else {
            index++;
        }
    }

    return NO;
}

/* MNURLDownloaderDelegate protocol */
-(void) downloader:(MNURLDownloader*) downloader dataReady:(NSData*) data {
    NSUInteger index;

    if (![self findReqDataByDownloader: downloader index: &index]) {
        return;
    }

    MNUIWebViewHttpReqData* reqData = [_requests objectAtIndex: index];

    NSString* escapedString = MNStringAsJSString([[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease]);

    NSString* code = [reqData.successJSCode stringByReplacingOccurrencesOfString: MNUIWebViewHttpReqJSCodeSubstVarResponseText withString: escapedString];

    [_delegate mnUiWebViewHttpReqDidSucceedWithCodeToEval: code andFlags: reqData.flags];

    [_requests removeObjectAtIndex: index];
}

-(void) downloader:(MNURLDownloader*) downloader didFailWithError:(MNURLDownloaderError*) error {
    NSUInteger index;

    if (![self findReqDataByDownloader: downloader index: &index]) {
        return;
    }

    MNUIWebViewHttpReqData* reqData = [_requests objectAtIndex: index];

    NSString* escapedTextString = MNStringAsJSString(error.message);
    NSString* escapedCodeString = MNStringAsJSString([NSString stringWithFormat: @"%d", error.httpStatus]);

    NSString* code = [reqData.failJSCode stringByReplacingOccurrencesOfString: MNUIWebViewHttpReqJSCodeSubstVarResponseErrorCode withString: escapedCodeString];

    code = [code stringByReplacingOccurrencesOfString: MNUIWebViewHttpReqJSCodeSubstVarResponseErrorText withString: escapedTextString];

    [_delegate mnUiWebViewHttpReqDidFailWithCodeToEval: code andFlags: reqData.flags];

    [_requests removeObjectAtIndex: index];
}

@end
