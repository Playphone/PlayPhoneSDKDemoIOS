//
//  PPSExBasicViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 06.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PPSExCommon.h"

#import "PPSExBasicViewController.h"

#pragma mark -

@implementation PPSExBasicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (YES);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateState];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sections = [self.sectionNames count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.sectionRows count] > section) {
        NSArray *rows = [self.sectionRows objectAtIndex:section];
        
        if (rows != nil) {
            return [rows count];
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)showFooterLabelWithText:(NSString*)labelText {
    UILabel *footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 21)];
    footerLabel.text = labelText;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textAlignment   = UITextAlignmentCenter;
    
    ((UITableView*)self.view).tableFooterView = footerLabel;
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
