//
//  clsCaseMedia.m
//  iFACES
//
//  Created by Hardik Zaveri on 12/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsCaseMedia.h"
#import "iFACESAppDelegate.h"
#import "clsMedia.h"
#import "clsNotesInfo.h"

@implementation clsCaseMedia
@synthesize tableView;
@synthesize media;
@synthesize objCNNIPageController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		
		/*self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
		 target:self action:@selector(new:)] autorelease];*/
		NSMutableArray *fileArray = [[NSMutableArray alloc] init];
		self.media = fileArray;
		[fileArray release];
		
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.sMediaFileSelected = nil;
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "SELECT coalesce(media_filename, ''), media_type, iMediaID, coalesce(title, ''), coalesce(media_blob, '') from tblEntity_Media where iEntityID = ? and media_type In (0,1) union select '', 3, iNotesID, title || ' (' || addDate || ')', '' from tblNotes where iEntityID = ?";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				if(appDelegate.iContactEntityID == 0)
				{
					sqlite3_bind_int(statement, 1, appDelegate.iEntityID);
					sqlite3_bind_int(statement, 2, appDelegate.iEntityID);
				}
				else
				{
					sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
					sqlite3_bind_int(statement, 2, appDelegate.iContactEntityID);
				}
				while (sqlite3_step(statement) == SQLITE_ROW) 
				{
					clsMedia *objMedia = [clsMedia alloc];
					objMedia.sFileName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					objMedia.iMediaType = sqlite3_column_int(statement, 1);
					objMedia.iMediaID = sqlite3_column_int(statement, 2);
					objMedia.sTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
					objMedia.img = [NSData dataWithBytes:sqlite3_column_blob(statement, 4) length:sqlite3_column_bytes(statement, 4)];
					[media addObject:objMedia];
					[objMedia release];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		} 
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
		path = nil;
		paths = nil;
		[paths  release];
		documentsDirectory = nil;
		
	}
    return self;
	
}

/*If you need to do additional setup after loading the view, override viewDidLoad.*/
-(void) viewDidLoad{
    
    self.tableView.clearsContextBeforeDrawing = YES;
    self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebar_hands_big.jpg"]];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = backgroundImage;    
	
}
/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */
 
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	return [media count];
}	

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSIndexPath *)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	clsMedia *objMedia = [media objectAtIndex:indexPath.row];
	appDelegate.iMediaID = objMedia.iMediaID;
    
    
	appDelegate.iMediaType = objMedia.iMediaType;
	if(objMedia.iMediaType == 3)
	{
		appDelegate.sMediaFileSelected = nil;
		appDelegate.sOperationMode = @"EDIT";
	}
	else if(objMedia.iMediaType == 0)
	{
		appDelegate.sMediaFileSelected = objMedia.sFileName;
	}
	else if(objMedia.iMediaType == 1)
	{
		appDelegate.sMediaFileSelected = nil;
		appDelegate.sOperationMode = @"EDIT";
	}
	//[objMedia release];
	objCNNIPageController = [[clsCNNIPageController alloc] initWithNibName:@"nCNNIPageController" bundle:nil]; 
	[appDelegate.navigationController pushViewController:objCNNIPageController animated:YES];
	//[self.view addSubview:tabBarController.view];
	
    return nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *identity = @"MainCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) 
	{
        // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identity] autorelease];
    }
    
	clsMedia *objMedia = [media objectAtIndex:indexPath.row];
	cell.textLabel.text = objMedia.sTitle;
    
	cell.textLabel.font = [UIFont boldSystemFontOfSize:17.5]; 
	if(objMedia.iMediaType == 0)
	{
		UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"microphone" ofType:@"png"]];
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(700.0, 1.0,40.0, 40.0)];
		[tmpImageView setImage:tmpImg];
		//[cell addSubview:tmpImageView];
        [[cell imageView] setImage:tmpImageView.image];
		[tmpImageView release];
		[tmpImg release];
	}
	else if(objMedia.iMediaType == 3)
	{
		UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notes2" ofType:@"png"]];
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(700.0, 1.0,40.0, 40.0)];
		[tmpImageView setImage:tmpImg];
		//[cell addSubview:tmpImageView];
        [[cell imageView] setImage:tmpImageView.image];
		[tmpImageView release];
		[tmpImg release];
	}
	else if(objMedia.iMediaType == 1)
	{
		UIImage *tmpImg = [[UIImage alloc] initWithData:objMedia.img];
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(700.0, 1.0,40.0, 40.0)];
		//tmpImageView.transform = CGAffineTransformRotate(tmpImageView.transform, M_PI);
		[tmpImageView setImage:tmpImg];
		//[cell addSubview:tmpImageView];
        [[cell imageView] setImage:tmpImageView.image];
		[tmpImageView release];
		[tmpImg release];
	}
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)viewWillAppear:(BOOL)animated {
    self.tableView.clearsContextBeforeDrawing = YES;
}

- (void)dealloc {
	[super dealloc];
}


//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
//{
//    return UITableViewCellAccessoryDetailDisclosureButton;
//}


@end
