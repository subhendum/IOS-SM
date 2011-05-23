//
//  ProductsTabViewController.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductsTabViewController.h"
#import "ProductCategoriesViewController.h"
#import "TabBarTrialAppDelegate.h"

@implementation ProductsTabViewController
@synthesize listOfProductCategories, selectedProductCategory;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
//	[self.window addSubview:productsNavigationController.view];
//	[self.window makeKeyAndVisible];
	
	listOfProductCategories = [[NSArray alloc] initWithObjects:@"Wines",@"Spirits",@"Chairman's Selection",@"Collector's Corner",nil];
	
	

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listOfProductCategories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [listOfProductCategories objectAtIndex:indexPath.row];
	
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Getting the selected text from the table view
	selectedProductCategory = [NSString stringWithFormat:@"%@",[listOfProductCategories objectAtIndex:indexPath.row]];
	NSLog(@"Selected Item : %@",selectedProductCategory);
	
	TabBarTrialAppDelegate *appDelegate = (TabBarTrialAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.selectedProdutcType = selectedProductCategory;
	
//	if ([selectedProductCategory isEqualToString:@"Wines"])
//	{
		
	ProductCategoriesViewController *categoriesViewController = [[ProductCategoriesViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.navigationController pushViewController:categoriesViewController animated:YES];
		
//	}
	
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

