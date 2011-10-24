//
//  PPSExAnyRoomCookieViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 24.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNWSRequest.h"
#import "MNGameRoomCookiesProvider.h"

#import "PPSExBasicViewController.h"


@interface PPSExAnyRoomCookieViewController : PPSExBasicViewController <MNGameRoomCookiesProviderDelegate,MNWSRequestDelegate>
{
    NSString     *_requestBlockName;
    MNWSRequest  *_wsRequest;
    NSArray      *_roomListArray;
    
    UILabel      *_infoLabel;
    UIPickerView *_roomPickerView;
    UITextView   *_cookiesTextView;
    UIButton     *_readCookiesButton;
    UIButton     *_reloadListButton;
}

@property (retain, nonatomic) IBOutlet UIPickerView *roomPickerView;
@property (retain, nonatomic) IBOutlet UITextView   *cookiesTextView;
@property (retain, nonatomic) IBOutlet UIButton     *readCookiesButton;
@property (retain, nonatomic) IBOutlet UIButton     *reloadListButton;

- (IBAction)doReadCookies:(id)sender;
- (IBAction)doReloadList:(id)sender;

@end
