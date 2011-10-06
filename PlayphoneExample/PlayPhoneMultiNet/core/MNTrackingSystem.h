//
//  MNTrackingSystem.h
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MNSession;
@class MNTrackingUrlTemplate;

@interface MNTrackingSystem : NSObject {
@private
    MNTrackingUrlTemplate* _beaconUrlTemplate;
    MNTrackingUrlTemplate* _shutdownUrlTemplate;
    NSMutableDictionary*   _trackingVariables;
    BOOL                   _launchTracked;
    MNTrackingUrlTemplate* _enterForegroundUrlTemplate;
    MNTrackingUrlTemplate* _enterBackgroundUrlTemplate;
}

-(id) initWithSession:(MNSession*) session;

-(void) trackLaunchWithUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session;

-(void) setShutdownUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session;
-(void) trackShutdownForSession:(MNSession*) session;

-(void) setBeaconUrlTemplate:(NSString*) urlTemplate forSession:(MNSession*) session;
-(void) sendBeacon:(NSString*) beaconAction data:(NSString*) beaconData andSession:(MNSession*) session;

-(void) setEnterForegroundUrlTemplate:(NSString*) urlTemplate;
-(void) setEnterBackgroundUrlTemplate:(NSString*) urlTemplate;

-(void) trackEnterForegroundForSession:(MNSession*) session;
-(void) trackEnterBackgroundForSession:(MNSession*) session;

-(NSDictionary*) getTrackingVars;

@end
