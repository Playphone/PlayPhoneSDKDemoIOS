//
//  MNStrMaskStorage.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 11/30/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNStrMaskStorage : NSObject {
    @private

    NSMutableSet* masks;
}

-(id) init;
-(void) dealloc;

-(void) addMask:(NSString*) mask;
-(void) removeMask:(NSString*) mask;

-(BOOL) checkString:(NSString*) str;

@end
