//
//  RootViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 05.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PPSExBasicViewController.h"
#import "MNDirect.h"

@protocol PPSExBasicNotificationProtocol;

@interface RootViewController : PPSExBasicTableViewController <MNDirectDelegate,UINavigationControllerDelegate>
{
    NSUInteger mnDirectCurStatus;
    
    id<PPSExBasicNotificationProtocol> basicNotificationDelegate;
}


@end
