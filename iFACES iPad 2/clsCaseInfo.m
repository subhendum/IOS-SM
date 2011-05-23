//
//  clsCaseInfo.m
//  iFACES
//
//  Created by Hardik Zaveri on 11/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsCaseInfo.h"
#import "iFACESAppDelegate.h"
#import "MapViewController.h"

@implementation clsCaseInfo
@synthesize tableView;
@synthesize str_nbr;
@synthesize str_nme;
@synthesize zipCode;
@synthesize cty_nme;
@synthesize objMaps;
@synthesize fullAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		self.title = @"Case Info";
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
        
        NSLog(@" FACES DB PATH ======================> %@",path);
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "select str_nbr,  str_nme, cty_nme, zipCode FROM tblAddress where iEntityID=?";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iEntityID);
				if(sqlite3_step(statement) == SQLITE_ROW) 
				{
					self.str_nbr =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                    fullAddress = [NSString stringWithFormat:@"%@\n",self.str_nbr];
					self.str_nme =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",self.str_nme];
					self.cty_nme =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",self.cty_nme];
					self.zipCode =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                    fullAddress = [fullAddress stringByAppendingString:self.zipCode];
                    NSLog(@"Full Address : %@",fullAddress);
                    [fullAddress retain];
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
		//paths = nil;
		//path = nil;
		//documentsDirectory = nil;
	}
	return self;
}

//If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor clearColor];

    UIImageView *tableBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
    tableBack.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = tableBack;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CaseDetails_Updated.png"]];
    backgroundImage.contentMode = UIViewContentModeBottom;
    backgroundImage.opaque = YES;
    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //self.tableView.backgroundView = backgroundImage;
    [self.tableView addSubview:backgroundImage];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(48, 6, 300, 30);
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


- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.
    switch (section) 
	{
        case 0: return @"Details";
        case 1: return @"Address";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
    return 2;
}


- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.row == 3 && indexPath.section == 1)
	{
		if(self.str_nbr != nil && self.str_nme != nil && self.cty_nme != nil && self.zipCode != nil)
		{
			iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
			NSString *tmp = @"&q=";
			tmp = [tmp stringByAppendingString:self.str_nbr];
			tmp = [tmp stringByAppendingString:@"+"];
			tmp = [tmp stringByAppendingString:self.str_nme];
			tmp = [tmp stringByAppendingString:@"+"];
			tmp = [tmp stringByAppendingString:self.cty_nme];
			tmp = [tmp stringByAppendingString:@"+"];
			tmp = [tmp stringByAppendingString:self.zipCode];
			tmp = [tmp stringByReplacingOccurrencesOfString:@" " withString:@"+"];
			appDelegate.sMapQuery = tmp;
			//tmp = nil;
			//if(objMaps == nil)
			//	objMaps = [[clsMaps alloc] initWithNibName:@"nMaps" bundle:nil];
			//[appDelegate.navigationController pushViewController:objMaps animated:YES];
			tmp = [@"http://maps.google.com/maps?&z=16&iwloc=A" stringByAppendingString:tmp];
            MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
            mapView.url = tmp;
            [appDelegate.navigationController pushViewController:mapView animated:YES];
           // [mapView release];

//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmp]];
			tmp = nil;
		}
		else
			return nil;
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
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	if(section == 0)
		return 2;
	else
		return 2;
}	

-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	if((indexPath.section == 1 && indexPath.row == 0))
	{
		return 100.0;
	}
	else
		return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
    }
    
//    UIImageView *cellImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
//    cellImage.contentMode = UIViewContentModeScaleToFill;
//    [cell setBackgroundView:cellImage];
    
    switch (indexPath.section) 
	{
        case 0:
		{
			iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
			if(indexPath.row == 0)
			{
				cell.textLabel.text = [appDelegate.sCaseName stringByAppendingString:[NSString stringWithFormat:@" - %.0f", appDelegate.iCaseID]]; 
			}
			else
			{
				cell.textLabel.text = [@"Open Date: " stringByAppendingString:appDelegate.sCaseOpenDate];
			}
			break;
		}
        case 1:
			if(indexPath.row == 0)
			{
				//cell.textLabel.text = [self.str_nbr stringByAppendingString:@", "];
				//cell.textLabel.text = [cell.textLabel.text stringByAppendingString:self.str_nme];
                UIImageView *homeAddressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(53, 12, 32, 32)];
                [homeAddressImageView setImage:[UIImage imageNamed:@"house-icon.png"]];
                homeAddressImageView.backgroundColor = [UIColor clearColor];
                [cell addSubview:homeAddressImageView];
                
				UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 15.0, 150, 20.0)];
				lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
				lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
				lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
				lblTemp.textAlignment = UITextAlignmentRight;
				lblTemp.text = @"Home Address";
                lblTemp.textColor = [UIColor whiteColor];                
                lblTemp.backgroundColor = [UIColor clearColor];
				[cell addSubview:lblTemp];
				[lblTemp release];                
                
                lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(225.0, 15.0, 230.0, 80.0)];
                lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
                lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
                lblTemp.textColor = [UIColor blackColor];
                lblTemp.textAlignment = UITextAlignmentLeft;
                lblTemp.numberOfLines = 4;
                lblTemp.text = fullAddress;
                lblTemp.textColor = [UIColor whiteColor];                    
                lblTemp.backgroundColor = [UIColor clearColor];
                [cell addSubview:lblTemp];
                [lblTemp release];                
                
			}
//			else if(indexPath.row == 1) 
//				cell.textLabel.text = self.cty_nme; 
//			else if(indexPath.row == 2)	
//				cell.textLabel.text = self.zipCode;
			else
			{
				cell.textLabel.text = @"View On Map";
				UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"maps" ofType:@"png"]];
				UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(645.0, 5.0,40.0, 40.0)];
				[tmpImageView setImage:tmpImg];
				//[cell addSubview:tmpImageView];
                [[cell imageView] setImage:tmpImg];
                
				[tmpImageView release];
				[tmpImg release];
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			}
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
   cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
//{
//	if(indexPath.row == 3 && indexPath.section == 1)
//		return UITableViewCellAccessoryDetailDisclosureButton;
//	else
//		return UITableViewCellAccessoryNone;
//}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
	
}
 */


- (BOOL)shouldAutorotateToInterfaceO2rientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[tableView release];
	[self.str_nbr release];
	[self.str_nme release];
	[self.cty_nme release];
	[self.zipCode release];
	[objMaps release];
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}



- (void)dealloc {
	[tableView release];
	[self.str_nbr release];
	[self.str_nme release];
	[self.cty_nme release];
	[self.zipCode release];
	[objMaps release];
	[super dealloc];
}


@end
