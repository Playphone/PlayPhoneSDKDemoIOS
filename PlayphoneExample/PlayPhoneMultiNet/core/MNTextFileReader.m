//
//  MNTextFileReader.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 10/8/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNTextFileReader.h"

#define TEXT_FILE_READER_START_BUF_SIZE (128)

@implementation MNTextFileReader

-(id) initWithFileName:(NSString*) name {
    self = [super init];

    if (self != nil) {
        _file   = fopen([name cStringUsingEncoding: NSUTF8StringEncoding],"rt");
        _buffer = malloc(TEXT_FILE_READER_START_BUF_SIZE);

        if (_file == NULL || _buffer == NULL) {
            [self release];

            return nil;
        }

        _bufferSize = TEXT_FILE_READER_START_BUF_SIZE;
        _dataSize   = fread(_buffer,1,TEXT_FILE_READER_START_BUF_SIZE,_file);
    }

    return self;
}

-(void) dealloc {
    if (_file != NULL) {
        fclose(_file);
    }

    free(_buffer);

    [super dealloc];
}

-(NSString*) readLine {
    BOOL  ok    = YES;
    char* lnPtr = memchr(_buffer,'\n',_dataSize);

    while (lnPtr == NULL && _dataSize == _bufferSize && ok) {
        // ln not found in buffer - extend buffer and fill it with data till the end of file or finding ln

        size_t newSize   = _bufferSize * 2;
        char*  newBuffer = realloc(_buffer,newSize);

        if (newBuffer != NULL) {
            _buffer     = newBuffer;
            _bufferSize = newSize;

            size_t deltaSize = newSize - _dataSize;
            size_t readSize  = fread(_buffer + _dataSize,1,deltaSize,_file);

            if (readSize < deltaSize && ferror(_file)) {
                ok = NO;
            }
            else {
                lnPtr = memchr(_buffer + _dataSize,'\n',readSize);
            }

            _dataSize += readSize;
        }
        else {
            ok = NO;
        }
    }

    NSString* result = nil;

    if (ok) {
        if (lnPtr == NULL) {
            if (_dataSize > 0) {
                result = [[[NSString alloc] initWithBytes: _buffer length: _dataSize encoding: NSUTF8StringEncoding] autorelease];

                _dataSize = 0;
            }
            else {
                return nil;
            }
        }
        else {
            ptrdiff_t len = lnPtr - _buffer;

            result = [[[NSString alloc] initWithBytes: _buffer length: len encoding: NSUTF8StringEncoding] autorelease];

            len += 1;

            _dataSize -= len;

            memmove(_buffer,_buffer + len,_dataSize);

            size_t readSize  = fread(_buffer + _dataSize,1,len,_file);

            if (readSize < len && ferror(_file)) {
                result = nil;
            }
            else {
                _dataSize += readSize;
            }
        }
    }

    return result;
}

@end
