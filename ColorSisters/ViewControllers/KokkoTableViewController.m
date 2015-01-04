//
//  KokkoTableViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoTableViewController.h"
#import "KokkoData.h"
#import "KokkoShareViewController.h"

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.detailItem allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[[self.detailItem allKeys] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]] objectAtIndex:indexPath.row];
    
    return cell;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showDetail"]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        NSString *brand = cell.textLabel.text;
        [[segue destinationViewController] setDetailItem:@{brand: self.detailItem[brand]}];
    }
}


#pragma mark - Actions

- (void)tapShare:(id)sender
{
    KokkoShareViewController *svc = [[KokkoShareViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

@end
