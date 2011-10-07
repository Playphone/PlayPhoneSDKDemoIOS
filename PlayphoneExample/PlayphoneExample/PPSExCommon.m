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
        _rowTitle = [row.rowTitle retain];
        _rowSubTitle = [row.rowSubTitle retain];
        _viewControllerName = [row.viewControllerName retain];
        _nibName = [row.nibName retain];
    }
    
    return self;
}

- (void)dealloc {
    [_rowTitle release];
    [_rowSubTitle release];
    [_viewControllerName release];
    [_nibName release];
    
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