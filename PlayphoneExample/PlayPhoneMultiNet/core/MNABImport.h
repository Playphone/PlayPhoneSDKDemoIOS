//
//  MNABImport.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 18.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MNABPersonInfo : NSObject
{
    NSString       *_personName;
    NSMutableArray *_personPhones;
    NSMutableArray *_personEMails;
}

@property (nonatomic, readonly) NSString *personName;
@property (nonatomic, readonly) NSArray  *personPhones;
@property (nonatomic, readonly) NSArray  *personEMails;

@end


@interface MNABImport : NSObject

/**
 * Get contacts list
 * @return array of MNABPersonInfo of contacts with name and
 * at least on e-mail or phone number filled
 */
+ (NSArray *)getContactList;

@end
