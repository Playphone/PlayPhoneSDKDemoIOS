//
//  MNLauncherTools.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 10/29/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define mn_extern_c extern "C"
#else
#define mn_extern_c extern
#endif

mn_extern_c BOOL MNLauncherIsURLSchemeSupported (NSString* scheme);
mn_extern_c BOOL MNLauncherStartApp             (NSString* scheme, NSString* params);
mn_extern_c BOOL MNLauncherIsLauncherURL        (NSURL* url, NSInteger gameId);
mn_extern_c NSString* MNLauncherGetLaunchParams (NSURL* url);

#undef mn_extern_c
