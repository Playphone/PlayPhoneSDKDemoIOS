//
//  PPSExServerInfoViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 10.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNServerInfoProvider.h"

#import "PPSExCommon.h"
#import "PPSExInfoPaneViewController.h"
#import "PPSExServerInfoViewController.h"


static NSString *PPSExServerInfoInvalidValue = @"<invalid value>";

static NSString *PPSExServerInfoServerTimeKeyString = @"Server Time";

@interface PPSExServerInfoViewController() 

@property (retain, nonatomic) PPSExInfoPaneViewController *infoPaneViewController;

- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;

@end

@implementation PPSExServerInfoViewController

@synthesize infoPaneViewController = _infoPaneViewController;
@synthesize infoPaneView           = _infoPaneView;
@synthesize getServerInfoButton    = _getServerInfoButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.infoPaneViewController = [[[PPSExInfoPaneViewController alloc]initWithNibName:@"PPSExInfoPaneView" bundle:[NSBundle mainBundle]]autorelease];

    self.infoPaneViewController.view.frame = self.infoPaneView.bounds;
    [self.infoPaneView addSubview:self.infoPaneViewController.view];
    
    [[MNDirect serverInfoProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [self stopActivityIndicator];

    [self setInfoPaneView          :nil];
    [self setInfoPaneViewController:nil];
    [self setGetServerInfoButton   :nil];
    
    [[MNDirect serverInfoProvider]removeDelegate:self];

    [super viewDidUnload];
}

- (void)dealloc {
    [self stopActivityIndicator];

    [_infoPaneView           release];
    [_infoPaneViewController release];
    [_getServerInfoButton    release];

    [[MNDirect serverInfoProvider]removeDelegate:self];

    [super dealloc];
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];
    }
    else {
        [self switchToNotLoggedInState];
        
    }
}

- (void)switchToLoggedInState {
    [self.infoPaneViewController setHeaderTextSafe:@"Server Info:"];
    [self.infoPaneViewController setBodyTextSafe  :@""];
    
    self.getServerInfoButton.enabled = YES;
}

- (void)switchToNotLoggedInState {
    [self.infoPaneViewController setHeaderTextSafe:PPSExUserNotLoggedInString];
    [self.infoPaneViewController setBodyTextSafe  :@""];
    
    self.getServerInfoButton.enabled = NO;
}

- (IBAction)doGetServerInfo:(id)sender {
    [[MNDirect serverInfoProvider]requestServerInfoItem:MNServerInfoServerTimeInfoKey];
    
    [self startActivityIndicator];
}

#pragma mark - MNServerInfoProviderDelegate

-(void) serverInfoWithKey:(NSInteger) key received:(NSString*) value {
    [self stopActivityIndicator];
    
    NSMutableString *infoString = [NSMutableString stringWithCapacity:PPSExCommonStringDefCapacity];
    
    if (key == MNServerInfoServerTimeInfoKey) {
        
        NSTimeInterval timeInterval = 0;
        if (!PPSExScanDouble(value,&timeInterval)) {
            [infoString appendFormat:@"%@: %@",PPSExServerInfoServerTimeKeyString, PPSExServerInfoInvalidValue];
        }
        else {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];      
            NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
            
            dateFormatter.timeStyle = NSDateFormatterMediumStyle;
            dateFormatter.dateStyle = NSDateFormatterMediumStyle;
            
            [infoString appendFormat:
             @"%@: %@ (%@)",
             PPSExServerInfoServerTimeKeyString,
             value,
             [dateFormatter stringFromDate:date]];
        }
    }
    
    [self.infoPaneViewController setBodyTextSafe:infoString];
}

-(void) serverInfoWithKey:(NSInteger) key requestFailedWithError:(NSString*) error {
    [self stopActivityIndicator];
    PPSExShowAlert(error,@"Request Error");
}


#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    // [self updateState];
    [self switchToNotLoggedInState];
}

@end
