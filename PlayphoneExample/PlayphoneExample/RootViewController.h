//
//  RootViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 05.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MNDirect.h"

@protocol PPSExBasicNotificationProtocol;

@interface RootViewController : UITableViewController <MNDirectDelegate>
{
    NSUInteger mnDirectCurStatus;
    
    id<PPSExBasicNotificationProtocol> basicNotificationDelegate;
}


@end
