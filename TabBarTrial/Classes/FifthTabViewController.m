//
//  FifthTabViewController.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FifthTabViewController.h"
#import "TabBarTrialAppDelegate.h"

@implementation FifthTabViewController


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	NSLog(@"More viewDidAppear");
	
	//TabBarTrialAppDelegate *appDelegate = (TabBarTrialAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//appDelegate.backController = [[BackViewController alloc] init];
//	UIImage *backImage = [UIImage imageNamed:@"refresh.png"];
//	UITabBarItem *backItem = [[UITabBarItem alloc] initWithTitle:@"..Back" image:backImage tag:0];
//	appDelegate.backController.tabBarItem = backItem;
//	
//	appDelegate.tab6Controller = [[SixthTabViewController alloc] init];
//	UIImage *sixthImage = [UIImage imageNamed:@"trophy.png"];
//	UITabBarItem *sixthItem = [[UITabBarItem alloc] initWithTitle:@"Contact Us" image:sixthImage tag:1];
//	appDelegate.tab6Controller.tabBarItem = sixthItem;
//	
//	appDelegate.tab7Controller = [[SeventhTabViewController alloc] init];
//	UIImage *seventhImage = [UIImage imageNamed:@"refresh.png"];
//	UITabBarItem *seventhItem = [[UITabBarItem alloc] initWithTitle:@"Cart" image:seventhImage tag:2];
//	appDelegate.tab7Controller.tabBarItem = seventhItem;
//		
//	//NSArray *controllers = [[NSArray alloc] initWithObjects:tab1Controller,tab2Controller,tab3Controller,tab4Controller,tab5Controller,nil];
//	appDelegate.tabBarController.viewControllers = [[NSArray alloc] initWithObjects:appDelegate.backController,appDelegate.tab6Controller,appDelegate.tab7Controller,nil];	
//	
	
	
	
}

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
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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

