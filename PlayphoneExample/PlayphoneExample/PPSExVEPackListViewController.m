//
//  PPSExVEPackListViewController.m
//  PlayphoneExample
//
//  Created by Vladislav Ogol on 08.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNDirect.h"
#import "MNVShopProvider.h"

#import "PPSExCommon.h"
#import "PPSExVEPackInfoViewController.h"
#import "PPSExVEPackListViewController.h"

static NSString *PPSExVECategoriesScreenSectionNames[] = 
{
    @"",
};

@interface PPSExVEPackListViewController()
- (void)updateView;
@end

@implementation PPSExVEPackListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSArray *sectionNamesArray = [NSArray arrayWithObjects:PPSExVECategoriesScreenSectionNames
                                                     count:DeclaredArraySize(PPSExVECategoriesScreenSectionNames)];
    
    NSArray *sectionRowsArray  = [NSArray arrayWithObjects:nil];
    
    self.sectionNames = sectionNamesArray;
    self.sectionRows  = sectionRowsArray;
    
    [super viewDidLoad];
    self.cellStyle = UITableViewCellStyleValue1;
}

-(void) onVShopInfoUpdated {
    [self updateView];    
}

- (void)updateState  {
    if ([[MNDirect vShopProvider]isVShopInfoNeedUpdate]) {
        [[MNDirect vShopProvider]doVShopInfoUpdate];
    }
    else {
        [self updateView];
    }
}

- (void)updateView {
    NSArray *packList = [[MNDirect vShopProvider]getVShopPackList];
    
    NSMutableArray *tableViewRows = [NSMutableArray arrayWithCapacity:[packList count]];
    
    PPSExMainScreenRowTypeObject *rowObject = nil;
    
    for (MNVShopPackInfo *packInfo in packList) {                             
        rowObject = [[PPSExMainScreenRowTypeObject alloc]initWithTitle:packInfo.name 
                                                              subTitle:MNVShopPackGetPriceString(packInfo)];
        rowObject.viewControllerName = @"PPSExVEPackInfoViewController";
        rowObject.nibName = @"PPSExVEPackInfoView";

        [tableViewRows addObject:rowObject];
        
        [rowObject release];
        rowObject = nil;
    }
    
    self.sectionRows = [NSArray arrayWithObjects:tableViewRows,nil];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSArray *packList = [[MNDirect vShopProvider]getVShopPackList];

    NSString *itemName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    MNVShopPackInfo *selectedItem = nil;
    
    for (MNVShopPackInfo *packInfo in packList) {
        if ([packInfo.name isEqualToString:itemName]) {
            selectedItem = packInfo;
            break;
        }
    }
    
    ((PPSExVEPackInfoViewController*)self.navigationController.topViewController).packInfo = selectedItem;
}

@end
