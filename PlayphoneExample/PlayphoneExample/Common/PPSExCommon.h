//
//  PPSExCommon.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#ifndef PlayphoneExample_PPSExCommon_h
#define PlayphoneExample_PPSExCommon_h

#import <UIKit/UIKit.h>
#import "MNVShopProvider.h"

#define MARK NSLog(@"%s",__PRETTY_FUNCTION__)

#define DeclaredArraySize(Array) ((int)(sizeof(Array) / sizeof(Array[0])))

#define PPSExGameId      (10900)
#define PPSExGameSecret1 (0xae2b10f2)
#define PPSExGameSecret2 (0x248f58d9)
#define PPSExGameSecret3 (0xc9654f24)
#define PPSExGameSecret4 (0x37960337)

#define PPSExCommonStringDefCapacity (1024)

#define PPSExSessionStatusAsString(status) status==MN_OFFLINE?"MN_OFFLINE":status==MN_CONNECTING?"MN_CONNECTING":status==MN_LOGGEDIN?"MN_LOGGEDIN":status==MN_IN_GAME_WAIT?"MN_IN_GAME_WAIT":status==MN_IN_GAME_START?"MN_IN_GAME_START":status==MN_IN_GAME_PLAY?"MN_IN_GAME_PLAY":status==MN_IN_GAME_END?"MN_IN_GAME_END":"[Invalid Status]"
#define PPSExUserStatusAsString(status)    status==MN_USER_CHATER?"MN_USER_CHATER":status==MN_USER_PLAYER?"MN_USER_PLAYER":status==MN_USER_STATUS_UNDEFINED?"MN_USER_STATUS_UNDEFINED":"[Invalid Status]"
#define PPSExLogMNSessionStatus(status)    NSLog(@"SessionStatus. %s: %s",#status,PPSExSessionStatusAsString(status))
#define PPSExLogMNPlayerStatus(status)     NSLog(@"PlayerStatus. %s: %s",#status,PPSExUserStatusAsString(status))

NSString *PPSExUserNotLoggedInString;
NSString *PPSExInvalidNumberFormatString;
NSString *PPSExLeaderboardEmpty;

typedef struct
{
    NSString *rowTitle;
    NSString *rowSubTitle;
    NSString *viewControllerName;
    NSString *nibName;
} PPSExMainScreenRowType;


@interface PPSExMainScreenRowTypeObject : NSObject {
@private
    NSString *_rowTitle;
    NSString *_rowSubTitle;
    NSString *_viewControllerName;
    NSString *_nibName;
}

@property (nonatomic,retain) NSString *rowTitle;
@property (nonatomic,retain) NSString *rowSubTitle;
@property (nonatomic,retain) NSString *viewControllerName;
@property (nonatomic,retain) NSString *nibName;

- (id)initWithNativeRow:(PPSExMainScreenRowType)row;
- (id)initWithTitle:(NSString *)title subTitle:(NSString *) subTitle;

- (void)dealloc;

+ (NSArray *)getArrayOfNativeRows:(PPSExMainScreenRowType *)rowsArray count:(NSUInteger)rowsCount;

@end

NSString *MNVShopPackGetPriceString(MNVShopPackInfo *packInfo);

void PPSExShowAlert(NSString *message,NSString *title);
void PPSExShowWSRequestErrorAlert(NSString *message);
void PPSExShowNotLoggedInAlert (void);
void PPSExShowInvalidNumberFormatAlert(void);

BOOL PPSExScanInteger(NSString *string,NSInteger *integerValuePtr);
BOOL PPSExScanLongLong(NSString *string,long long *integerValuePtr);
BOOL PPSExScanDouble(NSString *string,double *doubleValuePtr);

BOOL PPSExIsIPad(void);
CGFloat PPSExGetKeyboardHeight(void);

#endif
