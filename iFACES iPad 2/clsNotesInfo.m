//
//  clsNotesInfo.m
//  iFACES
//
//  Created by Hardik Zaveri on 03/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "iFACESAppDelegate.h";
#import "clsNotesInfo.h"
#import "MapViewController.h"

@implementation clsNotesInfo

@synthesize tableView;
@synthesize sTitle;
@synthesize sAddDate;
@synthesize sUpdateDate;
@synthesize sLatitude;
@synthesize sLongitude;
@synthesize sTags;
@synthesize objMaps;
@synthesize sTagsTmp;
 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			sqlite3_stmt *statement; 
			const char *sql;
			if(appDelegate.iMediaType == 3)
			{
				
				sql = "Select coalesce(title, ' '), coalesce(addDate, ' '), coalesce(updateDate, ' '), coalesce(latitude, ' '), coalesce(longitude, ' '), coalesce(notes_tags, ' ') from tblNotes where iNotesID = ?";   
				if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
				{
					sqlite3_bind_int(statement, 1, appDelegate.iMediaID);
					if(sqlite3_step(statement)  == SQLITE_ROW) 
					{
						self.sTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
						self.sAddDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
						self.sUpdateDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
						self.sLatitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
						self.sLongitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
						self.sTags = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
						self.sTagsTmp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
					}
				}
				// "Finalize" the statement - releases the resources associated with the statement.
				sqlite3_finalize(statement);
			}
			else
			{
				sql = "Select coalesce(title, ' '), coalesce(addDate, ' '), coalesce(updateDate, ' '), coalesce(latitude, ' '), coalesce(longitude, ' '), coalesce(media_tags, ' ') from tblEntity_Media where imediaId = ?";
				if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
				{
					sqlite3_bind_int(statement, 1, appDelegate.iMediaID);
					if(sqlite3_step(statement)  == SQLITE_ROW) 
					{
						self.sTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
						self.sAddDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
						self.sUpdateDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
						self.sLatitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
						self.sLongitude = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
						self.sTags = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
						self.sTagsTmp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
					}
				}
				// "Finalize" the statement - releases the resources associated with the statement.
				sqlite3_finalize(statement);
			}
		}
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
	}

	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Information will appear");
}

/*If you need to do additional setup after loading the view, override viewDidLoad.*/
- (void)viewDidLoad 
{
    self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    self.tableView.backgroundView = backgroundImage;
}
 
/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveAction:)];

	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.tabBarController.navigationItem.rightBarButtonItem = saveItem;

	[saveItem release];
}*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
    return 2;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	if(indexPath.section == 1 && indexPath.row == 2)
	{
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString *tmp = @"&q=";
		tmp = [tmp stringByAppendingString:sLatitude];
		tmp = [tmp stringByAppendingString:@","];
		tmp = [tmp stringByAppendingString:sLongitude];
		appDelegate.sMapQuery = tmp;
		//tmp = nil;
		//if(objMaps == nil)
		//	objMaps = [[clsMaps alloc] initWithNibName:@"nMaps" bundle:nil];
		//[appDelegate.navigationController pushViewController:objMaps animated:YES];
		tmp = [@"http://maps.google.com/maps?&z=16&iwloc=A" stringByAppendingString:tmp];
        MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        mapView.url = tmp;
        
        [appDelegate.navigationController pushViewController:mapView animated:YES];          
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmp]];
		tmp = nil;
		//[tmp release];
	}
    return nil;
}
- (CGFloat) tableView: (UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.0f;
}
- (CGFloat) tableView: (UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40.0f;
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
//{
//	if((indexPath.section == 1 && indexPath.row == 2))
//		return UITableViewCellAccessoryDisclosureIndicator;
//	else
//		return UITableViewCellAccessoryNone;
//}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.
    if(section == 0)
	{
		
        return [@"Title: " stringByAppendingString:sTitle];
	}
	else
		return nil;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	return 3;
}	

-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	if(indexPath.section == 0 && indexPath.row == 2)
	{
		return 85.0;
	}
	else if(indexPath.section == 1 && indexPath.row == 2)
		return 50.0;
	else
		return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
    }
	
	cell.textLabel.text = @"";
	
	switch (indexPath.section) 
	{
		case 0:
		{
			if(indexPath.row == 0)
            {
				cell.textLabel.text = [@"Created: " stringByAppendingString:sAddDate];
                cell.textLabel.textColor = [UIColor whiteColor];
            }
			else if(indexPath.row == 1)
            {
				cell.textLabel.text = [@"Updated: " stringByAppendingString:sUpdateDate];
                cell.textLabel.textColor = [UIColor whiteColor];                
            }
			else if(indexPath.row == 2)
			{
				cell.textLabel.text = @"Tags: ";
                cell.textLabel.textColor = [UIColor whiteColor];
				UILabel *lblTags = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 0.0, 200, 80)];
				lblTags.numberOfLines = 3;
				lblTags.text = sTags;
               lblTags.textColor = [UIColor whiteColor];
				lblTags.font = [UIFont boldSystemFontOfSize:17.5];
                lblTags.backgroundColor = [UIColor clearColor];
				[cell.contentView addSubview:lblTags];
				[lblTags release];
				//cell.textLabel.text = [@"Tags: " stringByAppendingString:sTags];
 			}
			break;
		}
		case 1:
		{
			if(indexPath.row == 0)
            {
                cell.textLabel.text = [@"Longitude: " stringByAppendingString:sLongitude];
                cell.textLabel.textColor = [UIColor whiteColor];   
            }
			else if(indexPath.row == 1)
            {
				cell.textLabel.text = [@"Latitude: " stringByAppendingString:sLatitude];
               cell.textLabel.textColor = [UIColor whiteColor];            
            }
			else
			{
				cell.textLabel.text = @"View On Map";
            cell.textLabel.textColor = [UIColor whiteColor];                
				UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"maps" ofType:@"png"]];
				UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(650.0, 3.0,40.0, 40.0)];
				[tmpImageView setImage:tmpImg];
				//[cell addSubview:tmpImageView];
                [[cell imageView] setImage:tmpImg];
				[tmpImageView release];
				[tmpImg release];
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			}
			break;
		}
	}
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(43, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHue:(136.0/360.0)  // Slightly bluish green
                                 saturation:1.0
                                 brightness:0.95
                                      alpha:1.0];
    //  label.shadowColor = [UIColor whiteColor];
    //  label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40.0f)];
    [view autorelease];
    [view addSubview:label];
    
    return view;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

/*- (void)saveAction:(id)sender
{	
	[txtTitle resignFirstResponder];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.tabBarController.navigationItem.rightBarButtonItem = nil;
}*/

@end
