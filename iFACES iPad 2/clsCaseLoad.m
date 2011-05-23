 //
//  clsWorkLoad.m
//  iFACES
//
//  Created by Hardik Zaveri on 09/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsCaseLoad.h"
#import "clsCase.h"
#import "iFACESAppDelegate.h"

@implementation clsCaseLoad

@synthesize objCICLPageController;
@synthesize tableView;
@synthesize cases;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		self.title = @"Cases";
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSMutableArray *caseArray = [[NSMutableArray alloc] init];
		self.cases = caseArray;
		caseArray = nil;
		[caseArray release];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "SELECT tm.entityId, tm.entity_name, tm.iEntityID, coalesce(wd.open_date, '') FROM tblentity_master tm inner join workload_details wd on tm.ientityid = wd.ientityid and assigned_to=? where entity_type='Case' group by tm.entityId, tm.entity_name, tm.iEntityID order by tm.entity_name";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iFACESSSN);
				while (sqlite3_step(statement) == SQLITE_ROW) 
				{
					clsCase *objCase = [clsCase alloc];
					objCase.iCaseID = sqlite3_column_double(statement, 0);
					objCase.sCaseName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
					objCase.iEntityID = sqlite3_column_double(statement, 2);
					objCase.dtOpenDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
					[cases addObject:objCase];
					objCase = nil;
					[objCase release];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			sql = nil;
			statement = nil;
		} 
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
		paths = nil;
		path = nil;
		documentsDirectory = nil;
	}
	return self;
}



- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	return [cases count];
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *identity = @"MainCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
       cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identity] autorelease];
		//cell = [[UITableViewCell alloc] autorelease];
    }
	cell.textLabel.font = [UIFont boldSystemFontOfSize:17.5]; 
    // Retrieve the book object matching the row from the application delegate's array.
    clsCase *objCase = [cases objectAtIndex:indexPath.row];
	NSString *sCaseID = [NSString stringWithFormat:@"(%.0f)", objCase.iCaseID];
    cell.textLabel.text = [objCase.sCaseName stringByAppendingString:@"\t"];
	cell.textLabel.text = [cell.textLabel.text stringByAppendingString:sCaseID];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
	sCaseID = nil;
	objCase = nil;
	//[objCase release];
	// objCase.iCaseID;
	
	
	/*UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 1.0,60.0, 40.0)];
	lblTemp.text = sCaseID;
	lblTemp.font = [UIFont boldSystemFontOfSize:17.5];
	lblTemp.textAlignment = UITextAlignmentRight;
	
	[cell addSubview:lblTemp];
	
	[lblTemp release];*/
	//[sCaseID release];
	
	//cell.textLabel.text = [cell.text];// stringByAppendingString:sCaseID];// objCase.iCaseID;
	//UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"imgCase" ofType:@"png"]];
	//UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(225.0, 1.0,50.0, 40.0)];
	//[tmpImageView setImage:tmpImg];
	//[cell addSubview:tmpImageView];
	//[tmpImageView release];
	//[tmpImg release];
	
	return cell;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellAccessoryDetailDisclosureButton;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
    clsCase *objCase = [cases objectAtIndex:indexPath.row];
	appDelegate.iEntityID = objCase.iEntityID;
	appDelegate.iCaseID = objCase.iCaseID;
	appDelegate.sCaseName = objCase.sCaseName;
	appDelegate.sCaseOpenDate = objCase.dtOpenDate;
	objCase = nil;
	objCICLPageController = [[clsCICLPageController alloc] initWithNibName:@"nCICLPageController" bundle:nil]; 
	[appDelegate.navigationController pushViewController:objCICLPageController animated:YES];
    return nil;
}


/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


 //If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
    
   // self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landingpage.gif"]];
//    backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
////    //backgroundImage.alpha = 0.4;
//    self.tableView.backgroundView = backgroundImage;
////    //self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage.image];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebar_hands_big.jpg"]];
    imgView.frame = self.view.bounds;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];
    [imgView release];    
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
	[tableView release];
	[cases release];
	[super dealloc];
}


@end
