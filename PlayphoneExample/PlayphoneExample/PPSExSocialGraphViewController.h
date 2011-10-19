//
//  PPSExSocialGraphViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 12.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//
#import "MNWSRequest.h"

#import "PPSExBasicViewController.h"

@interface PPSExSocialGraphViewController : PPSExBasicTableViewController <MNWSRequestDelegate> {
    NSString    *_requestBlockName;
    NSArray     *_buddyList;
    
    MNWSRequest *_wsRequest;
}

@end
