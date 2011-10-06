//
//  MNTools.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/13/09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import <UIKit/UIKit.h>

#import "MNCommon.h"
#import "MNTools.h"

#define MNSmartFoxServerDefaultPort (9339)
#define MNBlueBoxServerDefaultPort  (0) /* will be set by smartFox */

static NSString* MNConfigFileName    = @"MN.bundle/multinet";
static NSString* MNConfigFileNameOld = @"MN.bundle/MultiNet";
static NSString* MNConfigFileType    = @"plist";

static NSString* MNConfigParamConfigURL = @"MultiNetConfigServerURL";

BOOL MNStringScanInteger (NSInteger* value, NSString* str) {
    BOOL result = NO;

    if (str != nil) {
        NSScanner* scanner = [[NSScanner alloc] initWithString: str];

        if (scanner != nil) {
            result = [scanner scanInteger: value];

            [scanner release];
        }
    }

    return result;
}

NSInteger MNStringScanIntegerWithDefValue (NSString* str, NSInteger defValue) {
    NSInteger result;

    if (!MNStringScanInteger(&result,str)) {
        result = defValue;
    }

    return result;
}

BOOL MNStringScanLongLong (long long* value, NSString* str) {
    BOOL result = NO;

    if (str != nil) {
        NSScanner* scanner = [[NSScanner alloc] initWithString: str];

        if (scanner != nil) {
            result = [scanner scanLongLong: value];

            [scanner release];
        }
    }

    return result;
}

long long MNStringScanLongLongWithDefValue (NSString* str, long long defValue) {
    long long result;

    if (!MNStringScanLongLong(&result,str)) {
        result = defValue;
    }

    return result;
}

extern BOOL MNStringScanDouble (double* value, NSString* str) {
    BOOL result = NO;

    if (str != nil) {
        NSScanner* scanner = [[NSScanner alloc] initWithString: str];

        if (scanner != nil) {
            result = [scanner scanDouble: value];

            [scanner release];
        }
    }

    return result;
}

NSString* MNStringCreateFromInteger(NSInteger value) {
    return [[NSString alloc] initWithFormat: @"%d", value];
}

NSString* MNStringCreateFromLongLong(long long value) {
    return [[NSString alloc] initWithFormat: @"%lld", value];
}

NSString* MNDictionaryStringForKey (NSDictionary* dict, NSString* key) {
    id value = [dict objectForKey: key];

    if (value != nil && [value isKindOfClass: [NSString class]]) {
        return (NSString*)value;
    }
    else {
        return nil;
    }
}

static BOOL MNDictionaryIntegerForKey (NSDictionary* dict, NSString* key, NSInteger* value) {
    id tmpValue = [dict objectForKey: key];

    if      ([tmpValue isKindOfClass: [NSNumber class]]) {
        *value = [(NSNumber*)tmpValue integerValue];

        return YES;
    }
    else if ([tmpValue isKindOfClass: [NSString class]]) {
        NSInteger scannedValue;

        if (MNStringScanInteger(&scannedValue,(NSString*)tmpValue)) {
            *value = scannedValue;

            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

static BOOL MNDictionaryBooleanForKey (NSDictionary* dict, NSString* key, BOOL* value) {
    id tmpValue = [dict objectForKey: key];

    if ([tmpValue isKindOfClass: [NSNumber class]]) {
        *value = [(NSNumber*)tmpValue boolValue];

        return YES;
    }
    else {
        return NO;
    }
}

static NSDictionary* MNReadProperties (void) {
    NSString* multiNetPropertiesFilePath = [[[[NSBundle mainBundle] bundlePath]
                                            stringByAppendingPathComponent: MNConfigFileName]
                                             stringByAppendingPathExtension: MNConfigFileType];

    NSDictionary* result = [NSDictionary dictionaryWithContentsOfFile: multiNetPropertiesFilePath];

    if (result == nil) {
        //NOTE: we check presence of file with "old" name, this will be removed some time in the future

        multiNetPropertiesFilePath = [[[[NSBundle mainBundle] bundlePath]
                                      stringByAppendingPathComponent: MNConfigFileNameOld]
                                       stringByAppendingPathExtension: MNConfigFileType];

        result = [NSDictionary dictionaryWithContentsOfFile: multiNetPropertiesFilePath];
    }

    return result;
}

NSString* MNGetMultiNetConfigURL (void) {
    return MNDictionaryStringForKey(MNReadProperties(),MNConfigParamConfigURL);
}

NSString* MNCreateStringByReplacingPercentEscapesUTF8 (NSString* src) {
    if (src == nil) {
        return nil;
    }

    CFStringRef result = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)src,CFSTR(""),kCFStringEncodingUTF8);

    return (NSString*)result;
}

NSDictionary* MNCopyDictionaryWithGetRequestParamString (NSString* paramString) {
    if (paramString == nil) {
        return nil;
    }

    NSArray *parameters = [paramString componentsSeparatedByString: @"&"];

    NSUInteger paramIndex;
    NSUInteger paramCount = [parameters count];

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity: paramCount];

    for (paramIndex = 0; paramIndex < paramCount; paramIndex++) {
        NSString *paramNameValue = [parameters objectAtIndex: paramIndex];

        NSRange paramNameRange = [paramNameValue rangeOfString: @"="];

        if (paramNameRange.location != NSNotFound) {
            NSString* paramName  = MNCreateStringByReplacingPercentEscapesUTF8([paramNameValue substringToIndex: (paramNameRange.location)]);
            NSString* paramValue = MNCreateStringByReplacingPercentEscapesUTF8([paramNameValue substringFromIndex: (paramNameRange.location + paramNameRange.length)]);

            if (paramName != nil && paramValue != nil) {
                [dictionary setObject: paramValue forKey: paramName];
            }

            [paramValue release];
            [paramName release];
        }
        else {
            NSString* paramName  = MNCreateStringByReplacingPercentEscapesUTF8(paramNameValue);

            [dictionary setObject: @"" forKey: paramName];

            [paramName release];
        }
    }

    return  dictionary;
}

NSDictionary* MNCopyDictionaryWithURLRequestParameters (NSURLRequest* request) {
    NSString* requestMethod = [request HTTPMethod];
    NSString* parameterString = nil;

    if ([requestMethod isEqualToString: @"GET"]) {
        NSString* query = [[request URL] query];

        if (query != nil) {
            parameterString = [[query stringByReplacingOccurrencesOfString: @"+" withString: @" "] retain];
        }
    }
    else if ([requestMethod isEqualToString: @"POST"]) {
        NSData* HTTPBody = [request HTTPBody];

        if (HTTPBody != nil) {
            NSString* decodedString = [[NSString alloc] initWithData: HTTPBody encoding: NSUTF8StringEncoding];

            if (decodedString != nil) {
                parameterString = [[decodedString stringByReplacingOccurrencesOfString: @"+" withString: @" "] retain];

                [decodedString release];
            }
        }
    }

    NSDictionary* dictionary = MNCopyDictionaryWithGetRequestParamString(parameterString);

    [parameterString release];

    return dictionary;
}

static unsigned char NibbleAsHexChar (unsigned char data) {
    return (data <= 9) ? ('0' + data) : ('A' + data - 10);
}

#define MN_HTTP_PERCENT_ESCAPE_BUF_REQUIRED_SIZE (3)

static void URLEncodeCharWithPercentSequence (void* buf, unsigned char ch) {
    ((unsigned char*)buf)[0] = '%';
    ((unsigned char*)buf)[1] = NibbleAsHexChar(ch >> 4);
    ((unsigned char*)buf)[2] = NibbleAsHexChar(ch & 0x0F);
}

static char URLEncodingSpaceEscapeChar = '+';
static char URLEncodingParamValueSepChar = '=';
static char URLEncodingParamSepChar = '&';

static NSData* GetURLEncodedData (NSString* str) {
    const unsigned char* utf8Str = (const unsigned char*)[str UTF8String];
    size_t utf8StrLen = strlen((const char*)utf8Str);
    size_t index;
    unsigned char percentEscapeBuf[MN_HTTP_PERCENT_ESCAPE_BUF_REQUIRED_SIZE];

    NSMutableData* encodedData = [NSMutableData dataWithCapacity: utf8StrLen];

    for (index = 0; index < utf8StrLen; index++) {
        char ch = utf8Str[index];

        if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') ||
            (ch >= '0' && ch <= '9') ||
            (ch == '.') || (ch == '-') || (ch == '*') || (ch == '_')) {
            [encodedData appendBytes: &ch length: sizeof(ch)];
        }
        else if (ch == ' ') {
            [encodedData appendBytes: &URLEncodingSpaceEscapeChar length: sizeof(URLEncodingSpaceEscapeChar)];
        }
        else {
            URLEncodeCharWithPercentSequence(percentEscapeBuf,ch);

            [encodedData appendBytes: percentEscapeBuf length: sizeof(percentEscapeBuf)];
        }
    }

    return encodedData;
}

void MNPostRequestBodyAddParam (NSMutableData* bodyData, NSString* paramName, NSString* paramValue, BOOL urlEncodeName, BOOL urlEncodeValue) {
    if ([bodyData length] > 0) {
        [bodyData appendBytes: &URLEncodingParamSepChar length: sizeof(URLEncodingParamSepChar)];
    }

    if (urlEncodeName) {
        [bodyData appendData: GetURLEncodedData(paramName)];
    }
    else {
        [bodyData appendData: [paramName dataUsingEncoding: NSUTF8StringEncoding]];
    }

    [bodyData appendBytes: &URLEncodingParamValueSepChar length: sizeof(URLEncodingParamValueSepChar)];

    if (urlEncodeValue) {
        [bodyData appendData: GetURLEncodedData(paramValue)];
    }
    else {
        [bodyData appendData: [paramValue dataUsingEncoding: NSUTF8StringEncoding]];
    }
}

static NSMutableData* requestDataWithParams(NSDictionary* params) {
    NSMutableData* data = [[NSMutableData alloc] init];

    BOOL haveParams = NO;
    
    for (id key in params) {
        if (haveParams) {
            [data appendBytes: &URLEncodingParamSepChar length: sizeof(URLEncodingParamSepChar)];
        }
        else {
            haveParams = YES;
        }
        
        [data appendData: GetURLEncodedData(key)];
        [data appendBytes: &URLEncodingParamValueSepChar length: sizeof(URLEncodingParamValueSepChar)];
        [data appendData: GetURLEncodedData([params objectForKey: key])];
    }

    return data;
}

NSMutableURLRequest* MNGetURLRequestWithPostMethod(NSURL* url, NSDictionary* params) {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: url];

    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];

    NSMutableData* postData = requestDataWithParams(params);

    [request setHTTPBody: postData];

    return request;
}

NSString* MNGetRequestStringFromParams (NSDictionary* params) {
    NSData* requestData = requestDataWithParams(params);

    return [[[NSString alloc] initWithBytes: [requestData bytes] length: [requestData length] encoding: NSUTF8StringEncoding] autorelease];
}

typedef struct {
    NSString* from;
    NSString* to;
} MNStringReplacePair;

static MNStringReplacePair MNStringReplacePairsHTML[] = {
    { @">" , @"&gt;"   },
    { @"<" , @"&lt;"   },
    { @"\"", @"&quot;" },
    { @"'" , @"&#39;"  }
};

static MNStringReplacePair MNStringReplacePairsJS[] = {
    { @"\r", @"\\r"   },
    { @"\n", @"\\n"   },
    { @"\t", @"\\t"   },
    { @"\"", @"\\x22" },
    { @"'" , @"\\x27" },
    { @"&" , @"\\x26" },
    { @"<" , @"\\x3C" },
    { @">" , @"\\x3E" }
};

static NSString* MNStringWithReplacedPairs(NSString* string, MNStringReplacePair *pairs, unsigned int pairsCount) {
    unsigned int index;
    NSMutableString *resultStr = [NSMutableString stringWithCapacity: [string length]];

    [resultStr setString: string];

    for (index = 0; index < pairsCount; index++) {
        [resultStr replaceOccurrencesOfString: pairs[index].from withString: pairs[index].to options: 0 range: NSMakeRange(0,[resultStr length])];
    }

    return resultStr;
}

NSString* MNStringByWrappingWithQuotes (NSString* str) {
    if (str != nil) {
        return [NSString stringWithFormat: @"'%@'", str];
    }
    else {
        return nil;
    }
}

NSString* MNStringWithHTMLSpecCharsEscaped (NSString* string) {
    if (string != nil) {
        NSMutableString *result = [NSMutableString stringWithCapacity: [string length]];
        NSArray *stringParts = [string componentsSeparatedByString: @"&"];
        NSInteger index;
        NSInteger count = [stringParts count];

        for (index = 0; index < count; index++) {
            if (index > 0) {
                [result appendString: @"&amp;"];
            }

            [result appendString: MNStringWithReplacedPairs([stringParts objectAtIndex: index],MNStringReplacePairsHTML,MNDeclaredArraySize(MNStringReplacePairsHTML))];
        }

        return result;
    }
    else {
        return nil;
    }
}

NSString* MNStringWithJSSpecCharsEscaped(NSString* string) {
    if (string != nil) {
        NSMutableString *result = [NSMutableString stringWithCapacity: [string length]];
        NSArray *stringParts = [string componentsSeparatedByString: @"\\"];
        NSInteger index;
        NSInteger count = [stringParts count];

        for (index = 0; index < count; index++) {
            if (index > 0) {
                [result appendString: @"\\\\"];
            }

            [result appendString: MNStringWithReplacedPairs([stringParts objectAtIndex: index],MNStringReplacePairsJS,MNDeclaredArraySize(MNStringReplacePairsJS))];
        }

        return result;
    }
    else {
        return nil;
    }
}

NSString* MNStringAsJSString(NSString* string) {
    if (string == nil) {
        return @"null";
    } else {
        return MNStringByWrappingWithQuotes(MNStringWithJSSpecCharsEscaped(string));
    }
}

NSString* MNStringGetMD5String (NSString* string) {
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    const char *stringUtf8;

    stringUtf8 = [string UTF8String];

    CC_MD5(stringUtf8,strlen(stringUtf8),md5Buffer);

    NSMutableString* result = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];

    unsigned int byteIndex;

    for (byteIndex = 0; byteIndex < CC_MD5_DIGEST_LENGTH; byteIndex++) {
        [result appendFormat: @"%02x", md5Buffer[byteIndex]];
    }

    return result;
}

#define MN_BASE64_INBLOCK_SIZE (3)
#define MN_BASE64_OUTBLOCK_SIZE (4)
#define MN_BASE64_PADDING_CHAR ('=')

extern NSString* MNDataGetBase64String (NSData* data) {
    static char base64Dict[] = {
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
      'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
      'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
      'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
      'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
      'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
      'w', 'x', 'y', 'z', '0', '1', '2', '3',
      '4', '5', '6', '7', '8', '9', '+', '/'
    };

    NSUInteger dataSize = [data length];
    const unsigned char* dataBytes = [data bytes];
    char buffer[MN_BASE64_OUTBLOCK_SIZE + 1];

    NSMutableString* result = [NSMutableString stringWithCapacity: (dataSize + MN_BASE64_INBLOCK_SIZE - 1) / MN_BASE64_INBLOCK_SIZE * MN_BASE64_OUTBLOCK_SIZE];

    buffer[MN_BASE64_OUTBLOCK_SIZE] = '\0';

    while (dataSize >= MN_BASE64_INBLOCK_SIZE) {
        buffer[0] = base64Dict[ (dataBytes[0] & 0xFC) >> 2];
        buffer[1] = base64Dict[((dataBytes[0] & 0x03) << 4) | (dataBytes[1] >> 4)];
        buffer[2] = base64Dict[((dataBytes[1] & 0x0F) << 2) | (dataBytes[2] >> 6)];
        buffer[3] = base64Dict[  dataBytes[2] & 0x3F];

        [result appendFormat: @"%s",buffer];

        dataBytes += MN_BASE64_INBLOCK_SIZE;
        dataSize  -= MN_BASE64_INBLOCK_SIZE;
    }

    if (dataSize == 1) {
        buffer[0] = base64Dict[ (dataBytes[0] & 0xFC) >> 2];
        buffer[1] = base64Dict[((dataBytes[0] & 0x03) << 4)];
        buffer[2] = MN_BASE64_PADDING_CHAR;
        buffer[3] = MN_BASE64_PADDING_CHAR;

        [result appendFormat: @"%s",buffer];
    }
    else if (dataSize == 2) {
        buffer[0] = base64Dict[ (dataBytes[0] & 0xFC) >> 2];
        buffer[1] = base64Dict[((dataBytes[0] & 0x03) << 4) | (dataBytes[1] >> 4)];
        buffer[2] = base64Dict[((dataBytes[1] & 0x0F) << 2)];
        buffer[3] = MN_BASE64_PADDING_CHAR;

        [result appendFormat: @"%s",buffer];
    }

    return result;
}

NSString* MNGetDeviceIdMD5(void) {
    return MNStringGetMD5String([[UIDevice currentDevice] uniqueIdentifier]);
}

NSString* MNGetAppVersionInternal (void) {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
}

NSString* MNGetAppVersionExternal (void) {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
}

typedef struct {
    NSUInteger status;
    NSString* name;
} MNSessionStatusNameInfo;

#define MNSessionStatusDefineName(name) \
 { name, @#name }

static MNSessionStatusNameInfo MNSessionStatusNames[] = {
    MNSessionStatusDefineName(MN_OFFLINE),
    MNSessionStatusDefineName(MN_CONNECTING),
    MNSessionStatusDefineName(MN_LOGGEDIN),
    MNSessionStatusDefineName(MN_IN_GAME_WAIT),
    MNSessionStatusDefineName(MN_IN_GAME_START),
    MNSessionStatusDefineName(MN_IN_GAME_PLAY),
    MNSessionStatusDefineName(MN_IN_GAME_END)
};

#undef MNSessionStatusNameInfo

NSString* MNSessionStatusGetNameByCode (NSUInteger status) {
    BOOL found = NO;
    unsigned int index = 0;

    while (!found && index < MNDeclaredArraySize(MNSessionStatusNames)) {
        if (MNSessionStatusNames[index].status == status) {
            found = YES;
        }
        else {
            index++;
        }
    }

    if (found) {
        return MNSessionStatusNames[index].name;
    }
    else {
        return nil;
    }
}

BOOL      MNSessionStatusGetCodeByName (NSUInteger *status, NSString* name) {
    BOOL found = NO;
    unsigned int index = 0;

    if (name == nil) {
        return NO;
    }

    while (!found && index < MNDeclaredArraySize(MNSessionStatusNames)) {
        if ([MNSessionStatusNames[index].name isEqualToString: name]) {
            found = YES;
            *status = MNSessionStatusNames[index].status;
        }
        else {
            index++;
        }
    }

    return found;
}

BOOL      MNSessionIsStatusValid       (NSUInteger status) {
    return status == MN_OFFLINE || status == MN_CONNECTING || status == MN_LOGGEDIN ||
           status == MN_IN_GAME_WAIT || status == MN_IN_GAME_START || status == MN_IN_GAME_PLAY ||
           status == MN_IN_GAME_END;
}

extern NSInteger MNRand (void) {
    return rand();
}

static NSArray* MNCopyNumberArrayFromCSVString (NSString* string, BOOL longLongMode) {
    NSMutableArray* result = nil;
    NSArray* parts = [string componentsSeparatedByString: @","];

    if (parts != nil) {
        NSUInteger index;
        NSUInteger count;
        BOOL ok = YES;

        index = 0;
        count = [parts count];
        result = [[NSMutableArray alloc] initWithCapacity: count];

        while (index < count && ok) {
            NSNumber* numberValue;

            if (longLongMode) {
                long long longLongValue;

                ok = MNStringScanLongLong(&longLongValue,(NSString*)[parts objectAtIndex: index]);

                if (ok) {
                    numberValue = [[NSNumber alloc] initWithLongLong: longLongValue];
                }
            }
            else {
                NSInteger intValue;

                ok = MNStringScanInteger(&intValue,(NSString*)[parts objectAtIndex: index]);

                if (ok) {
                    numberValue = [[NSNumber alloc] initWithInteger: intValue];
                }
            }

            if (ok) {
                [result addObject: numberValue];

                [numberValue release];

                index++;
            }
        }

        if (!ok) {
            [result release];

            result = nil;
        }
    }

    return result;
}

NSArray* MNCopyIntegerArrayFromCSVString (NSString* string) {
    return MNCopyNumberArrayFromCSVString(string,NO);
}

NSArray* MNCopyLongLongArrayFromCSVString (NSString* string) {
    return MNCopyNumberArrayFromCSVString(string,YES);
}

NSString* MNGetGameSecret(unsigned int secret1, unsigned int secret2, unsigned int secret3, unsigned int secret4) {
    return [NSString stringWithFormat: @"%08x-%08x-%08x-%08x", secret1, secret2, secret3, secret4];
}

static BOOL MNCharIsDigit (unichar c) {
    return c >= '0' && c <= '9';
}

static NSInteger MNCharGetDigit (unichar c) {
    return c - '0';
}

BOOL MNParseMNUserNameToComponents (MNUserId* userId, NSString** plainName, NSString* structuredName) {
    NSUInteger nameLength = [structuredName length];
    NSInteger  pos        = nameLength - 1;

    if (pos < 0) {
        return NO;
    }

    if ([structuredName characterAtIndex: pos] != ']') {
        return NO;
    }

    MNUserId tempId = 0;
    MNUserId factor = 1;

    for (pos = pos - 1; pos >= 0 && MNCharIsDigit([structuredName characterAtIndex: pos]); pos--) {
        tempId += MNCharGetDigit([structuredName characterAtIndex: pos]) * factor;
        factor *= 10;
    }

    if (tempId == 0) {
        return NO;
    }

    if (pos < 0 || [structuredName characterAtIndex: pos] != '[') {
        return NO;
    }

    pos--;

    if (pos < 0 || [structuredName characterAtIndex: pos] != ' ') {
        return NO;
    }

    *userId = tempId;
    *plainName = [structuredName substringToIndex: pos];

    return YES;
}

NSString* MNStringEscapeSimple(NSString* str, NSString* charToEscape, NSString* escapeChar) {
    return MNStringEscapeCharSimple(MNStringEscapeCharSimple
                                     (str,escapeChar,escapeChar),
                                    charToEscape,
                                    escapeChar);
}

NSString* MNStringUnEscapeSimple(NSString* str, NSString* charToEscape, NSString* escapeChar) {
    return MNStringUnEscapeCharSimple(MNStringUnEscapeCharSimple
                                       (str,charToEscape,escapeChar),
                                      escapeChar,
                                      escapeChar);
}

NSString* MNStringEscapeCharSimple(NSString* str, NSString* charToEscape, NSString* escapeChar) {
    NSData* charToEscapeData = [charToEscape dataUsingEncoding: NSUTF8StringEncoding];

    if ([charToEscapeData length] != 1) {
        return nil;
    }

    NSString* charToEscapeReplaceStr = [NSString stringWithFormat: @"%@%02X",escapeChar,(unsigned int)(((unsigned char*)[charToEscapeData bytes])[0])];

    return [str stringByReplacingOccurrencesOfString: charToEscape withString: charToEscapeReplaceStr];
}

NSString* MNStringUnEscapeCharSimple(NSString* str, NSString* charToEscape, NSString* escapeChar) {
    NSData* charToEscapeData = [charToEscape dataUsingEncoding: NSUTF8StringEncoding];

    if ([charToEscapeData length] != 1) {
        return nil;
    }

    NSString* charToEscapeReplaceStr = [NSString stringWithFormat: @"%@%02X",escapeChar,(unsigned int)(((unsigned char*)[charToEscapeData bytes])[0])];

    return [str stringByReplacingOccurrencesOfString: charToEscapeReplaceStr withString: charToEscape];
}

void MNDisplayAlertMessage(NSString* title, NSString* message) {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: title
                               message: message
                               delegate: nil
                               cancelButtonTitle: @"Ok"
                               otherButtonTitles: nil];

   [alertView show];
   [alertView release];
}
