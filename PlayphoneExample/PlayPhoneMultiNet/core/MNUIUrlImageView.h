//
//  MNUIUrlImageView.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 13.01.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNUIUrlImageView : UIImageView
 {
  NSURLConnection  *downloadConnection;
  NSMutableData    *imageData;
 }

-(void)       dealloc;
-(void)       loadImageWithUrl    : (NSURL*)          aImageUrl;

@end
