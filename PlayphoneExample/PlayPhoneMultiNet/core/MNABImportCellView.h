//
//  MNABImportCellView.h
//  MultiNet client
//
//  Created by Vlad Ogol on 02.06.09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNABImportCellView : UITableViewCell
 {
  UILabel     *userNameLabel;
  UILabel     *userEmailLabel;
  UIImageView *userAvatarImageView;

  UIButton    *checkButton;
  BOOL         checkedFlag;
 }

@property (nonatomic,assign,setter=setUserName:  ,getter=getUserName)   NSString *userName;
@property (nonatomic,assign,setter=setUserEmail: ,getter=getUserEmail)  NSString *userEmail;
@property (nonatomic,assign,setter=setUserAvatar:,getter=getUserAvatar) UIImage  *userAvatarImage;

@property (nonatomic,setter=setCheckedFlag:) BOOL checkedFlag;

-(id)         initWithFrame       : (CGRect)          frame
            reuseIdentifier       : (NSString*)       reuseIdentifier;

-(void)       dealloc;


@end
