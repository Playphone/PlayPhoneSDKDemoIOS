//
//  MNABImportCellView.m
//  MultiNet client
//
//  Created by Vlad Ogol on 02.06.09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNABImportCellView.h"

@interface MNABImportCellView()

-(void)       checkButtonUpInside : (id)              sender;

-(void)       setUserName         : (NSString*)       name;
-(NSString*)  getUserName;

-(void)       setUserEmail        : (NSString*)       email;
-(NSString*)  getUserEmail;

-(void)       setUserAvatar       : (UIImage*)        avatar;
-(UIImage*)   getUserAvatar;

@end


@implementation MNABImportCellView

@synthesize checkedFlag;

-(id)         initWithFrame       : (CGRect)          frame
            reuseIdentifier       : (NSString*)       reuseIdentifier
 {
  if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
   {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    //Init with sizes and places according to full-screen application and use autosizing to fit to real placeholder
    userNameLabel       = [[UILabel     alloc]initWithFrame:CGRectMake(51 ,2 ,210,22)];
    userEmailLabel      = [[UILabel     alloc]initWithFrame:CGRectMake(51 ,23,210,18)];
    userAvatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2  ,2 ,40 ,40)];
    checkButton         = [[UIButton    alloc]initWithFrame:CGRectMake(280,2 ,40 ,40)];

    userNameLabel      .autoresizingMask = UIViewAutoresizingFlexibleWidth;
    userEmailLabel     .autoresizingMask = UIViewAutoresizingFlexibleWidth;
    userAvatarImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    checkButton        .autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    userNameLabel .minimumFontSize = 20;
    userNameLabel .adjustsFontSizeToFitWidth = YES;
    userNameLabel.font  = [userNameLabel.font fontWithSize:23];

    userEmailLabel.minimumFontSize = 15;
    userEmailLabel.font  = [userEmailLabel.font fontWithSize:16];
    userEmailLabel.adjustsFontSizeToFitWidth = YES;

    [checkButton setBackgroundImage:[UIImage imageNamed:@"MN.bundle/Images/check_unchecked.png"   ] forState:UIControlStateNormal  ];
    [checkButton setBackgroundImage:[UIImage imageNamed:@"MN.bundle/Images/check_checked.png"     ] forState:UIControlStateSelected];
    [checkButton setBackgroundImage:[UIImage imageNamed:@"MN.bundle/Images/check_midlechecked.png"] forState:UIControlStateHighlighted | UIControlStateNormal  ];
    [checkButton setBackgroundImage:[UIImage imageNamed:@"MN.bundle/Images/check_midlechecked.png"] forState:UIControlStateHighlighted | UIControlStateSelected];

    [checkButton addTarget:self action:@selector(checkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:userNameLabel];
    [self addSubview:userEmailLabel];
    [self addSubview:userAvatarImageView];
    [self addSubview:checkButton];
   }

  return self;
 }

- (void)      setSelected         : (BOOL)            selected
                 animated         : (BOOL)            animated
 {
  [super setSelected:selected animated:animated];
   // Configure the view for the selected state
 }

- (void)      dealloc
 {
  [userNameLabel       release];
  [userEmailLabel      release];
  [userAvatarImageView release];
  [checkButton         release];

  [super dealloc];
 }

-(void)       checkButtonUpInside : (id)              sender
 {
  self.checkedFlag = !self.checkedFlag;
 }

#pragma mark ========= Property Setters/Getters ==========

-(void)       setUserName         : (NSString*)       name
 {
  userNameLabel.text = name;
 }
-(NSString*)  getUserName
 {
  return userNameLabel.text;
 }

-(void)       setUserEmail        : (NSString*)       email
 {
  userEmailLabel.text = email;
 }
-(NSString*)  getUserEmail
 {
  return userEmailLabel.text;
 }

-(void)       setUserAvatar       : (UIImage*)        avatar
 {
  userAvatarImageView.image = avatar;
 }
-(UIImage*)   getUserAvatar
 {
  return userAvatarImageView.image;
 }

-(void)       setCheckedFlag      : (BOOL)            aCheckedFlag
 {
  checkedFlag = aCheckedFlag;
  checkButton.selected = checkedFlag;
 }

@end
