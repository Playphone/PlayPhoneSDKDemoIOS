//
//  MNABImportTableViewDataSource.m
//  MultiNet client
//
//  Created by Vlad Ogol on 29.05.09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNABImportCellView.h"

#import "AddressBook/ABPerson.h"
#import "AddressBook/ABMultiValue.h"

#import "MNABImportDialogView.h"
#import "MNABImportTableViewDataSource.h"

//---------------------------------------------------------------------------

#define MNAB_CELL_ID         @"contact-cell"

//---------------------------------------------------------------------------

@implementation MNABImportTableViewDataSource

-(id)         init
 {
  if (self = [super init])
   {
    peopleArray = [MNABImportTableViewDataSource copyContactInfo];
   }

  return self;
 }

-(void)       dealloc
 {
  [peopleArray release];

  [super dealloc];
 }

+(NSArray*)   copyContactInfo
 {
  ABAddressBookRef ab = ABAddressBookCreate();
  CFArrayRef tmpPeopleArrayRef = ABAddressBookCopyArrayOfAllPeople(ab);

  NSMutableArray *contactsArray = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(tmpPeopleArrayRef)];

  for (unsigned int index = 0;index < CFArrayGetCount(tmpPeopleArrayRef);index++)
   {
    MNABContactInfo *userInfo;

    ABRecordRef     person          = (ABRecordRef)    CFArrayGetValueAtIndex(tmpPeopleArrayRef,index);
    ABMultiValueRef emailMultiValue = (ABMultiValueRef)ABRecordCopyValue(person,kABPersonEmailProperty);
    NSString       *lastName        = (NSString*)      ABRecordCopyValue(person,kABPersonLastNameProperty);
    NSString       *firstName       = (NSString*)      ABRecordCopyValue(person,kABPersonFirstNameProperty);
    NSUInteger      emailCount      = ABMultiValueGetCount(emailMultiValue);

    if ((emailCount > 0) && ((lastName != nil) || (firstName != nil)))
     {
      userInfo = [[MNABContactInfo alloc] init];

      if (lastName == nil)
       {
        userInfo.contactName = [NSString stringWithFormat:@"%@",firstName];
       }
      else if (firstName == nil)
       {
        userInfo.contactName = [NSString stringWithFormat:@"%@",lastName];
       }
      else
       {
        userInfo.contactName = [NSString stringWithFormat:@"%@ %@",lastName,firstName];
       }

      if (ABPersonHasImageData(person))
       {
        userInfo.avatar = [UIImage imageWithData:[(NSData*)ABPersonCopyImageData(person) autorelease]];
       }
      else
       {
        userInfo.avatar = [UIImage imageNamed:@"MN.bundle/Images/avatar_empty.png"];
       }

      userInfo.email = [(NSString*)ABMultiValueCopyValueAtIndex(emailMultiValue,0) autorelease];
      
      [contactsArray addObject:userInfo];
      
      for (NSUInteger emailIndex = 1;emailIndex < emailCount;emailIndex++)
       {
        MNABContactInfo *tmpInfo = [[MNABContactInfo alloc]init];
        
        tmpInfo.contactName = [NSString stringWithString:userInfo.contactName];
        tmpInfo.avatar      = [UIImage  imageWithCGImage:userInfo.avatar.CGImage];
        tmpInfo.email       = [(NSString*)ABMultiValueCopyValueAtIndex(emailMultiValue,emailIndex) autorelease];
        
        [contactsArray addObject:tmpInfo];
        [tmpInfo release];
       }
      
      [userInfo release];
     }
    
    CFRelease(emailMultiValue);
    [lastName release];
    [firstName release];
   }

  CFRelease(tmpPeopleArrayRef);
  CFRelease(ab);
  
  return(contactsArray);
 }

#pragma mark ===== UITableViewDataSource implementation =====

-(NSInteger)  tableView                 : (UITableView*)   tableView
              numberOfRowsInSection     : (NSInteger)      section
 {
  return [peopleArray count];
 }

-(UITableViewCell*)
              tableView                 : (UITableView*)   tableView
              cellForRowAtIndexPath     : (NSIndexPath*)   indexPath
 {
  if (([indexPath length] != 2) && ([indexPath indexAtPosition:0] != 0))
   {
    //NOTE: We don't accept groupping in table view
    return nil;
   }

  MNABImportCellView *cellView = (MNABImportCellView*)[tableView dequeueReusableCellWithIdentifier:MNAB_CELL_ID];

  if (cellView == nil)
   {
    cellView = [[[MNABImportCellView alloc] initWithFrame:CGRectMake(0,0,tableView.bounds.size.width, 44) reuseIdentifier:MNAB_CELL_ID] autorelease];
   }

  MNABContactInfo *userInfo = (MNABContactInfo*)[peopleArray objectAtIndex:[indexPath indexAtPosition:1]];

  cellView.userName  = userInfo.contactName;
  cellView.userEmail = userInfo.email;
  cellView.userAvatarImage = userInfo.avatar;

  return cellView;
 }

@end

//---------------------------------------------------------------------------

@implementation MNABContactInfo

@synthesize contactName;
@synthesize email;
@synthesize avatar;

-(id) init
 {
  if (self = [super init])
   {
    contactName = nil;
    email       = nil;
    avatar      = nil;
   }

  return self;
 }

-(void) dealloc
 {
  [contactName release];
  [email       release];
  [avatar      release];
  
  [super dealloc];
 }

@end

