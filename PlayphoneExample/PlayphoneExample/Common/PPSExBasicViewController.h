//
//  PPSExBasicViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 06.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPSExBasicNotificationProtocol <NSObject>

- (void)playerLoggedIn;
- (void)playerLoggedOut;

@end

@interface PPSExBasicViewController : UIViewController <PPSExBasicNotificationProtocol>

- (void)updateState;

- (void)playerLoggedIn;
- (void)playerLoggedOut;

@end


@interface PPSExBasicTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,PPSExBasicNotificationProtocol>
{
    NSArray *_sectionNames;
    NSArray *_sectionRows;
    
    UITableViewCellStyle _cellStyle;
}

@property (nonatomic,retain) NSArray *sectionNames;
@property (nonatomic,retain) NSArray *sectionRows;
@property (nonatomic,assign) UITableViewCellStyle cellStyle;

- (void)showFooterLabelWithText:(NSString*)labelText;

- (void)updateState;

- (void)playerLoggedIn;
- (void)playerLoggedOut;

@end
