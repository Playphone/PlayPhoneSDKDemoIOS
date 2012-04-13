//
//  MNTrackingSystem.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MNSession;
@class MNInstallTracker;
@class MNTrackingUrlTemplate;
@class MNTrackingSystemDelegateWrapper;

@interface MNAppBeaconResponse : NSObject {
@private
    NSString* _responseText;
    long      _callSeqNumber;
}

@property (nonatomic,retain) NSString* responseText;
@property (nonatomic,assign) long      callSeqNumber;

-(id) initWithResponseText:(NSString*) responseText andCallSeqNumber:(long) callSeqNumber;

@end


@protocol MNTrackingSystemDelegate<NSObject>
-(void) appBeaconDidReceiveResponse:(MNAppBeaconResponse*) response;
@end


@interface MNTrackingSystem : NSObject {
@private
    MNTrackingUrlTemplate* _beaconUrlTemplate;
    MNTrackingUrlTemplate* _shutdownUrlTemplate;
    NSMutableDictionary*   _trackingVariables;
    BOOL                   _launchTracked;
    MNInstallTracker*      _installTracker;
    MNTrackingUrlTemplate* _enterForegroundUrlTemplate;
    MNTrackingUrlTemplate* _enterBackgroundUrlTemplate;

    MNTrackingSystemDelegateWrapper* _delegateWrapper;
}

-(id) initWithSession:(MNSession*) session andTrackingSystemDelegate:(id<MNTrackingSystemDelegate>) delegate;

-(void) trackLaunchWithUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session;
-(void) trackInstallWithUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session;

-(void) setShutdownUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session;
-(void) trackShutdownForSession:(MNSession*) session;

-(void) setBeaconUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session;
-(void) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData andSession:(MNSession*) session;
-(void) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData callSeqNumber:(long) callSeqNumber andSession:(MNSession*) session;

-(void) setEnterForegroundUrlTemplate:(NSString*) urlTemplate;
-(void) setEnterBackgroundUrlTemplate:(NSString*) urlTemplate;

-(void) trackEnterForegroundForSession:(MNSession*) session;
-(void) trackEnterBackgroundForSession:(MNSession*) session;

-(NSDictionary*) getTrackingVars;

@end
