//
//  PPSExBasicViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 06.10.11.
//  Copyright 2011 PlayPhone Inc. All rights reserved.
//

#import "PPSExCommon.h"

#import "PPSExBasicViewController.h"

#define PPSExNavigationPaneHeight            (65)
#define PPSExTextFieldGap                    (10)

#pragma mark -

#define PPSExBasicViewContentDefHeight (410.0)
@interface PPSExBasicViewController() 
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) UITextField             *activeTextField;

- (void)locateActivityIndicatorInCenter;
- (void)adjustOffsetForTextField:(UITextField *)textField;

@end

@implementation PPSExBasicViewController

@synthesize contentMinHeght   = _contentMinHeght;
@synthesize activityIndicator = _activityIndicator;
@synthesize activeTextField   = _activeTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _contentMinHeght = PPSExBasicViewContentDefHeight;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray]autorelease];
    self.activeTextField   = nil;
    
    [self.view addSubview:self.activityIndicator];
}

- (void)viewDidUnload {
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
    self.activeTextField   = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (YES);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)self.view).contentSize = CGSizeMake(self.view.frame.size.width,self.contentMinHeght);
    }
    
    [self updateState];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self locateActivityIndicatorInCenter];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)self.view).contentSize = CGSizeMake(self.view.frame.size.width,self.contentMinHeght);
        
        if (self.activeTextField != nil) {
            [self adjustOffsetForTextField:self.activeTextField];
        }
    }
}

- (void)dealloc {
    [self stopActivityIndicator];
    
    if (_activityIndicator != nil) {
        [_activityIndicator removeFromSuperview];
        [_activityIndicator release];
        
        _activityIndicator = nil;
    }

    self.activeTextField   = nil;

    [super dealloc];
}

- (void)setContentMinHeght:(CGFloat)contentMinHeght {
    _contentMinHeght = contentMinHeght;
    
    if (self.view != nil) {
        if ([self.view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)self.view).contentSize = CGSizeMake(self.view.frame.size.width,self.contentMinHeght);
        }
    }
}

- (void)locateActivityIndicatorInCenter {
    CGPoint windowCenter = [UIApplication sharedApplication].keyWindow.center;
    CGPoint result = [self.view convertPoint:windowCenter fromView:[UIApplication sharedApplication].keyWindow];
    
    if (self.activityIndicator != nil) {
        self.activityIndicator.center = result;
    }
}

- (void)startActivityIndicator {
    [self locateActivityIndicatorInCenter];

    self.view.userInteractionEnabled = NO;
        
    [self.activityIndicator startAnimating];
}
- (void)stopActivityIndicator {
    self.view.userInteractionEnabled = YES;
    
    if (_activityIndicator != nil) {
        [self.activityIndicator stopAnimating];
    }
}

- (void)adjustOffsetForTextField:(UITextField *)textField {
    if (textField == nil) {
        return;
    }
    
    CGRect textFieldRect               = [self.view convertRect:(textField).frame 
                                                       fromView:(textField).superview];
    
    CGFloat keyboardHeight = PPSExGetKeyboardHeight();
    CGAffineTransform curTransform = CGAffineTransformIdentity;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        curTransform = CGAffineTransformMakeRotation(M_PI_2);
    }
    
    CGRect windowRect = CGRectApplyAffineTransform([UIApplication sharedApplication].keyWindow.bounds,curTransform);
    
    CGFloat keyboardTopLineInWindow    = windowRect.size.height - keyboardHeight;
    CGPoint fieldRequiredPointInWindow = CGPointMake(textFieldRect.origin.x,keyboardTopLineInWindow - PPSExTextFieldGap);
    CGPoint fieldRequiredPointInView   = [self.view convertPoint:fieldRequiredPointInWindow fromView:[UIApplication sharedApplication].keyWindow];
    CGFloat offset = textFieldRect.origin.y + textFieldRect.size.height - fieldRequiredPointInView.y;
    
    CGPoint curOffset = ((UIScrollView *)self.view).contentOffset;
    
    if (CGPointEqualToPoint(_oldOffset,CGPointZero)) {
        _oldOffset = curOffset;
    }

    if (offset > 0) {
        [((UIScrollView *)self.view) 
         setContentOffset:CGPointMake(0,(curOffset.y + offset))
         animated:YES];
    }
}

#pragma mark - UITextField delegate

- (IBAction)textFieldEditDidBegin:(id)sender {
    self.activeTextField = sender;
    
    [self adjustOffsetForTextField:(UITextField*)sender];
/*    
    CGRect textFieldRectInWindow = [self.view convertRect:textFieldRect
                                                   toView:[UIApplication sharedApplication].keyWindow];
    
    CGFloat fieldBottomLineInWindow = textFieldRectInWindow.origin.y + textFieldRectInWindow.size.height + PPSExTextFieldGap;
    CGFloat keyboardTopLineInWindow = [UIApplication sharedApplication].keyWindow.frame.origin.y + [UIApplication sharedApplication].keyWindow.frame.size.height - PPSExKeyboardHeight;
    CGFloat offset = fieldBottomLineInWindow-fieldRequiredPosition;
    
    if (fieldBottomLineInWindow > keyboardTopLineInWindow) {
        [((UIScrollView *)self.view) 
         setContentOffset:CGPointMake(0,(offset))
//         setContentOffset:CGPointMake(0,(textFieldRect.origin.y    + 
//                                         textFieldRect.size.height - 
//                                         PPSExKeyboardHeight       +
//                                         PPSExNavigationPaneHeight +
//                                         PPSExTextFieldGap))
         animated:YES];
    }
 */
}
- (IBAction)textFieldEditDidEnd  :(id)sender {
    [((UIScrollView *)self.view) setContentOffset:_oldOffset animated:YES];
    _oldOffset = CGPointZero;
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    //Empty implementation
}
- (void)playerLoggedOut {
    //Empty implementation
}
- (void)updateState  {
    //Empty implementation
}

@end

#pragma mark -

@implementation PPSExBasicTableViewController

@synthesize sectionNames = _sectionNames;
@synthesize sectionRows  = _sectionRows;
@synthesize cellStyle    = _cellStyle;

- (void)dealloc {
    self.sectionNames = nil;
    self.sectionRows  = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (YES);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellStyle = UITableViewCellStyleSubtitle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateState];
}

#pragma mark - UITableViewDataSource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sections = [self.sectionNames count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.sectionRows count] > section) {
        NSArray *rows = [self.sectionRows objectAtIndex:section];
        
        if (rows != nil) {
            return [rows count];
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:self.cellStyle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int sectionIndex = [indexPath indexAtPosition:0];
    int rowIndex     = [indexPath indexAtPosition:1];
    
    NSArray                      *rows = [self.sectionRows objectAtIndex:sectionIndex];
    PPSExMainScreenRowTypeObject *row  = [rows objectAtIndex:rowIndex];
    
    cell.textLabel      .text = row.rowTitle;
    cell.detailTextLabel.text = row.rowSubTitle;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionNames objectAtIndex:section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath indexAtPosition:0];
    int rowIndex     = [indexPath indexAtPosition:1];
    
    NSString *viewControllerName = nil;
    NSString *nibName            = nil;
    
    NSArray                      *rows = [self.sectionRows objectAtIndex:sectionIndex];
    PPSExMainScreenRowTypeObject *row  = [rows objectAtIndex:rowIndex];
    
    viewControllerName = row.viewControllerName;
    nibName            = row.nibName;
    
    if (viewControllerName != nil) {
        PPSExBasicViewController *viewController = [[NSClassFromString(viewControllerName) alloc] initWithNibName:nibName
                                                                                                           bundle:[NSBundle mainBundle]];
        
        if (viewController == nil) {
            NSLog(@"Can not create view controller with name: [%@] and nibName: [%@]",viewControllerName,nibName);
        }
        else {
            viewController.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            
            [self.navigationController pushViewController:viewController animated:YES];
            
            [viewController release];
        }
    }
}
- (void)showFooterLabelWithText:(NSString *)labelText {
    UILabel *footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 21)];
    footerLabel.text = labelText;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textAlignment   = UITextAlignmentCenter;
    
    ((UITableView *)self.view).tableFooterView = footerLabel;
    [footerLabel release];
}

#pragma mark - PPSExBasicNotificationProtocol

- (void)playerLoggedIn {
    //Empty implementation
}
- (void)playerLoggedOut {
    //Empty implementation
}
- (void)updateState  {
    //Empty implementation
}

@end
