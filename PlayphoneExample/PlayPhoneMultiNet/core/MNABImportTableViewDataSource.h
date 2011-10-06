//
//  MNABImportTableViewDataSource.h
//  MultiNet client
//
//  Created by Vlad Ogol on 29.05.09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/ABAddressBook.h>

@interface MNABImportTableViewDataSource : NSObject <UITableViewDataSource>
 {
  NSArray  *peopleArray;
 }

+(NSArray*)   copyContactInfo;

-(id)         init;

-(NSInteger)  tableView                 : (UITableView*)   tableView
              numberOfRowsInSection     : (NSInteger)      section;

-(UITableViewCell*)
              tableView                 : (UITableView*)   tableView
              cellForRowAtIndexPath     : (NSIndexPath*)   indexPath;
@end

@interface MNABContactInfo : NSObject
 {
  NSString *contactName;
  NSString *email;
  UIImage  *avatar;
 }

@property (nonatomic,retain) NSString *contactName;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) UIImage  *avatar;

-(id)         init;
-(void)       dealloc;

@end
