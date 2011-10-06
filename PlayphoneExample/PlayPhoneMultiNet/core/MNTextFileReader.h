//
//  MNTextFileReader.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 10/8/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNTextFileReader : NSObject {
@private

    FILE*  _file;
    char*  _buffer;
    size_t _bufferSize;
    size_t _dataSize;
}

-(id)        initWithFileName:(NSString*) name;
-(NSString*) readLine;

@end
