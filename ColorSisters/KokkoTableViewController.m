//
//  KokkoTableViewController.m
//  ColorSisters
//
//  Copyright (c) 2014 Kokko, Inc. All rights reserved.
//

#import "KokkoTableViewController.h"
#import "KokkoDetailedMatchViewController.h"

@interface KokkoTableViewController ()

@end

@implementation KokkoTableViewController

NSString *detailControllerName = @"showDetail";  // TODO:  might be a better way to reference the detail view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleMatchesArray = @[@"Dior",
                               @"L'Oreal",
                               @"M.A.C",
                               @"Maybelline",
                               @"Revlon",
                               ];
    
    
    self.imageMatchesArray = @[@"product_images.bundle/Dior/100.png",
                               @"product_images.bundle/L'Oreal/C1.png",
                               @"product_images.bundle/MAC/C3.5.png",
                               @"product_images.bundle/Maybelline/D2.png",
                               @"product_images.bundle/Revlon/110.png",
                               ];
    
    // Do any additional setup after loading the view,
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:nil];
//    self.navigationItem.leftBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.titleMatchesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.titleMatchesArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"";
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableViewImage = [UIImage imageNamed:[self.imageMatchesArray objectAtIndex:indexPath.row]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqual:detailControllerName]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *object = self.imageMatchesArray[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}


@end
