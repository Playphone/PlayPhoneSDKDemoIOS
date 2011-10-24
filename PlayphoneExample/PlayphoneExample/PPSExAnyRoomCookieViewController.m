//
//  PPSExAnyRoomCookieViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 24.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNGameRoomCookiesProvider.h"
#import "MNWSRequest.h"
#import "MNWSRoomListItem.h"

#import "PPSExCommon.h"

#import "PPSExAnyRoomCookieViewController.h"


#define PPSExAnyRoomCookieViewMinHeight (415)


@interface PPSExAnyRoomCookieViewController()

@property (nonatomic, retain) NSString     *requestBlockName;
@property (nonatomic, retain) MNWSRequest  *wsRequest;
@property (nonatomic, retain) NSArray      *roomListArray;

- (void)cancelRequestSafely;

- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;

@end

@implementation PPSExAnyRoomCookieViewController

@synthesize roomPickerView    = _roomPickerView;
@synthesize cookiesTextView   = _cookiesTextView;
@synthesize readCookiesButton = _readCookiesButton;
@synthesize reloadListButton  = _reloadListButton;
@synthesize requestBlockName  = _requestBlockName;
@synthesize wsRequest         = _wsRequest;
@synthesize roomListArray     = _roomListArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomListArray    = nil;
    self.requestBlockName = nil;
    self.wsRequest        = nil;
    
    [[MNDirect gameRoomCookiesProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [self setRoomPickerView   :nil];
    [self setCookiesTextView  :nil];
    [self setReadCookiesButton:nil];
    [self setReloadListButton :nil];

    self.roomListArray = nil;
    
    [self cancelRequestSafely];
    
    [super viewDidUnload];
}

- (void)cancelRequestSafely {
    self.requestBlockName = nil;

    if (self.wsRequest != nil) {
        [self.wsRequest cancel];
        
        self.wsRequest = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UIScrollView *)self.view).contentSize = CGSizeMake(self.view.frame.size.width, PPSExAnyRoomCookieViewMinHeight);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    ((UIScrollView *)self.view).contentSize = CGSizeMake(self.view.frame.size.width, PPSExAnyRoomCookieViewMinHeight);
}

- (void)dealloc {
    [_roomPickerView    release];
    [_cookiesTextView   release];
    [_readCookiesButton release];
    [_reloadListButton  release];
   
    [_roomListArray     release];

    [self cancelRequestSafely];
    
    [[MNDirect gameRoomCookiesProvider]removeDelegate:self];

    [super dealloc];
}

- (void)updateState {
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];
        
        MNWSRequestContent *requestContent = [[[MNWSRequestContent alloc] init] autorelease];
        self.requestBlockName = [[requestContent addCurrGameRoomList] retain];
        
        MNWSRequestSender *requestSender = [[[MNWSRequestSender alloc] initWithSession: [MNDirect getSession]] autorelease];
        self.wsRequest = [requestSender sendWSRequestAuthorized: requestContent withDelegate: self];
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)switchToLoggedInState {
    self.readCookiesButton.enabled = YES;
    self.cookiesTextView.text = @"";
}

- (void)switchToNotLoggedInState {
    self.readCookiesButton.enabled = NO;
    self.cookiesTextView.text = @"";
    
    self.roomListArray = nil;
    [self.roomPickerView reloadAllComponents];
}

- (IBAction)doReadCookies:(id)sender {
    self.cookiesTextView.text = @"";
    
    for (NSUInteger key = 0;key < 5;key++) {
        MNWSRoomListItem *roomInfo = [self.roomListArray objectAtIndex:[self.roomPickerView selectedRowInComponent:0]];
        
        if (roomInfo != nil) {
            [[MNDirect gameRoomCookiesProvider]downloadGameRoomCookieForRoom:[roomInfo getRoomSFId].integerValue
                                                                     withKey:key];
        }
    }
}

- (IBAction)doReloadList:(id)sender {
    [self updateState];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.roomListArray count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component != 0) {
        return @"Invalid component";
    }
    
    MNWSRoomListItem *roomInfo = [self.roomListArray objectAtIndex:row];
    
    return [NSString stringWithFormat:@"%@ (Id: %d)",[roomInfo getRoomName],[roomInfo getRoomSFId].integerValue];
}

#pragma mark - MNGameRoomCookiesProviderDelegate

- (void)gameRoomCookieForRoom:(NSInteger) roomSFId withKey:(NSInteger) key downloadSucceeded:(NSString*) cookie {
    if (self.cookiesTextView.text.length != 0) {
        self.cookiesTextView.text = [self.cookiesTextView.text stringByAppendingString:@"\n"];
    }
    
    self.cookiesTextView.text = [self.cookiesTextView.text stringByAppendingFormat:
                                 @"Key: %d, Value: %@",
                                 key,
                                 cookie];
}

- (void)gameRoomCookieForRoom:(NSInteger) roomSFId withKey:(NSInteger) key downloadFailedWithError:(NSString*) error {
    PPSExShowAlert(error, @"Download Failed");
}

#pragma mark - MNWSRequestDelegate

- (void)wsRequestDidSucceed:(MNWSResponse *) response {
    self.roomListArray = [response getDataForBlock: self.requestBlockName];
    
    [self.roomPickerView reloadAllComponents];
    
    self.requestBlockName = nil;
    self.wsRequest        = nil;
}

- (void)wsRequestDidFailWithError:(MNWSRequestError *) error {
    PPSExShowWSRequestErrorAlert(error.message);
    
    self.requestBlockName = nil;
    self.wsRequest        = nil;
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
