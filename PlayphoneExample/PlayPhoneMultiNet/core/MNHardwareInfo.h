//
//  MNHardwareInfo.h
//  MultiNet client
//
//  Copyright 2012 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define mn_extern_c extern "C"
#else
#define mn_extern_c extern
#endif

mn_extern_c NSString* MNHardwareGetWiFiMACAddress (void);

#undef mn_extern_c
