//
//  PPSExSocialGraphViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 12.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNWSRequest.h"
#import "MNWSBuddyListItem.h"

#import "PPSExCommon.h"
#import "PPSExUserInfoViewController.h"
#import "PPSExSocialGraphViewController.h"

static NSString *PPSExSocialGraphSectionNames[] = 
{
    @"",
};

@interface PPSExSocialGraphViewController()
@property (nonatomic,retain) NSString *requestBlockName;
@property (nonatomic,retain) NSArray  *buddyList;

- (void)updateView;
@end

@implementation PPSExSocialGraphViewController
@synthesize requestBlockName = _requestBlockName;
@synthesize buddyList = _buddyList;

- (void)viewDidLoad {
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExSocialGraphSectionNames
                                                     count:DeclaredArraySize(PPSExSocialGraphSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
    
    self.requestBlockName = nil;
    self.buddyList        = nil;
}

- (void)dealloc {
    self.requestBlockName = nil;
    self.buddyList        = nil;

    [super dealloc];
}

- (void)updateState  {
    if ([MNDirect isUserLoggedIn]) {
        MNWSRequestContent* requestContent = [[[MNWSRequestContent alloc]init]autorelease];
        
        self.requestBlockName = [requestContent addCurrUserBuddyList];
        
        MNWSRequestSender* requestSender = [[[MNWSRequestSender alloc]initWithSession:[MNDirect getSession]]autorelease];
        
        [requestSender sendWSRequestAuthorized:requestContent withDelegate:self];
    }
    else {
        [self updateView];
    }
}

- (void)updateView {
    NSMutableArray *tableViewRows = [NSMutableArray arrayWithCapacity:20];
    ((UITableView*)self.view).tableFooterView = nil;
    
    if (![MNDirect isUserLoggedIn]) {
        [self showFooterLabelWithText:PPSExUserNotLoggedInString];
    }
    else if ((self.buddyList == nil) || ([self.buddyList count] == 0)) {
        [self showFooterLabelWithText:@"No friends detected"];
    }
    else {
        PPSExMainScreenRowTypeObject *rowObject = nil;
        
        for (MNWSBuddyListItem *buddyInfo in self.buddyList) {                             
            rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:[buddyInfo getFriendUserNickName]
                                                                  subTitle:[NSString stringWithFormat:@"Now is: %@",[[buddyInfo getFriendUserOnlineNow]boolValue]?@"Online":@"Offline"]];
            rowObject.viewControllerName = @"PPSExUserInfoViewController";
            rowObject.nibName = @"PPSExUserInfoView";
            
            [tableViewRows addObject:rowObject];
            
            [rowObject release];
            rowObject = nil;
        }
    }
    
    self.sectionRows = [NSArray arrayWithObjects:tableViewRows,nil];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        
    NSString *buddyName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    MNWSBuddyListItem *selectedItem = nil;
    
    for (MNWSBuddyListItem *buddyInfo in self.buddyList) {
        if ([[buddyInfo getFriendUserNickName] isEqualToString:buddyName]) {
            selectedItem = buddyInfo;
            break;
        }
    }
    
    ((PPSExUserInfoViewController*)self.navigationController.topViewController).buddyInfo = selectedItem;
}

#pragma mark - MNWSRequestDelegate

-(void) wsRequestDidSucceed:(MNWSResponse*) response {
    self.buddyList = [response getDataForBlock: self.requestBlockName];
    self.requestBlockName = nil;
    
    [self updateView];
}

-(void) wsRequestDidFailWithError:(MNWSRequestError*) error {
    PPSExShowWSRequestErrorAlert(error.message);

    self.requestBlockName = nil;
    
    [self updateView];
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}

- (void)playerLoggedOut {
    // [self updateState];
    self.sectionRows = nil;
    [self.tableView reloadData];
    
    [self showFooterLabelWithText:PPSExUserNotLoggedInString];
}

@end
