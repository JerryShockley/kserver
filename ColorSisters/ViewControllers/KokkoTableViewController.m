//
//  KokkoTableViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoTableViewController.h"
#import "KokkoData.h"
#import "KokkoShareViewController.h"
#import "KokkoDetailPageControlViewController.h"

@interface KokkoTableViewController ()

@end


@implementation KokkoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(tapShare:)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.detailItem allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    cell.textLabel.text = [[[self.detailItem allKeys] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Figure out what was tapped
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *brand = cell.textLabel.text;
    
    // Create the detail view
    KokkoDetailPageControlViewController *dvc = [[KokkoDetailPageControlViewController alloc] init];
    dvc.detailItem = @{brand: self.detailItem[brand]};
    
    // Present the detail view
    [self.navigationController pushViewController:dvc animated:YES];
}


#pragma mark - Actions

- (void)tapShare:(id)sender
{
    KokkoShareViewController *svc = [[KokkoShareViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

@end
