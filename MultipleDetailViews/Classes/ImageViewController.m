//
//  ImageViewController.m
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"
#import "GDFileViewController.h"

@implementation ImageViewController
@synthesize files, imageNavController, imageTableView;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *appDocumentsDirectory = [rootPath stringByAppendingPathComponent:@"DocsImages"];	
	
	NSError *error;
	
	NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appDocumentsDirectory error:&error];
	
	if (folderContents == nil) {
		NSLog(@"%@ does not exist",appDocumentsDirectory);
	}
	else if ([folderContents count] == 0) {
		NSLog(@"%@ is empty",appDocumentsDirectory);
	}
	else {
		NSLog(@" %@ contains %i documents",appDocumentsDirectory, [folderContents count]);
		
		self.files = [[NSMutableArray alloc] initWithCapacity:[folderContents count]];
		
		for (NSString *name in folderContents) {
			[self.files addObject:name];
		}
	}	
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
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
    return [self.files count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	// Getting the Documents folder path
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *rootPathWithFolder = [rootPath stringByAppendingPathComponent:@"DocsImages"];
	
	
	cell.textLabel.text = [self.files objectAtIndex:indexPath.row];
	cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:[rootPathWithFolder stringByAppendingPathComponent:cell.textLabel.text]];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

	NSString *selectedFile = [self.files objectAtIndex:indexPath.row];
	NSLog(@"Loading file %@ ",selectedFile);
	
	GDFileViewController *detailViewController = [[GDFileViewController alloc] initWithNibName:@"GDFileViewController" bundle:nil];
	detailViewController.selectedFile = selectedFile;
	detailViewController.source = @"ImageView";
	
	// Pass the selected object to the new view controller.
	[self.imageNavController pushViewController:detailViewController animated:YES];
	[detailViewController release];		
	
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
    [files release];
	[super dealloc];
	
}


@end

