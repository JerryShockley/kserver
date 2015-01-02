//
//  KokkoTableViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoTableViewController.h"
#import "KokkoData.h"

@interface KokkoTableViewController ()

@end


@implementation KokkoTableViewController


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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSString *brand = cell.textLabel.text;
    
    [[segue destinationViewController] setDetailItem:[[[KokkoData alloc] init] setRecommendationsForBrand:brand withMatches:self.detailItem[brand]]];
}


@end
