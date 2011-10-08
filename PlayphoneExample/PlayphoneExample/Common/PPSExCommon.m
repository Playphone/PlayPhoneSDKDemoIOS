//
//  PPSExCommon.c
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PPSExCommon.h"

@implementation PPSExMainScreenRowTypeObject

@synthesize rowTitle = _rowTitle;
@synthesize rowSubTitle = _rowSubTitle;
@synthesize viewControllerName = _viewControllerName;
@synthesize nibName = _nibName;


- (id)initWithNativeRow:(PPSExMainScreenRowType)row {

    self = [super init];
    
    if (self) {
        self.rowTitle = [row.rowTitle retain];
        self.rowSubTitle = [row.rowSubTitle retain];
        self.viewControllerName = [row.viewControllerName retain];
        self.nibName = [row.nibName retain];
    }
    
    return self;
}

- (id)initWithTitle:(NSString*)title subTitle:(NSString*) subTitle {
    self = [super init];
    
    if (self) {
        self.rowTitle = [title retain];
        self.rowSubTitle = [subTitle retain];
        self.viewControllerName = @"";
        self.nibName = @"";
    }
    
    return self;
}

- (void)dealloc {
    self.rowTitle = nil;
    self.rowSubTitle = nil;
    self.viewControllerName = nil;
    self.nibName = nil;
    
    [super dealloc];
}

+ (NSArray*)getArrayOfNativeRows:(PPSExMainScreenRowType*)rowsArray count:(NSUInteger)rowsCount {
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithCapacity:rowsCount];
    
    for (NSUInteger index = 0;index < rowsCount;index++) {
        [resultArray addObject:[[PPSExMainScreenRowTypeObject alloc]initWithNativeRow:rowsArray[index]]];
    }
    
    return (NSArray*)resultArray;
}

@end