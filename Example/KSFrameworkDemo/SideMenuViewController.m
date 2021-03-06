//
//  SideMenuViewController.m
//  KSFrameworkDemo
//
//  This file is part of a fork of MFSideMenu by Michael Frederick.
//
//  Modified by Travis Zehren beginning 9/07/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//    Created by Michael Frederick on 3/19/12.
//

#import "SideMenuViewController.h"
#import "KSSlideController.h"
#import "DemoSlideViewController.h"

@implementation SideMenuViewController

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section %ld", (long)section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext" size:21];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Item %ld", (long)indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    UINavigationController *navigationController = self.slideController.centerViewController;

    ((UIViewController *)navigationController.viewControllers.lastObject).title = [NSString stringWithFormat:@"Demo #%ld-%ld", (long)indexPath.section, (long)indexPath.row];

    [self.slideController setSlideControllerState:KSSlideControllerStateClosed];
}

@end
