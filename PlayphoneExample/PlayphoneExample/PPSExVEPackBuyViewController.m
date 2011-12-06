//
//  PPSExVEPackBuyViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 09.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "MNDirect.h"
#import "MNDirectUIHelper.h"
#import "MNVShopProvider.h"
#import "MNVItemsProvider.h"

#import "PPSExCommon.h"
#import "PPSExVEPackBuyViewController.h"


#define PPSExVEPackBuyViewMinHeight (400)


@interface PPSExVEPackBuyViewController()
@property (nonatomic, retain)NSArray *packList;

- (void)switchToLoggedInState;
- (void)switchToNotLoggedInState;

@end


@implementation PPSExVEPackBuyViewController

@synthesize buyButton      = _buyButton;
@synthesize packPickerView = _packPickerView;
@synthesize packList       = _packList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentMinHeght = PPSExVEPackBuyViewMinHeight;
    
    [[MNDirect vShopProvider] addDelegate:self];
}

- (void)viewDidUnload {
    [self setPackPickerView:nil];
    [self setBuyButton     :nil];
    
    [[MNDirect vShopProvider] removeDelegate:self];

    [super viewDidUnload];
}

- (void)dealloc {
    [_packPickerView release];
    [_buyButton      release];
    
    self.packList = nil;
    
    [[MNDirect vShopProvider] removeDelegate:self];
    
    [super dealloc];
}

- (void)updateState {
    self.packList = [[MNDirect vShopProvider]getVShopPackList];
    [self.packPickerView reloadAllComponents];
    
    if ([MNDirect isUserLoggedIn]) {
        [self switchToLoggedInState];
    }
    else {
        [self switchToNotLoggedInState];
    }
}

- (void)switchToLoggedInState {
    self.buyButton.enabled = YES;
    [self.buyButton setTitle:@"Buy" forState:UIControlStateNormal];
}
- (void)switchToNotLoggedInState {
    self.buyButton.enabled = NO;
    [self.buyButton setTitle:PPSExUserNotLoggedInString forState:UIControlStateNormal];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.packList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component != 0) {
        return @"Invalid component";
    }
    
    MNVShopPackInfo *packInfo = [self.packList objectAtIndex:row];
    NSString *title = [NSString stringWithFormat:@"%@\t%@",packInfo.name,MNVShopPackGetPriceString(packInfo)];
    
    return title;
}

- (IBAction)doBuyBack:(id)sender {
    MNVShopPackInfo *packInfo = [self.packList objectAtIndex:[self.packPickerView selectedRowInComponent:0]];

    if (packInfo.priceValue == 0) {
        //Free pack
        [[MNDirect vShopProvider]procCheckoutVShopPacksSilent:[NSArray arrayWithObject:[NSNumber numberWithInt:packInfo.packId]]
                                                    packCount:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]
                                          clientTransactionId:[[MNDirect vItemsProvider]getNewClientTransactionId]];
    }
    else if (packInfo.priceItemId == 0) {
        //Pack priced in real currency
        [[MNDirect vShopProvider]execCheckoutVShopPacks:[NSArray arrayWithObject:[NSNumber numberWithInt:packInfo.packId]]
                                              packCount:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]
                                    clientTransactionId:[[MNDirect vItemsProvider]getNewClientTransactionId]];
    }
    else {
        //Pack priced in virtual currency or free
        [[MNDirect vShopProvider]procCheckoutVShopPacksSilent:[NSArray arrayWithObject:[NSNumber numberWithInt:packInfo.packId]]
                                                    packCount:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]
                                          clientTransactionId:[[MNDirect vItemsProvider]getNewClientTransactionId]];
        
    }
}

#pragma mark - MNVShopProviderDelegate

-(void) showDashboard {
    [MNDirectUIHelper showDashboard];
}

-(void) hideDashboard {
    [MNDirectUIHelper hideDashboard];
}

-(void) onCheckoutVShopPackSuccess:(MNVShopProviderCheckoutVShopPackSuccessInfo *) result {
    PPSExShowAlert(@"Pack purchased successfully",@"Purchase succeeded");
}

-(void) onCheckoutVShopPackFail:(MNVShopProviderCheckoutVShopPackFailInfo *) result {    
    PPSExShowAlert([NSString stringWithFormat:@"Error code: [%d]\nMessage: [%@]",result.errorCode,result.errorMessage],@"Purchase failed");
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
