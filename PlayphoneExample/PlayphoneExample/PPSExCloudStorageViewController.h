//
//  PPSExCloudStorageViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 12.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNGameCookiesProvider.h"
#import "PPSExBasicViewController.h"

@interface PPSExCloudStorageViewController : PPSExBasicViewController <MNGameCookiesProviderDelegate> {
    UITextField *_cookieTextField;
    UITextView *_cookiesListTextView;
    UIButton *_doReadCloud;
}

@property (nonatomic, retain) IBOutlet UITextField *cookieTextField;
@property (nonatomic, retain) IBOutlet UITextView *cookiesListTextView;
@property (retain, nonatomic) IBOutlet UIButton *storeInCloudButton;
@property (retain, nonatomic) IBOutlet UIButton *readCloudButton;

- (IBAction)doStoreInCloud:(id)sender;
- (IBAction)doReadCloud:(id)sender;

@end
