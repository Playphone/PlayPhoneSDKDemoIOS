//
//  MNABImportDialogView.h
//  MultiNet client
//
//  Created by Vlad Ogol on 09.06.09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNABImportTableViewDataSource;

@protocol MNABImportDelegate
/* on success contactArray is filled with MNABContactInfo */
/* on cancel contactArray is nil                            */
-(void) contactImportInfoReady: (NSArray*) contactArray;
@end

@interface MNABImportDialogView : UIView
 {
  UIView          *dialogSubView;
  UITableView     *tableView;
  UIToolbar       *toolbar;
  UIBarButtonItem *importButton;
  UIBarButtonItem *cancelButton;
  UIBarButtonItem *selectAllButton;

  MNABImportTableViewDataSource *contactsTableDS;
  id<MNABImportDelegate> contactImportDelegate;
 }

@property (nonatomic,assign) id<MNABImportDelegate> contactImportDelegate;

-(id)         initWithFrame       : (CGRect)          frame;
-(void)       dealloc;

-(void)       showOnTop;

@end
