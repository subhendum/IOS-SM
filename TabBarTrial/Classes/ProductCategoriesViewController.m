//
//  ProductCategoriesViewController.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductCategoriesViewController.h"
#import "TabBarTrialAppDelegate.h"

@implementation ProductCategoriesViewController
@synthesize categories;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	TabBarTrialAppDelegate *appDelegate = (TabBarTrialAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	if ([appDelegate.selectedProdutcType isEqualToString:@"Wines"])
	{
		categories = [[NSArray alloc] initWithObjects:@"Red",@"White",@"Sparkling",@"Fortified/Dessert",@"Fruit/Beverages",@"Kosher",@"Organic",@"Rose",@"Sake",@"Vermount",nil];	
	}
	else if ([appDelegate.selectedProdutcType isEqualToString:@"Spirits"])
	{
		categories = [[NSArray alloc] initWithObjects:@"Brandy",@"Cognac",@"Cordials",@"Gin",@"Rum",@"Blended Scotch",@"Single Malt Scotch",@"Tequila",@"Vodka",@"Whiskey",@"Other Spirits",nil];		
	}
	else if ([appDelegate.selectedProdutcType isEqualToString:@"Red"])
	{
		categories = [[NSArray alloc] initWithObjects:@"Pinot Noir",@"Proprietary Red Blend",@"Siagioverse",@"Other Red Vareitals",@"Nebbiolo",@"Brunello",@"Malbec",@"Merlot",@"Syrah",nil];		
	}
	
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [categories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [categories objectAtIndex:indexPath.row];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	TabBarTrialAppDelegate *appDelegate = (TabBarTrialAppDelegate *) [[UIApplication sharedApplication] delegate];
	appDelegate.selectedProdutcType = [categories objectAtIndex:indexPath.row];
	NSLog(@"Selected Item : %@", appDelegate.selectedProdutcType);
	ProductCategoriesViewController *categoriesViewController = [[ProductCategoriesViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.navigationController pushViewController:categoriesViewController animated:YES];
	self.navigationController.navigationItem.title = appDelegate.selectedProdutcType;

    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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

