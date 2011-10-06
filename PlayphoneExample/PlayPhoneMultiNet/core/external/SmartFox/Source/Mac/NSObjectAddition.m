//
//  NSObjectAddition.m
//  INFSmartFoxiPhoneLibrary
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#if (TARGET_OS_IPHONE)

#import <objc/runtime.h>
#import <objc/message.h>

#import "NSObjectAddition.h"

@implementation NSObject (MyAdditions)

- (NSString *)className
{
	return [NSString stringWithUTF8String:class_getName([self class])];
}

+ (NSString *)className
{
	return [NSString stringWithUTF8String:class_getName(self)];
}

@end

#endif
