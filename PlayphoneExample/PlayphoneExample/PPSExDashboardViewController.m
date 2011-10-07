//
//  PPSExDashboardViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirectButton.h"
#import "MNDirectUIHelper.h"

#import "PPSExDashboardViewController.h"

@implementation PPSExDashboardViewController

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)doShowLauncherIcon:(id)sender {
    [MNDirectButton show];
}

- (IBAction)doHideLauncherIcon:(id)sender {
    [MNDirectButton hide];
}

- (IBAction)doShowDashboard:(id)sender {
    [MNDirectUIHelper showDashboard];
}

- (void)dealloc {
    [super dealloc];
}
@end
