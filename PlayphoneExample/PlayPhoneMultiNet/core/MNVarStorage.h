//
//  MNVarStorage.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 9/22/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNVarStorage : NSObject {
    @private

    NSMutableDictionary* persistentStorage;
    NSMutableDictionary* tempStorage;
}

-(id) initWithContentsOfFile:(NSString*) path;
-(BOOL) writeToFile:(NSString*) path;

-(void) setValue:(NSString*) value forVariable:(NSString*) name;
-(NSString*) getValueForVariable:(NSString*) name;

-(NSDictionary*) dictionaryWithVariablesByMask:(NSString*) mask;
-(NSDictionary*) dictionaryWithVariablesByMasks:(NSArray*) masks;

-(void) removeVariablesByMask:(NSString*) mask;
-(void) removeVariablesByMasks:(NSArray*) masks;

@end
