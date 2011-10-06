//
//  MNTools.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/13/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MNCommon.h"

#define MNDeclaredArraySize(array) (sizeof(array) / sizeof((array)[0]))

#ifdef __cplusplus
#define mn_extern_c extern "C"
#else
#define mn_extern_c extern
#endif

mn_extern_c BOOL MNStringScanInteger (NSInteger* value, NSString* str);
mn_extern_c BOOL MNStringScanLongLong (long long* value, NSString* str);
mn_extern_c BOOL MNStringScanDouble (double* value, NSString* str);

mn_extern_c NSInteger MNStringScanIntegerWithDefValue (NSString* str, NSInteger defValue);
mn_extern_c long long MNStringScanLongLongWithDefValue (NSString* str, long long defValue);

mn_extern_c NSString* MNStringCreateFromInteger(NSInteger value);
mn_extern_c NSString* MNStringCreateFromLongLong(long long value);

mn_extern_c NSString* MNCreateStringByReplacingPercentEscapesUTF8 (NSString* src);
mn_extern_c NSDictionary* MNCopyDictionaryWithGetRequestParamString (NSString* paramString);
mn_extern_c NSDictionary* MNCopyDictionaryWithURLRequestParameters (NSURLRequest* request);

mn_extern_c NSString* MNGetMultiNetConfigURL (void);

mn_extern_c NSString* MNStringByWrappingWithQuotes (NSString* str);
mn_extern_c NSString* MNStringWithHTMLSpecCharsEscaped (NSString* string);
mn_extern_c NSString* MNStringWithJSSpecCharsEscaped(NSString* string);

mn_extern_c void      MNPostRequestBodyAddParam (NSMutableData* bodyData, NSString* paramName, NSString* paramValue, BOOL urlEncodeName, BOOL urlEncodeValue);
mn_extern_c NSMutableURLRequest* MNGetURLRequestWithPostMethod(NSURL* url, NSDictionary* params);
mn_extern_c NSString* MNGetRequestStringFromParams (NSDictionary* params);

mn_extern_c NSString* MNStringAsJSString(NSString* string);

mn_extern_c NSString* MNStringGetMD5String (NSString* string);

mn_extern_c NSString* MNDataGetBase64String (NSData* data);

mn_extern_c NSString* MNGetDeviceIdMD5(void);

mn_extern_c NSString* MNGetAppVersionInternal (void);
mn_extern_c NSString* MNGetAppVersionExternal (void);

mn_extern_c NSString* MNSessionStatusGetNameByCode (NSUInteger status);
mn_extern_c BOOL      MNSessionStatusGetCodeByName (NSUInteger *status, NSString* name);
mn_extern_c BOOL      MNSessionIsStatusValid       (NSUInteger status);

/* return random number in range 0..RAND_MAX */
mn_extern_c NSInteger MNRand (void);

mn_extern_c NSString* MNDictionaryStringForKey (NSDictionary* dict, NSString* key);

mn_extern_c NSArray* MNCopyIntegerArrayFromCSVString (NSString* string);
mn_extern_c NSArray* MNCopyLongLongArrayFromCSVString (NSString* string);

#define MNLocalizedString(str,code) \
 [NSString stringWithFormat: @"%@ [%d]",str,code]

mn_extern_c NSString* MNGetGameSecret(unsigned int secret1, unsigned int secret2, unsigned int secret3, unsigned int secret4);

mn_extern_c BOOL MNParseMNUserNameToComponents (MNUserId* userId, NSString** plainName, NSString* formattedName);

/* escape string using following rules:                             */
/* escapeChar is replaced by escapeChar escapeCode sequence         */
/* charToEscape is replaced by escapeChar charToEscapeCode sequence */
/* for example, if charToEscape is '%' and escapeChar is '~',       */
/* escaping of string "A%B~C" results in "A~25B~7EC"                */
mn_extern_c NSString* MNStringEscapeSimple(NSString* str, NSString* charToEscape, NSString* escapeChar);
mn_extern_c NSString* MNStringUnEscapeSimple(NSString* str, NSString* charToEscape, NSString* escapeChar);

/* *Char* functions differ from MNStringEscapeSimple/MNStringUnEscapeSimple in */
/* that *Char* variants do not escape escape char itself, just charToEscape    */
mn_extern_c NSString* MNStringEscapeCharSimple(NSString* str, NSString* charToEscape, NSString* escapeChar);
mn_extern_c NSString* MNStringUnEscapeCharSimple(NSString* str, NSString* charToEscape, NSString* escapeChar);

mn_extern_c void MNDisplayAlertMessage(NSString* title, NSString* message);

#undef mn_extern_c
