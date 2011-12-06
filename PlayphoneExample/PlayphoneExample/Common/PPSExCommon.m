//
//  PPSExCommon.c
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExCommon.h"


NSString *PPSExUserNotLoggedInString     = @"User is not logged in";
NSString *PPSExInvalidNumberFormatString = @"Invalid number format";
NSString *PPSExVirtualItemCurrencyString = @"vI";


#define PPSExKeyboardHeightPortraitIPhone    (216)
#define PPSExKeyboardHeightLanscapeIPhone    (162)
#define PPSExKeyboardHeightPortraitIPad      (264)
#define PPSExKeyboardHeightLanscapeIPad      (352)


@implementation PPSExMainScreenRowTypeObject

@synthesize rowTitle = _rowTitle;
@synthesize rowSubTitle = _rowSubTitle;
@synthesize viewControllerName = _viewControllerName;
@synthesize nibName = _nibName;

- (id)initWithNativeRow:(PPSExMainScreenRowType)row {

    self = [super init];
    
    if (self) {
        self.rowTitle           = row.rowTitle;
        self.rowSubTitle        = row.rowSubTitle;
        self.viewControllerName = row.viewControllerName;
        self.nibName            = row.nibName;
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title subTitle:(NSString *) subTitle {
    self = [super init];
    
    if (self) {
        self.rowTitle           = title;
        self.rowSubTitle        = subTitle;
        self.viewControllerName = @"";
        self.nibName            = @"";
    }
    
    return self;
}

- (void)dealloc {
    self.rowTitle           = nil;
    self.rowSubTitle        = nil;
    self.viewControllerName = nil;
    self.nibName            = nil;
    
    [super dealloc];
}

+ (NSArray* )getArrayOfNativeRows:(PPSExMainScreenRowType *)rowsArray count:(NSUInteger)rowsCount {
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:rowsCount];
    
    for (NSUInteger index = 0;index < rowsCount;index++) {
        [resultArray addObject:[[[PPSExMainScreenRowTypeObject alloc]initWithNativeRow:rowsArray[index]]autorelease]];
    }
    
    return (NSArray *)resultArray;
}

@end

NSString *MNVShopPackGetPriceString(MNVShopPackInfo *packInfo) {
    NSString *packPriceString = nil;
    
    if (packInfo.priceItemId == 0) {
        packPriceString = [NSString stringWithFormat:@"$%0.2f",packInfo.priceValue / 100.];
    }
    else {
        //need to determine price item name. Use general symbol "vI" for now;
        packPriceString = [NSString stringWithFormat:@"%lld %@",packInfo.priceValue,PPSExVirtualItemCurrencyString];
    }
    return  packPriceString;
}

void PPSExShowAlert(NSString *message,NSString *title) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

void PPSExShowWSRequestErrorAlert(NSString *message) {
    PPSExShowAlert(message,@"WS Request Error");
}

void PPSExShowNotLoggedInAlert (void) {
    PPSExShowAlert(PPSExUserNotLoggedInString,@"Error");
}

void PPSExShowInvalidNumberFormatAlert (void) {
    PPSExShowAlert(PPSExInvalidNumberFormatString,@"Input Error");
}

BOOL PPSExScanInteger(NSString *string,NSInteger *integerValuePtr) {
    BOOL       result  = NO;
    NSScanner* scanner = [[NSScanner alloc]initWithString:string];
    
    if (scanner != nil) {
        result = [scanner scanInteger:integerValuePtr];
        
        [scanner release];
    }
    
    return result;
}

BOOL PPSExScanLongLong(NSString *string,long long *integerValuePtr) {
    BOOL       result  = NO;
    NSScanner* scanner = [[NSScanner alloc]initWithString:string];
    
    if (scanner != nil) {
        result = [scanner scanLongLong:integerValuePtr];
        
        [scanner release];
    }
    
    return result;
}

BOOL PPSExScanDouble(NSString *string,double *doubleValuePtr) {
    BOOL       result  = NO;
    NSScanner* scanner = [[NSScanner alloc]initWithString:string];
    
    if (scanner != nil) {
        result = [scanner scanDouble:doubleValuePtr];
        
        [scanner release];
    }
    
    return result;
}

BOOL PPSExIsIPad(void) {
#ifdef UI_USER_INTERFACE_IDIOM
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
	return NO;
#endif
}


CGFloat PPSExGetKeyboardHeight(void) {
    CGFloat keyboardHeight = 0;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        if (PPSExIsIPad()) {
            keyboardHeight = PPSExKeyboardHeightPortraitIPad;
        }
        else {
            keyboardHeight = PPSExKeyboardHeightPortraitIPhone;
        }
    }
    else {
        if (PPSExIsIPad()) {
            keyboardHeight = PPSExKeyboardHeightLanscapeIPad;
        }
        else {
            keyboardHeight = PPSExKeyboardHeightLanscapeIPhone;
        }
    }
    
    return keyboardHeight;
}

