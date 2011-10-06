//
//  MNScoreProgressSideBySideView.h
//  MultiNet client
//
//  Created by Vladislav Ogol on 17.08.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNScoreProgressView.h"
#import "MNUIUrlImageView.h"

#import <UIKit/UIKit.h>


@interface MNScoreProgressSideBySideView : MNScoreProgressView {
    UIView         *mySPView;
    UILabel        *mySPPlaceLabel;
    UILabel        *mySPNameLabel;
    UILabel        *mySPScoreLabel;
//    UIImageView    *mySPProgressUpImageView;
//    UIImageView    *mySPProgressDownImageView;
    UIImageView    *mySPBackgroundFirstPlaceImageView;
    UIImageView    *mySPBackgroundDrawPlaceImageView;
    UIImageView    *mySPBackgroundSecondPlaceImageView;
    UIImageView    *oppSPBackgroundFirstPlaceImageView;
    UIImageView    *oppSPBackgroundDrawPlaceImageView;
    UIImageView    *oppSPBackgroundSecondPlaceImageView;
    MNUIUrlImageView *myUrlImageView;
    MNUIUrlImageView *oppUrlImageView;
    
    UIView         *oppSPView;
    UILabel        *oppSPPlaceLabel;
    UILabel        *oppSPNameLabel;
    UILabel        *oppSPScoreLabel;
}

@property (nonatomic,retain) UILabel        *mySPPlaceLabel;
@property (nonatomic,retain) UILabel        *mySPNameLabel;
@property (nonatomic,retain) UILabel        *mySPScoreLabel;
//@property (nonatomic,retain) UIImageView    *mySPProgressUpImageView;
//@property (nonatomic,retain) UIImageView    *mySPProgressDownImageView;
@property (nonatomic,retain) UIImageView    *mySPBackgroundFirstPlaceImageView;
@property (nonatomic,retain) UIImageView    *mySPBackgroundDrawPlaceImageView;
@property (nonatomic,retain) UIImageView    *mySPBackgroundSecondPlaceImageView;
@property (nonatomic,retain) MNUIUrlImageView *myUrlImageView;

@property (nonatomic,retain) UILabel        *oppSPPlaceLabel;
@property (nonatomic,retain) UILabel        *oppSPNameLabel;
@property (nonatomic,retain) UILabel        *oppSPScoreLabel;
@property (nonatomic,retain) UIImageView    *oppSPBackgroundFirstPlaceImageView;
@property (nonatomic,retain) UIImageView    *oppSPBackgroundDrawPlaceImageView;
@property (nonatomic,retain) UIImageView    *oppSPBackgroundSecondPlaceImageView;
@property (nonatomic,retain) MNUIUrlImageView *oppUrlImageView;

@end
