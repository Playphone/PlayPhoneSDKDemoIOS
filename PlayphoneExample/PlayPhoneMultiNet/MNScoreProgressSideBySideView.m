//
//  MNScoreProgressSideBySideView.m
//  MultiNet client
//
//  Created by Vladislav Ogol on 17.08.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNDirect.h"
#import "MNScoreProgressSideBySideView.h"

#define MNScoreProgressSideBySideModeIFirst           (1)
#define MNScoreProgressSideBySideModeOppFirst         (2)
#define MNScoreProgressSideBySideModeDraw             (3)

@interface MNScoreProgressSideBySideView()

@property (nonatomic,retain) UIView         *mySPView;
@property (nonatomic,retain) UIView         *oppSPView;

-(void) makeViewInFrame:(CGRect) frame;
-(void) updateViewWithMode:(NSInteger) mode animated:(BOOL) animatedFlag;

//FIXME: move to tools
-(NSString*)  getOrdinalNumber    : (NSInteger)            intValue;
//FIXME: move to tools
-(NSString*) getSeparatedInteger:(long long) intValue separator:(NSString*) separator;

@end



@implementation MNScoreProgressSideBySideView

@synthesize mySPView;
@synthesize oppSPView;
@synthesize mySPPlaceLabel;
@synthesize mySPNameLabel;
@synthesize mySPScoreLabel;
//@synthesize mySPProgressUpImageView;
//@synthesize mySPProgressDownImageView;
@synthesize mySPBackgroundFirstPlaceImageView;
@synthesize mySPBackgroundDrawPlaceImageView;
@synthesize mySPBackgroundSecondPlaceImageView;
@synthesize myUrlImageView;

@synthesize oppSPPlaceLabel;
@synthesize oppSPNameLabel;
@synthesize oppSPScoreLabel;
@synthesize oppSPBackgroundFirstPlaceImageView;
@synthesize oppSPBackgroundDrawPlaceImageView;
@synthesize oppSPBackgroundSecondPlaceImageView;
@synthesize oppUrlImageView;

-(id) init {
    self = [super init];
    return self;
}

-(id) initWithFrame:(CGRect) frame {
    if (self = [super initWithFrame:frame]) {
        [self makeViewInFrame:frame];
    }
    
    return self;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    [self makeViewInFrame:self.frame];
}

-(void) makeViewInFrame:(CGRect) frame {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds   = YES;
 
    self.mySPView  = [[[UIView alloc]initWithFrame:CGRectMake(0                     ,0,frame.size.width / 2.0, frame.size.height)]autorelease];
    self.mySPView .autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.mySPView .backgroundColor  = [UIColor clearColor]; 

    self.oppSPView = [[[UIView alloc]initWithFrame:CGRectMake(frame.size.width / 2.0,0,frame.size.width / 2.0, frame.size.height)]autorelease];
    self.oppSPView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.oppSPView.backgroundColor  = self.mySPView.backgroundColor;
    
    
    self.mySPPlaceLabel = [[[UILabel alloc]initWithFrame:CGRectMake(65,39,31,21)]autorelease];
    self.mySPPlaceLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.mySPPlaceLabel.font             = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    self.mySPPlaceLabel.textColor        = [UIColor colorWithRed:17./255. green:23./255. blue:56./255. alpha:1];
    self.mySPPlaceLabel.backgroundColor  = [UIColor clearColor];
    self.mySPPlaceLabel.textAlignment    = UITextAlignmentCenter;

    self.oppSPPlaceLabel = [[[UILabel alloc]initWithFrame:CGRectMake(65,39,31,21)]autorelease];
    self.oppSPPlaceLabel.autoresizingMask = self.mySPPlaceLabel.autoresizingMask;
    self.oppSPPlaceLabel.font             = self.mySPPlaceLabel.font;
    self.oppSPPlaceLabel.textColor        = self.mySPPlaceLabel.textColor;
    self.oppSPPlaceLabel.backgroundColor  = self.mySPPlaceLabel.backgroundColor;
    self.oppSPPlaceLabel.textAlignment    = self.mySPPlaceLabel.textAlignment;
    
    
    self.mySPNameLabel   = [[[UILabel alloc]initWithFrame:CGRectMake(67, 2,93,37)]autorelease];
    self.mySPNameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.mySPNameLabel.font             = [UIFont fontWithName:@"Arial" size:15];
    self.mySPNameLabel.textColor        = [UIColor whiteColor];
    self.mySPNameLabel.backgroundColor  = [UIColor clearColor];
    self.mySPNameLabel.numberOfLines    = 2;
    
    self.oppSPNameLabel  = [[[UILabel alloc]initWithFrame:CGRectMake(67, 2,93,37)]autorelease];
    self.oppSPNameLabel.autoresizingMask = self.mySPNameLabel.autoresizingMask;
    self.oppSPNameLabel.font             = self.mySPNameLabel.font;
    self.oppSPNameLabel.textColor        = self.mySPNameLabel.textColor;
    self.oppSPNameLabel.backgroundColor  = self.mySPNameLabel.backgroundColor;
    self.oppSPNameLabel.numberOfLines    = self.mySPNameLabel.numberOfLines;
    
    
    self.mySPScoreLabel  = [[[UILabel alloc]initWithFrame:CGRectMake(99,40,50,21)]autorelease];
    self.mySPScoreLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    self.mySPScoreLabel.font             = [UIFont fontWithName:@"Arial" size:15];
    self.mySPScoreLabel.textColor        = [UIColor whiteColor];
    self.mySPScoreLabel.backgroundColor  = [UIColor clearColor];
    self.mySPScoreLabel.textAlignment    = UITextAlignmentRight;
    
    self.oppSPScoreLabel = [[[UILabel alloc]initWithFrame:CGRectMake(99,40,50,21)]autorelease];
    self.oppSPScoreLabel.autoresizingMask = self.mySPScoreLabel.autoresizingMask;
    self.oppSPScoreLabel.font             = self.mySPScoreLabel.font;
    self.oppSPScoreLabel.textColor        = self.mySPScoreLabel.textColor;
    self.oppSPScoreLabel.backgroundColor  = self.mySPScoreLabel.backgroundColor;
    self.oppSPScoreLabel.textAlignment    = self.mySPScoreLabel.textAlignment;
    
    
    self.mySPBackgroundFirstPlaceImageView   = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"MNScoreProgressView.bundle/Images/mnsp_sticker_green.png"]]autorelease];
    self.mySPBackgroundDrawPlaceImageView    = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"MNScoreProgressView.bundle/Images/mnsp_sticker_green.png"]]autorelease];
    self.mySPBackgroundSecondPlaceImageView  = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"MNScoreProgressView.bundle/Images/mnsp_sticker_red.png"  ]]autorelease];
    self.oppSPBackgroundFirstPlaceImageView  = [[[UIImageView alloc]initWithImage:self.mySPBackgroundFirstPlaceImageView .image]autorelease];
    self.oppSPBackgroundDrawPlaceImageView   = [[[UIImageView alloc]initWithImage:self.mySPBackgroundDrawPlaceImageView  .image]autorelease];
    self.oppSPBackgroundSecondPlaceImageView = [[[UIImageView alloc]initWithImage:self.mySPBackgroundSecondPlaceImageView.image]autorelease];
    
    self.mySPBackgroundFirstPlaceImageView .autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mySPBackgroundDrawPlaceImageView  .autoresizingMask = self.mySPBackgroundSecondPlaceImageView.autoresizingMask;
    self.mySPBackgroundSecondPlaceImageView.autoresizingMask = self.mySPBackgroundSecondPlaceImageView.autoresizingMask;
    self.oppSPBackgroundFirstPlaceImageView .autoresizingMask = self.mySPBackgroundSecondPlaceImageView.autoresizingMask;
    self.oppSPBackgroundDrawPlaceImageView  .autoresizingMask = self.mySPBackgroundSecondPlaceImageView.autoresizingMask;
    self.oppSPBackgroundSecondPlaceImageView.autoresizingMask = self.mySPBackgroundSecondPlaceImageView.autoresizingMask;
    
    self.myUrlImageView = [[[MNUIUrlImageView alloc]initWithFrame:CGRectMake(6,6,55,55)]autorelease];
    self.oppUrlImageView = [[[MNUIUrlImageView alloc]initWithFrame:CGRectMake(6,6,55,55)]autorelease];
    
    [self.mySPView  addSubview:self.mySPBackgroundFirstPlaceImageView  ];
    [self.oppSPView addSubview:self.oppSPBackgroundDrawPlaceImageView  ];
    [self.mySPView  addSubview:self.mySPBackgroundSecondPlaceImageView ];
    [self.oppSPView addSubview:self.oppSPBackgroundFirstPlaceImageView ];
    [self.mySPView  addSubview:self.mySPBackgroundDrawPlaceImageView   ];
    [self.oppSPView addSubview:self.oppSPBackgroundSecondPlaceImageView];
    [self.mySPView  addSubview:self.myUrlImageView ];
    [self.oppSPView addSubview:self.oppUrlImageView];
    [self.mySPView  addSubview:self.mySPPlaceLabel ];
    [self.oppSPView addSubview:self.oppSPPlaceLabel];
    [self.mySPView  addSubview:self.mySPNameLabel  ];
    [self.oppSPView addSubview:self.oppSPNameLabel ];
    [self.mySPView  addSubview:self.mySPScoreLabel ];
    [self.oppSPView addSubview:self.oppSPScoreLabel];
    [self addSubview:self.mySPView ];
    [self addSubview:self.oppSPView];
}

-(void) drawRect:(CGRect) rect {
    // Drawing code
}


-(void) dealloc {
    self.mySPView = nil;
    self.oppSPView = nil;
    self.mySPPlaceLabel = nil;
    self.mySPNameLabel = nil;
    self.mySPScoreLabel = nil;
    //self.mySPProgressUpImageView = nil;
    //self.mySPProgressDownImageView = nil;
    self.mySPBackgroundFirstPlaceImageView = nil;
    self.mySPBackgroundDrawPlaceImageView = nil;
    self.mySPBackgroundSecondPlaceImageView = nil;
    self.myUrlImageView = nil;
    self.oppSPPlaceLabel = nil;
    self.oppSPNameLabel = nil;
    self.oppSPScoreLabel = nil;
    self.oppSPBackgroundFirstPlaceImageView = nil;
    self.oppSPBackgroundDrawPlaceImageView = nil;
    self.oppSPBackgroundSecondPlaceImageView = nil;
    self.oppUrlImageView = nil;

    [super dealloc];
}

-(void) prepareView {
    if (![self checkProvider]) {
        return;
    }
    
    self.mySPPlaceLabel.text = @"";
    self.mySPNameLabel .text = [[MNDirect getSession] getMyUserInfo].userName;
    self.mySPScoreLabel.text = @"";
//    self.mySPProgressUpImageView  .hidden = YES;
//    self.mySPProgressDownImageView.hidden = YES;

    self.oppSPPlaceLabel.text = @"";
    self.oppSPNameLabel .text = @"";
    self.oppSPScoreLabel.text = @"";
    self.oppUrlImageView.hidden = YES;
     
     
    [self updateViewWithMode:MNScoreProgressSideBySideModeDraw animated:NO];
     
    [self.myUrlImageView loadImageWithUrl:[NSURL URLWithString:[[[MNDirect getSession] getMyUserInfo]getAvatarUrl]]];
}

-(void) scoresUpdated:(NSArray*) scoreProgressItems {
    // virtual
    MNScoreProgressProviderItem *mySPItem  = nil;
    MNScoreProgressProviderItem *oppSPItem = nil;
    NSUInteger                 index     = 0;

    while ((index < [scoreProgressItems count]) &&
           ((mySPItem == nil) || (oppSPItem == nil))) {
        MNScoreProgressProviderItem *item = [scoreProgressItems objectAtIndex:index];
        
        if (item.userInfo.userId == [[MNDirect getSession] getMyUserInfo].userId) {
            mySPItem = item;
            [mySPItem retain];
        }
        else if (oppSPItem == nil) {
            oppSPItem = item;
        }
        
        index++;
    }
    
    if (mySPItem == nil) {
        mySPItem = [[MNScoreProgressProviderItem alloc]initWithUserInfo:[[MNDirect getSession] getMyUserInfo] score:0 andPlace:[scoreProgressItems count] + 1];
    }
    
    if (oppSPItem != nil) {
        self.mySPPlaceLabel.text = [self getOrdinalNumber:mySPItem.place];
        self.mySPNameLabel .text = mySPItem.userInfo.userName;
        self.mySPScoreLabel.text = [NSString stringWithFormat:@"%@",[self getSeparatedInteger:mySPItem.score separator:@","]];

        //self.mySPProgressUpImageView  .hidden = scoreDiff <= spPrevScoreDiff;
        //self.mySPProgressDownImageView.hidden = scoreDiff >= spPrevScoreDiff;
        
        self.oppSPPlaceLabel.text = [self getOrdinalNumber:oppSPItem.place];
        self.oppSPNameLabel .text = oppSPItem.userInfo.userName;
        self.oppSPScoreLabel.text = [NSString stringWithFormat:@"%@",[self getSeparatedInteger:oppSPItem.score separator:@","]];;
        self.oppUrlImageView.hidden = NO;
        [self.oppUrlImageView loadImageWithUrl:[NSURL URLWithString:[oppSPItem.userInfo getAvatarUrl]]];
        
        if (mySPItem.place == oppSPItem.place) {
            [self updateViewWithMode:MNScoreProgressSideBySideModeDraw animated:YES];
        }
        else if (mySPItem.place == 1) {
            [self updateViewWithMode:MNScoreProgressSideBySideModeIFirst animated:YES];
        }
        else if (oppSPItem.place == 1) {
            [self updateViewWithMode:MNScoreProgressSideBySideModeOppFirst animated:YES];
        }
        else {
            [self updateViewWithMode:MNScoreProgressSideBySideModeDraw animated:YES];
        }
        
        //[self scoreProgressShowMeFirst:(mySPItem.place == 1) animated:YES];
    }
    else {
        self.mySPPlaceLabel.text = [self getOrdinalNumber:1];
        self.mySPNameLabel .text = mySPItem.userInfo.userName;
        self.mySPScoreLabel.text = [NSString stringWithFormat:@"%@",[self getSeparatedInteger:mySPItem.score separator:@","]];
        //self.mySPProgressUpImageView  .hidden = YES;
        //self.mySPProgressDownImageView.hidden = YES;
        
        self.oppSPPlaceLabel.text = @"";
        self.oppSPNameLabel .text = @"";
        self.oppSPScoreLabel.text = @"";
        
        [self updateViewWithMode:MNScoreProgressSideBySideModeIFirst animated:YES];
        //[self scoreProgressShowMeFirst:YES animated:YES];
    }
    
    [mySPItem release];
}

-(void) updateViewWithMode:(NSInteger) mode animated:(BOOL) animatedFlag {
    self.mySPBackgroundFirstPlaceImageView  .hidden = YES;
    self.mySPBackgroundDrawPlaceImageView   .hidden = YES;
    self.mySPBackgroundSecondPlaceImageView .hidden = YES;
    self.oppSPBackgroundFirstPlaceImageView .hidden = YES;
    self.oppSPBackgroundDrawPlaceImageView  .hidden = YES;
    self.oppSPBackgroundSecondPlaceImageView.hidden = YES;
    
    if      (mode == MNScoreProgressSideBySideModeIFirst) {
        self.mySPBackgroundFirstPlaceImageView  .hidden = NO;
        self.oppSPBackgroundSecondPlaceImageView.hidden = NO;
    }
    else if (mode == MNScoreProgressSideBySideModeDraw) {
        self.mySPBackgroundDrawPlaceImageView   .hidden = NO;
        self.oppSPBackgroundDrawPlaceImageView  .hidden = NO;
    }
    else if (mode == MNScoreProgressSideBySideModeOppFirst) {
        self.mySPBackgroundSecondPlaceImageView .hidden = NO;
        self.oppSPBackgroundFirstPlaceImageView .hidden = NO;
    }
}

//FIXME: move to tools
static NSString *FMFirstOrdinalPostfix  = @"st";
static NSString *FMSecondOrdinalPostfix = @"nd";
static NSString *FMThirdOrdinalPostfix  = @"rd";
static NSString *FMThOrdinalPostfix     = @"th";

//FIXME: move to tools
-(NSString*) getOrdinalNumber:(NSInteger) intValue
{
    NSString *postfix;
    
    int mod10  = intValue % 10;
    int mod100 = intValue % 100;
    
    if      ((mod10 == 1) && (mod100 != 11)) {
        postfix = FMFirstOrdinalPostfix;
    }
    else if ((mod10 == 2) && (mod100 != 12)) {
        postfix = FMSecondOrdinalPostfix;
    }
    else if ((mod10 == 3) && (mod100 != 13)) {
        postfix = FMThirdOrdinalPostfix;
    }
    else {
        postfix = FMThOrdinalPostfix;
    }
    
    return [NSString stringWithFormat:@"%d%@",intValue,postfix];
}

//FIXME: move to tools
-(NSString*) getSeparatedInteger:(long long) intValue separator:(NSString*) separator {
    NSString *resultStr;
    long long hiValue;
    long long lowValue;
    BOOL      negativeFlag;
    
    negativeFlag = NO;
    
    if (intValue < 0) {
        negativeFlag = YES;
        intValue = -intValue;
    }
    
    hiValue   = intValue / 1000;
    lowValue  = intValue % 1000;
    resultStr = @"";
    
    while (hiValue != 0) {
        resultStr = [NSString stringWithFormat:@"%@%03d%@",separator,lowValue,resultStr];
        
        intValue = intValue / 1000;
        hiValue  = intValue / 1000;
        lowValue = intValue % 1000;
    }
    
    resultStr = [NSString stringWithFormat:@"%d%@",lowValue,resultStr];
    
    if (negativeFlag) {
        resultStr = [NSString stringWithFormat:@"-%@",resultStr];
    }
    
    return resultStr;
}

@end
