//
//  PPSExVEManageInventoryViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 10.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//
#import "MNDirect.h"
#import "MNVItemsProvider.h"

#import "PPSExCommon.h"
#import "PPSExVEManageInventoryViewController.h"

#define PPSExVEManageInventoryNotLoggedInString (@"N/A")

#define PPSExKeyboardHeight                     (263)
#define PPSExNavigationPaneHeight               (65)
#define PPSExTextFieldGap                       (10)


@interface PPSExVEManageInventoryViewController()
@property (nonatomic,retain) NSArray *itemList;

- (void)updateView;
- (void)updateAmountOfCurrentItem;
- (void)updateAmountOfItem:(MNGameVItemInfo*)itemInfo;

- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;

@end


@implementation PPSExVEManageInventoryViewController
@synthesize itemList            = _itemList;
@synthesize itemPickerView      = _itemPickerView;
@synthesize itemAmountTextField = _itemAmountTextField;
@synthesize amountLabel         = _amountLabel;
@synthesize titleLabel          = _titleLabel;
@synthesize addButton           = _addButton;
@synthesize subtractButton      = _subtractButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MNDirect vItemsProvider]addDelegate:self];
}

- (void)viewDidUnload {
    [self setItemPickerView     :nil];
    [self setItemAmountTextField:nil];
    [self setAmountLabel        :nil];
    [self setTitleLabel         :nil];
    [self setAddButton          :nil];
    [self setSubtractButton     :nil];

    self.itemList = nil;
    
    [super viewDidUnload];
}

- (void)dealloc {
    [_itemPickerView      release];
    [_itemAmountTextField release];
    [_itemList            release];
    [_amountLabel         release];
    [_titleLabel          release];
    [_addButton           release];
    [_subtractButton      release];
    
    [[MNDirect vItemsProvider]removeDelegate:self];

    [super dealloc];
}

- (void)updateState {
    if ([[MNDirect vItemsProvider]isGameVItemsListNeedUpdate]) {
        [[MNDirect vItemsProvider]doGameVItemsListUpdate];
    }
    else {
        [self updateView];
    }
    
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)updateView {
    self.itemList = [[MNDirect vItemsProvider]getGameVItemsList];
    [self.itemPickerView reloadAllComponents];
    
    if ((self.itemList != nil) && ([self.itemList count] > 0)) {
        MNGameVItemInfo *itemInfo = [self.itemList objectAtIndex:0];
        [self updateAmountOfItem:itemInfo];
    }
}

- (void)updateAmountOfCurrentItem {
    int selectedItem = [self.itemPickerView selectedRowInComponent:0];
    
    if (selectedItem == -1) {
        self.amountLabel.text = PPSExVEManageInventoryNotLoggedInString;
    }
    else if (selectedItem >= [self.itemList count]) {
        self.amountLabel.text = PPSExVEManageInventoryNotLoggedInString;
    }
    else {
        [self updateAmountOfItem:[self.itemList objectAtIndex:selectedItem]];
    }
}
- (void)updateAmountOfItem:(MNGameVItemInfo*)itemInfo {
    if ([MNDirect isUserLoggedIn]) {
        self.amountLabel.text = [NSString stringWithFormat:@"%lld",[[MNDirect vItemsProvider]getPlayerVItemCountById:itemInfo.vItemId]];
    }
    else {
        self.amountLabel.text = PPSExVEManageInventoryNotLoggedInString;
    }
}

- (void)switchToLoggedInState {
    self.titleLabel .text   = @"Current Amount:";
    self.amountLabel.hidden = NO;
    
    self.itemAmountTextField.enabled = YES;
    self.addButton          .enabled = YES;
    self.subtractButton     .enabled = YES;
}
- (void)switchToNotLoggedInState {
    self.titleLabel .text   = PPSExUserNotLoggedInString;
    self.amountLabel.hidden = YES;
    self.amountLabel.text   = PPSExVEManageInventoryNotLoggedInString;

    self.itemAmountTextField.text    = @"";
    self.itemAmountTextField.enabled = NO;
    self.addButton          .enabled = NO;
    self.subtractButton     .enabled = NO;
}

- (IBAction)doAddItems:(id)sender {
    NSInteger amount;
    
    MNGameVItemInfo *itemInfo = [self.itemList objectAtIndex:[self.itemPickerView selectedRowInComponent:0]];
    
    if (itemInfo != nil) {
        if (!PPSExScanInteger(self.itemAmountTextField.text,&amount)){
            PPSExShowInvalidNumberFormatAlert();
        }
        else {
            [[MNDirect vItemsProvider]reqAddPlayerVItem:itemInfo.vItemId
                                                  count:amount
                                 andClientTransactionId:[[MNDirect vItemsProvider]getNewClientTransactionId]];
        }
    }

    [self.itemAmountTextField resignFirstResponder];
}
- (IBAction)doSubtractItems:(id)sender {
    NSInteger amount;
    
    MNGameVItemInfo *itemInfo = [self.itemList objectAtIndex:[self.itemPickerView selectedRowInComponent:0]];
    
    if (itemInfo != nil) {
        if (!PPSExScanInteger(self.itemAmountTextField.text,&amount)){
            PPSExShowInvalidNumberFormatAlert();
        }
        else {
            [[MNDirect vItemsProvider]reqAddPlayerVItem:itemInfo.vItemId
                                                  count:-amount
                                 andClientTransactionId:[[MNDirect vItemsProvider]getNewClientTransactionId]];
        }
    }

    [self.itemAmountTextField resignFirstResponder];
}
- (IBAction)textFieldEditDidBegin:(id)sender {
    [((UIScrollView*)self.view) 
     setContentOffset:CGPointMake(0,(self.itemAmountTextField.frame.origin.y    + 
                                     self.itemAmountTextField.frame.size.height - 
                                     PPSExKeyboardHeight                        +
                                     PPSExNavigationPaneHeight                  +
                                     PPSExTextFieldGap))
     animated:YES];
}
- (IBAction)textFieldEditDidEnd:(id)sender {
    [((UIScrollView*)self.view) setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.itemList count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component != 0) {
        return @"Invalid component";
    }
    
    MNGameVItemInfo *itemInfo = [self.itemList objectAtIndex:row];
    
    return itemInfo.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component != 0) {
        NSLog(@"Invalid component");
        
        return;
    }
    
    [self updateAmountOfItem:[self.itemList objectAtIndex:row]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - MNVItemsProviderDelegate

- (void)onVitemListUpdated {
    [self updateView];
}

-(void) onVItemsTransactionCompleted:(MNVItemsTransactionInfo*) transaction {
    PPSExShowAlert(@"Item amount changed successfully", @"Transfer succeeded");
    [self updateAmountOfCurrentItem];
}

-(void) onVItemsTransactionFailed:(MNVItemsTransactionError*) transactionError {
    PPSExShowAlert([NSString stringWithFormat:
                    @"Error code: [%d]\nMessage: [%@]",
                    transactionError.failReasonCode,
                    transactionError.errorMessage],
                   @"Transfer failed");
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    [self updateState];
}
- (void)playerLoggedOut {
    //[self updateState];
    
    [self switchToNotLoggedInState];
}

@end
