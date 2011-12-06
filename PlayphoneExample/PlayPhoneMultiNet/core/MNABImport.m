//
//  MNABImport.m
//  MultiNet client
//
//  Created by Vladislav Ogol on 18.11.11.
//  Copyright (c) 2011 PlayPhone Inc. All rights reserved.
//

#import "AddressBook/ABPerson.h"
#import "AddressBook/ABMultiValue.h"

#import "MNABImport.h"


@interface MNABPersonInfo()

- (void)setName :(NSString *)name;
- (void)addPhone:(NSString *)phone;
- (void)addEMail:(NSString *)email;

@end

@implementation MNABPersonInfo
@synthesize personName   = _personName;
@synthesize personPhones = _personPhones;
@synthesize personEMails = _personEMails;

- (id)init {
    if (self = [super init]) {
        _personName   = [[NSString       alloc]initWithString:@""];
        _personPhones = [[NSMutableArray alloc]init];
        _personEMails = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (void)dealloc {
    [_personName   release];
    [_personPhones release];
    [_personEMails release];

    _personName   = nil;
    _personPhones = nil;
    _personEMails = nil;
    
    [super dealloc];
}

- (void)setName :(NSString *)name {
    if (_personName != nil) {
        [_personName release];
    }
    
    _personName = [name retain];
}

- (void)addPhone:(NSString *)phone {
    [_personPhones addObject:phone];
}

- (void)addEMail:(NSString *)email {
    [_personEMails addObject:email];
}

@end


@implementation MNABImport

+ (NSArray *)getContactList {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef tmpPeopleArrayRef = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray *contactsArray = [[[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(tmpPeopleArrayRef)]autorelease];
    
    for (unsigned int index = 0;index < CFArrayGetCount(tmpPeopleArrayRef);index++) {
        MNABPersonInfo *personInfo;
        
        ABRecordRef     person          = (ABRecordRef)    CFArrayGetValueAtIndex(tmpPeopleArrayRef,index);
        NSString       *compositeName   = (NSString*)      ABRecordCopyCompositeName(person);
        ABMultiValueRef emailMultiValue = (ABMultiValueRef)ABRecordCopyValue(person,kABPersonEmailProperty);
        ABMultiValueRef phoneMultiValue = (ABMultiValueRef)ABRecordCopyValue(person,kABPersonPhoneProperty);

        NSUInteger      emailCount      = ABMultiValueGetCount(emailMultiValue);
        NSUInteger      phoneCount      = ABMultiValueGetCount(phoneMultiValue);

        if (((phoneCount > 0) || (emailCount > 0)) && (compositeName != nil)) {
            personInfo = [[MNABPersonInfo alloc] init];
            
            [personInfo setName:compositeName];
            
            for (NSUInteger phoneIndex = 0;phoneIndex < phoneCount;phoneIndex++) {
                [personInfo addPhone:[(NSString*)ABMultiValueCopyValueAtIndex(phoneMultiValue,phoneIndex) autorelease]];
            }
            
            for (NSUInteger emailIndex = 0;emailIndex < emailCount;emailIndex++) {
                [personInfo addEMail:[(NSString*)ABMultiValueCopyValueAtIndex(emailMultiValue,emailIndex) autorelease]];
            }
            
            [contactsArray addObject:personInfo];
            
            [personInfo release];
        }
        
        CFRelease(phoneMultiValue);
        CFRelease(emailMultiValue);
        
        [compositeName  release];
    }
    
    CFRelease(tmpPeopleArrayRef);
    CFRelease(addressBook);
    
    return(contactsArray);
}

@end
