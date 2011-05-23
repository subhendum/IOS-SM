//
//  clsCaseContacts.m
//  iFACES
//
//  Created by Hardik Zaveri on 11/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsCaseContacts.h"
#import "iFACESAppDelegate.h"
#import "sqlite3.h"
#import "clsContacts.h"

@implementation clsCaseContacts
@synthesize tableView;
@synthesize contacts;

@synthesize objCICNPageController;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		[self getContacts];
	}
	return self;
}




- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//[self getContacts];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];

	clsContacts *objContacts;
	objContacts = [contacts objectAtIndex:indexPath.row];

	appDelegate.iContactEntityID = objContacts.iContactEntityID;
	appDelegate.iContactID = objContacts.iContactID;
	appDelegate.sContactName = objContacts.sContactName;

	//[objContacts release];
	
	//if(objCICNPageController == nil)
	objCICNPageController = [[clsCICNPageController alloc] initWithNibName:@"nCICNPageController" bundle:nil]; 
	[appDelegate.navigationController pushViewController:objCICNPageController animated:YES];
    return nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
	
	//[tableView reloadData]; 
}




/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


 /*If you need to do additional setup after loading the view, override viewDidLoad.*/
- (void)viewDidLoad 
{
    self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebar_hands_big.jpg"]];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = backgroundImage;
    
}
 



- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellAccessoryDetailDisclosureButton;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *identity = @"MainCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
    }
	cell.textLabel.font = [UIFont boldSystemFontOfSize:17.5]; 
    
    clsContacts *objContacts = [contacts objectAtIndex:indexPath.row];
    
	
	UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(72.0, 25.0,70.0, 18.0)];
	lblTemp.font = [UIFont boldSystemFontOfSize:11.00];
	lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.textAlignment = UITextAlignmentLeft;
	
	lblTemp.text = @"";
	lblTemp.text = objContacts.sContactEntityType;
    lblTemp.backgroundColor = [UIColor clearColor];
    lblTemp.textColor = [UIColor blackColor];    
	
//	[cell addSubview:lblTemp];
//	[cell sendSubviewToBack:NO];
  
    cell.detailTextLabel.text = lblTemp.text;
    cell.detailTextLabel.textColor = [UIColor whiteColor];
	lblTemp = nil;
	[lblTemp release];
	
	
	
	
	lblTemp =  [[UILabel alloc] initWithFrame:CGRectMake(65.0, 5.0,240.0, 20.0)];
	lblTemp.font = [UIFont boldSystemFontOfSize:17.5]; 
	lblTemp.text = [objContacts.sContactName stringByAppendingString:@"\t"];
	lblTemp.text = [lblTemp.text stringByAppendingString:[NSString stringWithFormat:@"(%.0f)", objContacts.iContactID]];
	lblTemp.textAlignment = UITextAlignmentLeft;
    lblTemp.backgroundColor = [UIColor clearColor];
    lblTemp.textColor = [UIColor whiteColor];
// 	[cell addSubview:lblTemp];
//	[cell sendSubviewToBack:NO];
    cell.textLabel.text = lblTemp.text;
    cell.textLabel.textColor = [UIColor whiteColor];
	lblTemp = nil;
	[lblTemp release];
	
	//UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 1.0,100.0, 80.0)];
    UIImageView *tmpImageView = [[UIImageView alloc] init];
	UIImage *tmpImg = nil;
    if(objContacts.tmpImage == nil)
	{	
        tmpImg = [self getImageforContact:objContacts.iContactEntityID];
        if (tmpImg == nil)
        {
            tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"imgPhotoPlace" ofType:@"png"]];
        }
		[tmpImageView setImage:tmpImg];
		tmpImg = nil;
		[tmpImg release];
	}
	else
		[tmpImageView setImage:objContacts.tmpImage];
	//[cell addSubview:tmpImageView];
    [[cell imageView] setImage:tmpImageView.image];
	tmpImageView = nil;
	[tmpImageView release];
	objContacts = nil;
	[objContacts release];    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
	return cell;
}



-(UIImage *)getImageforContact:(double)iEntityId {
    
    NSLog(@"iEntityId : %f",iEntityId);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];    
    UIImage *contactImage = nil; 
    const char *sql = "select media_blob from tblEntity_Media where iEntityID=? and Media_type=2";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
    {
        sqlite3_bind_int(statement, 1, iEntityId);
        if(sqlite3_step(statement) == SQLITE_ROW) 
        {
            contactImage = [[[UIImage alloc] initWithData:[NSData dataWithBytes:sqlite3_column_blob(statement, 0) length:sqlite3_column_bytes(statement, 0)]] retain];
        }
    }
    // "Finalize" the statement - releases the resources associated with the statement.
    sqlite3_finalize(statement);
    sql = nil;  
    
//    [paths  release];
//    [documentsDirectory release];
//    [path release];
    
    return contactImage;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	
	// Release anything that's not essential, such as cached data
	[tableView release];
	[contacts release];
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}

-(void) getContacts
{
	NSMutableArray *contactArray = [[NSMutableArray alloc] init];
	self.contacts = contactArray;
	contactArray = nil;
	[contactArray release];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
    
    NSLog(@"iEntity ID - %f",appDelegate.iEntityID);
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
	{
//		const char *sql = "Select entityID, contactName, iContactEntityID, ContactEntityType, media_blob from vGetContacts where iEntityID = ?"; 
        const char *sql = "Select entityID, contactName, iContactEntityID, ContactEntityType, media_blob from vAllContacts where iEntityID = ?"; 
		sqlite3_stmt *statement;      
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
		{
			sqlite3_bind_int(statement, 1, appDelegate.iEntityID);		
            
			while(sqlite3_step(statement) == SQLITE_ROW) 
			{
				clsContacts *objContacts = [clsContacts alloc];
				objContacts.iContactID = sqlite3_column_double(statement, 0);
				objContacts.sContactName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				objContacts.iContactEntityID = sqlite3_column_double(statement, 2);
				objContacts.sContactEntityType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				objContacts.tmpImage = [[[UIImage alloc] initWithData:[NSData dataWithBytes:sqlite3_column_blob(statement, 4) length:sqlite3_column_bytes(statement, 4)]] retain];
				[contacts addObject:objContacts];
				objContacts = nil;
				[objContacts release];
			}
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
		sql = nil;
		statement = nil;
	} 
	else 
	{
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		// Additional error handling, as appropriate...
	}
	paths = nil;
	path = nil;
	documentsDirectory = nil;
}

- (void)dealloc {
	
	[tableView release];
	[contacts release];
	[super dealloc];
}


@end
