//
//  MNUIWebViewHttpReqQueue.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/20/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNURLDownloader.h"

@protocol MNUIWebViewHttpReqQueueDelegate<NSObject>
-(void) mnUiWebViewHttpReqDidSucceedWithCodeToEval:(NSString*) jsCode andFlags:(unsigned int) flags;
-(void) mnUiWebViewHttpReqDidFailWithCodeToEval:(NSString*) jsCode andFlags:(unsigned int) flags;
@end

@interface MNUIWebViewHttpReqQueue : NSObject<MNURLDownloaderDelegate> {
    @private

    id<MNUIWebViewHttpReqQueueDelegate> _delegate;
    NSMutableArray*                     _requests;
}

-(id) initWithDelegate:(id<MNUIWebViewHttpReqQueueDelegate>) delegate;
-(void) addRequestWithUrl:(NSString*) url
               postParams:(NSString*) postBody
            successJSCode:(NSString*) successJSCode
               failJSCode:(NSString*) failJSCode
                 andFlags:(unsigned int) flags;

@end
