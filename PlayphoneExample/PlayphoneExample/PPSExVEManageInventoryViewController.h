//
//  PPSExVEManageInventoryViewController.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 10.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNVItemsProvider.h"
#import "PPSExBasicViewController.h"

@interface PPSExVEManageInventoryViewController : PPSExBasicViewController <MNVItemsProviderDelegate> {
    NSArray *_itemList;
    
    UIPickerView *_itemPickerView;
    UITextField  *_itemAmountTextField;
    UILabel      *_amountLabel;
    UILabel      *_titleLabel;
    UIButton     *_addButton;
    UIButton     *_subtractButton;
}

@property (nonatomic, retain) IBOutlet UIPickerView *itemPickerView;
@property (nonatomic, retain) IBOutlet UITextField  *itemAmountTextField;
@property (nonatomic, retain) IBOutlet UILabel      *amountLabel;
@property (nonatomic, retain) IBOutlet UILabel      *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton     *addButton;
@property (nonatomic, retain) IBOutlet UIButton     *subtractButton;

- (IBAction)doAddItems:(id)sender;
- (IBAction)doSubtractItems:(id)sender;
- (IBAction)textFieldEditDidBegin:(id)sender;
- (IBAction)textFieldEditDidEnd:(id)sender;
@end
