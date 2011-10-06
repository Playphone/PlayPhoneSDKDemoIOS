//
//  MNABImportDialogView.m
//  MultiNet client
//
//  Created by Vlad Ogol on 09.06.09.
//  Copyright 2009 PlayPhone. All rights reserved.
//

#import "MNABImportCellView.h"
#import "MNABImportTableViewDataSource.h"

#import "MNABImportDialogView.h"

#define CONTACT_IMPORT_DIALOG_INSET_X      (10.0f)
#define CONTACT_IMPORT_DIALOG_INSET_Y      (10.0f)
#define CONTACT_IMPORT_DIALOG_BORDER_WIDTH (10.0f)
#define CONTACT_IMPORT_TOOLBAR_DEF_HEIGHT  (44.0f)

static float MNABImportDialogBorderColor[] = { 0.3f, 0.3f, 0.3f, 0.8f };

//---------------------------------------------------------------------------

@interface MNABImportDialogView()

-(void)       importButton_tap    : (id)              sender;
-(void)       cancelButton_tap    : (id)              sender;
-(void)       selectAllButton_tap : (id)              sender;

-(void)       dismissAnimationDidStop: (NSString*)         animationID
                             finished: (NSNumber*)         finished
                              context: (void*)             context;

-(void)       dismiss;

@end

//---------------------------------------------------------------------------

@implementation MNABImportDialogView

@synthesize contactImportDelegate;

-(id)         initWithFrame       : (CGRect)          frame
 {
  if ((CGRectIsEmpty(frame)) || (CGRectIsInfinite(frame)))
   {
    frame = [UIScreen mainScreen].bounds;
   }

  if (self = [super initWithFrame:frame])
   {
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizesSubviews = YES;
    self.contentMode = UIViewContentModeRedraw;

    CGRect dialogFrame = CGRectInset(self.bounds,
                                     CONTACT_IMPORT_DIALOG_INSET_X + CONTACT_IMPORT_DIALOG_BORDER_WIDTH,
                                     CONTACT_IMPORT_DIALOG_INSET_Y + CONTACT_IMPORT_DIALOG_BORDER_WIDTH);

    dialogSubView = [[UIView alloc] initWithFrame: dialogFrame];
    dialogSubView.backgroundColor = [UIColor whiteColor];
    dialogSubView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dialogSubView.autoresizesSubviews = YES;
    dialogSubView.contentMode = UIViewContentModeRedraw;

    [self addSubview: dialogSubView];

    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake
               (0,
                dialogSubView.bounds.size.height - CONTACT_IMPORT_TOOLBAR_DEF_HEIGHT,
                dialogSubView.bounds.size.width,
                CONTACT_IMPORT_TOOLBAR_DEF_HEIGHT)];

    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolbar.autoresizesSubviews = YES;

    [dialogSubView addSubview:toolbar];

    importButton    = [[UIBarButtonItem alloc]initWithTitle:@"Import"     style:UIBarButtonItemStyleDone     target:self action:@selector(importButton_tap:   )];
    cancelButton    = [[UIBarButtonItem alloc]initWithTitle:@"Cancel"     style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButton_tap:   )];
    selectAllButton = [[UIBarButtonItem alloc]initWithTitle:@"Select All" style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllButton_tap:)];

    [toolbar setItems:[NSArray arrayWithObjects:
                       importButton,
                       cancelButton,
                       [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]autorelease],
                       selectAllButton,
                       nil]
             animated:YES];

    tableView = [[UITableView alloc]initWithFrame:CGRectMake
                 (0,
                  0,
                  dialogSubView.bounds.size.width,
                  dialogSubView.bounds.size.height - CONTACT_IMPORT_TOOLBAR_DEF_HEIGHT)
                                            style: UITableViewStylePlain];



    tableView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.autoresizesSubviews = YES;

    contactsTableDS = [[MNABImportTableViewDataSource alloc]init];

    tableView.dataSource = contactsTableDS;

    [dialogSubView addSubview:tableView];
   }

  return self;
 }

-(void)       drawRect            : (CGRect)          rect
 {
  CGContextRef ctx = UIGraphicsGetCurrentContext();

  CGRect borderOutRect = CGRectInset(self.bounds,CONTACT_IMPORT_DIALOG_INSET_X,CONTACT_IMPORT_DIALOG_INSET_Y);
  CGRect borderInRect  = CGRectInset(borderOutRect,CONTACT_IMPORT_DIALOG_BORDER_WIDTH,CONTACT_IMPORT_DIALOG_BORDER_WIDTH);

  float x1 = borderOutRect.origin.x;
  float x2 = borderInRect.origin.x;
  float x3 = borderInRect.origin.x + borderInRect.size.width;
  float x4 = borderOutRect.origin.x + borderOutRect.size.width;
  float y1 = borderOutRect.origin.y;
  float y2 = borderInRect.origin.y;
  float y3 = borderInRect.origin.y + borderInRect.size.height;
  float y4 = borderOutRect.origin.y + borderOutRect.size.height;

  CGContextBeginPath(ctx);

  CGContextMoveToPoint(ctx,x2,y1);
  CGContextAddArcToPoint(ctx,x4,y1,x4,y2,CONTACT_IMPORT_DIALOG_BORDER_WIDTH);
  CGContextAddArcToPoint(ctx,x4,y4,x3,y4,CONTACT_IMPORT_DIALOG_BORDER_WIDTH);
  CGContextAddArcToPoint(ctx,x1,y4,x1,y3,CONTACT_IMPORT_DIALOG_BORDER_WIDTH);
  CGContextAddArcToPoint(ctx,x1,y1,x2,y1,CONTACT_IMPORT_DIALOG_BORDER_WIDTH);
  CGContextClosePath(ctx);
  CGContextAddRect(ctx,borderInRect);

  CGContextSetRGBFillColor(ctx,
                           MNABImportDialogBorderColor[0],MNABImportDialogBorderColor[1],
                           MNABImportDialogBorderColor[2],MNABImportDialogBorderColor[3]);

  CGContextEOFillPath(ctx);

  [super drawRect: rect];
 }

-(void)       dealloc
 {
  [contactsTableDS release];

  [importButton    release];
  [cancelButton    release];
  [selectAllButton release];
  [toolbar         release];
  [tableView       release];
  [dialogSubView   release];

  [super dealloc];
 }

-(void)       showOnTop
 {
  CGRect windowBounds = [UIScreen mainScreen].applicationFrame;

  self.frame = windowBounds;

  UIWindow* window =  [[UIApplication sharedApplication] keyWindow];

  if (window == nil)
   {
    window = [[UIApplication sharedApplication].windows objectAtIndex: 0];
   }

  self.transform = CGAffineTransformMakeScale(0.1, 0.1);

  [window addSubview: self];

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.35];

  self.transform = CGAffineTransformMakeScale(1,1);

  [UIView commitAnimations];
 }

-(void)       dismiss
 {

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.35];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];

  self.transform = CGAffineTransformMakeScale(0.1,0.1);

  [UIView commitAnimations];
 }

-(void)       dismissAnimationDidStop: (NSString*)         animationID
                             finished: (NSNumber*)         finished
                              context: (void*)             context
 {
  [self removeFromSuperview];
  [self autorelease];
 }

-(void)       importButton_tap    : (id)              sender
 {
  NSMutableArray     *contactArray = [NSMutableArray arrayWithCapacity:[tableView numberOfRowsInSection:0]];
  MNABImportCellView *cell;
  MNABContactInfo    *contactInfo;

  NSIndexPath *baseIndexPath = [NSIndexPath indexPathWithIndex:0];

  for (unsigned int index = 0; index < [tableView numberOfRowsInSection:0]; index++)
   {
    cell = (MNABImportCellView*)[tableView cellForRowAtIndexPath:[baseIndexPath indexPathByAddingIndex:index]];

    if (cell.checkedFlag)
     {
      contactInfo = [[MNABContactInfo alloc]init];

      contactInfo.contactName = cell.userName;
      contactInfo.email       = cell.userEmail;
      contactInfo.avatar      = cell.userAvatarImage;

      [contactArray addObject:contactInfo];
      [contactInfo release];
     }
   }

  if (contactImportDelegate != nil)
   {
    if ([contactArray count] == 0)
     {
      [contactImportDelegate contactImportInfoReady: nil];
     }
    else
     {
      [contactImportDelegate contactImportInfoReady: contactArray];
     }
   }

  [self dismiss];
 }

-(void)       cancelButton_tap    : (id)              sender
 {
  if (contactImportDelegate != nil)
   {
    [contactImportDelegate contactImportInfoReady: nil];
   }

  [self dismiss];
 }

-(void)       selectAllButton_tap : (id)              sender
 {
  MNABImportCellView *cell;
  NSIndexPath *baseIndexPath = [NSIndexPath indexPathWithIndex:0];

  for (unsigned int index = 0; index < [tableView numberOfRowsInSection:0]; index++)
   {
    cell = (MNABImportCellView*)[tableView cellForRowAtIndexPath:[baseIndexPath indexPathByAddingIndex:index]];

    cell.checkedFlag = YES;
   }
 }


@end
