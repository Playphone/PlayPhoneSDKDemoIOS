//
//  PPSExVEPackBuyViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 09.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNDirectUIHelper.h"
#import "MNVShopProvider.h"
#import "MNVItemsProvider.h"

#import "PPSExCommon.h"
#import "PPSExVEPackBuyViewController.h"

@interface PPSExVEPackBuyViewController()
@property (nonatomic,retain)NSArray *packList;
@end


@implementation PPSExVEPackBuyViewController
@synthesize packPickerView = _packPickerView;
@synthesize packList = _packList;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UIScrollView*)self.view).contentSize = CGSizeMake(self.view.frame.size.width, 400);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    ((UIScrollView*)self.view).contentSize = CGSizeMake(self.view.frame.size.width, 400);
}

- (void)dealloc {
    [_packPickerView release];
    
    [[MNDirect vShopProvider] removeDelegate:self];

    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[MNDirect vShopProvider] addDelegate:self];
}
- (void)viewDidUnload {
    [self setPackPickerView:nil];

    [super viewDidUnload];
}

- (void)updateState {
    self.packList = [[MNDirect vShopProvider]getVShopPackList];
    [self.packPickerView reloadAllComponents];
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

-(void) onCheckoutVShopPackSuccess:(MNVShopProviderCheckoutVShopPackSuccessInfo*) result {
    PPSExShowAlert(@"Pack purchased successfully",@"Purchase succeeded");
}

-(void) onCheckoutVShopPackFail:(MNVShopProviderCheckoutVShopPackFailInfo*) result {    
    PPSExShowAlert([NSString stringWithFormat:@"Error code: [%d]\nMessage: [%@]",result.errorCode,result.errorMessage],@"Purchase failed");
}

@end
