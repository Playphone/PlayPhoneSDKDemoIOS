//
//  PPSExCommon.h
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef PlayphoneExample_PPSExCommon_h
#define PlayphoneExample_PPSExCommon_h

#import <UIKit/UIKit.h>

#define PPSExGameId      (10900)
#define PPSExGameSecret1 (0xae2b10f2)
#define PPSExGameSecret2 (0x248f58d9)
#define PPSExGameSecret3 (0xc9654f24)
#define PPSExGameSecret4 (0x37960337)

#define DeclaredArraySize(Array) ((int)(sizeof(Array) / sizeof(Array[0])))

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

@property (nonatomic,readonly) NSString *rowTitle;
@property (nonatomic,readonly) NSString *rowSubTitle;
@property (nonatomic,readonly) NSString *viewControllerName;
@property (nonatomic,readonly) NSString *nibName;

- (id)initWithNativeRow:(PPSExMainScreenRowType)row;
- (id)initWithTitle:(NSString*)title subTitle:(NSString*) subTitle;

- (void)dealloc;

+ (NSArray*)getArrayOfNativeRows:(PPSExMainScreenRowType*)rowsArray count:(NSUInteger)rowsCount;

@end

#endif
