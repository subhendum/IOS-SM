//
//  clsContactInfo.m
//  iFACES
//
//  Created by Hardik Zaveri on 16/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsContactInfo.h"
#import "sqlite3.h"
#import "iFACESAppDelegate.h"
#import "MapViewController.h"

@implementation clsContactInfo

@synthesize tableView;
@synthesize imgView;
@synthesize lblContactID;
@synthesize lblContactName;
@synthesize sContactName;
@synthesize tmpImage;
@synthesize sBirthDate;
@synthesize aPhone;
@synthesize aAddress;
@synthesize objMaps;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		//self.title = @"Contact Info";
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSLog(@"iEntityId : %f",appDelegate.iContactEntityID);
        
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "select coalesce(prefix, '') || ' ' || coalesce(first_name,'') || ' ' || coalesce(last_name, ''), coalesce(birth_date,'') from tblEntity_Details where iEntityID=?";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
				if(sqlite3_step(statement) == SQLITE_ROW) 
				{
					self.sContactName =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					self.sBirthDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			sql = nil;
			
			sql = "select media_blob from tblEntity_Media where iEntityID=? and Media_type=2";
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
				if(sqlite3_step(statement) == SQLITE_ROW) 
				{
					self.tmpImage = [[[UIImage alloc] initWithData:[NSData dataWithBytes:sqlite3_column_blob(statement, 0) length:sqlite3_column_bytes(statement, 0)]] retain];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			sql = nil;
			
			NSMutableArray *aPhoneNBR = [[NSMutableArray alloc] init];
			self.aPhone = aPhoneNBR;
			aPhoneNBR = nil;
			[aPhoneNBR release];

			sql = "select coalesce(phonenbr, '') from tblPhone where iEntityID=? and phonetyp in (14887, 14888) order by phonetyp";
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
				while(sqlite3_step(statement) == SQLITE_ROW) 
				{
					[aPhone addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			
			
			NSMutableArray *aAddr = [[NSMutableArray alloc] init];
			self.aAddress = aAddr;
			aAddr = nil;
			[aAddr release];
			sql = "select coalesce(str_nbr, ''),  coalesce(str_nme, ''), coalesce(cty_nme, ''), coalesce(zipCode, '') FROM tblAddress where iEntityID=? and address_typ_cde in (0, 1)";
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
				while(sqlite3_step(statement) == SQLITE_ROW) 
				{
					NSString * strTmp;
					strTmp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					strTmp = [strTmp stringByAppendingString:@"\n"];
					strTmp = [strTmp stringByAppendingString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
					strTmp = [strTmp stringByAppendingString:@"\n"];
					strTmp = [strTmp stringByAppendingString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
					strTmp = [strTmp stringByAppendingString:@"\n"];
					strTmp = [strTmp stringByAppendingString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
					[aAddress addObject:strTmp];
					strTmp = nil;
					//[strTmp dealloc];
					//[aAddress addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
					//[aAddress addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
					//[aAddress addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
					//[aAddress addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			sql = nil;
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
		[paths release];
		documentsDirectory = nil;
		
	}
	return self;
}


//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
//{
//	if((indexPath.row == 1 && indexPath.section == 1 && [aAddress count] > 0) || (indexPath.row == 3 && indexPath.section == 1 && [aAddress count] > 0))
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

- (void) viewDidLoad 
{

	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	[lblContactName setText:self.sContactName];
    lblContactName.textColor = [UIColor whiteColor];
	[lblContactID setText:[NSString stringWithFormat:@"(%.0f)", appDelegate.iContactID]];
    lblContactID.textColor = [UIColor whiteColor];    
	//imgView.image = tmpImage;
    [btnAddPhoto setImage:tmpImage forState:UIControlStateNormal];
	[tmpImage release];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = backgroundImage;    
    
    UITableView *topTable = (UITableView *)[self.view viewWithTag:1];
    
    [topTable setBackgroundView:nil];
    topTable.backgroundColor = [UIColor clearColor];
    UIImageView *topBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
    topBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    topTable.backgroundView = topBackgroundImage;    
    
}

- (IBAction)btnAddPhoto_Click:(id) sender
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
	[actionSheet showInView:[appDelegate.navigationController view]]; 
	[actionSheet release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	if(section == 2)
		return 1;
	else if(section == 0)
		return 2;
	else if(section == 1)
		return 4;
	else
		return 0;
}	


- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(indexPath.section == 0)
	{
        @try
        {
		NSString *tmp = [@"tel://" stringByAppendingString:[aPhone objectAtIndex:indexPath.row]];
		tmp = [tmp stringByReplacingOccurrencesOfString:@"(" withString:@""];
		tmp = [tmp stringByReplacingOccurrencesOfString:@")" withString:@""];
		tmp = [tmp stringByReplacingOccurrencesOfString:@" " withString:@""];
		tmp = [tmp stringByReplacingOccurrencesOfString:@"-" withString:@""];
		//objMaps = [[clsMaps alloc] initWithNibName:@"nMaps" bundle:nil];
		//[appDelegate.navigationController pushViewController:objMaps animated:YES];
		
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmp]];            
//		tmp=nil;
        MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        mapView.url = tmp;
            
        [appDelegate.navigationController pushViewController:mapView animated:YES];  
            tmp = nil;
            [tmp release];
        }
        @catch(id theException) {
            NSLog(@"%@", theException);
        }
		
	}
	else if((indexPath.row == 1 && indexPath.section == 1 && [aAddress count] > 0))
	{
		NSString *tmp = @"&q=";
		tmp = [tmp stringByAppendingString:[[aAddress objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
		tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@"+"];
		/*for(int i=0; i<4; i++)
		{
			tmp = [tmp stringByAppendingString:[[aAddress objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
			if(i<3)
				tmp = [tmp stringByAppendingString:@"+"];
		}
		tmp = [tmp stringByReplacingOccurrencesOfString:@"++" withString:@"+"];*/
		appDelegate.sMapQuery = tmp;
		//tmp = nil;
		//objMaps = [[clsMaps alloc] initWithNibName:@"nMaps" bundle:nil];
		//[appDelegate.navigationController pushViewController:objMaps animated:YES];
		tmp = [@"http://maps.google.com/maps?&z=16&iwloc=A" stringByAppendingString:tmp];
        
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmp]];
//		tmp = nil;
        MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        mapView.url = tmp;
        
        [appDelegate.navigationController pushViewController:mapView animated:YES];  
       
		[tmp release];
	}
	else if((indexPath.row == 3 && indexPath.section == 1 && [aAddress count] > 1))
	{
		NSString *tmp = @"&q=";
		tmp = [tmp stringByAppendingString:[[aAddress objectAtIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
		tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@"+"];
		/*for(int i=4; i<8; i++)
		{
			tmp = [tmp stringByAppendingString:[[aAddress objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
			if(i<7)
				tmp = [tmp stringByAppendingString:@"+"];
 		}
		tmp = [tmp stringByReplacingOccurrencesOfString:@"++" withString:@"+"];*/
		appDelegate.sMapQuery = tmp;
		//tmp = nil;
		//objMaps = [[clsMaps alloc] initWithNibName:@"nMaps" bundle:nil];
		//[appDelegate.navigationController pushViewController:objMaps animated:YES];
		tmp = [@"http://maps.google.com/maps?&z=16&iwloc=A" stringByAppendingString:tmp];
        
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmp]];
//		tmp = nil;
        MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        mapView.url = tmp;
        
        [appDelegate.navigationController pushViewController:mapView animated:YES];  
       
		[tmp release];
	}
    return nil;
}

- (CGFloat) tableView: (UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.0f;
}
- (CGFloat) tableView: (UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 45.0f;
}
-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	if((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 2))
	{
		return 100.0;
	}
	else
		return 50.0;
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
//    switch (section) 
//	{
//        case 0: return @"Details";
//       // case 1: return @"Address";
//    }
    if(tv.tag == 0 && section == 0) {
       return @"Details";     
    }

    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
    }
	cell.textLabel.text = @"";
	cell.textLabel.font = [UIFont boldSystemFontOfSize:17.5]; 
    
    switch (indexPath.section) 
	{
        case 0:
		{
			if(indexPath.row == 0)
			{
				if([aPhone count] > 0)
				{
					
					UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 15.0, 180.0, 20.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
					lblTemp.textAlignment = UITextAlignmentRight;
					lblTemp.text = @"Home Phone Number ";
                    lblTemp.textColor = [UIColor whiteColor];
                    lblTemp.backgroundColor = [UIColor clearColor];
					[cell addSubview:lblTemp];
					[lblTemp release];
					
					lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(280.0, 15.0, 130.0, 20.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor blackColor];
					lblTemp.textAlignment = UITextAlignmentLeft;
					lblTemp.text = [aPhone objectAtIndex:indexPath.row];
                    lblTemp.textColor = [UIColor whiteColor];
                    lblTemp.backgroundColor = [UIColor clearColor];
					[cell addSubview:lblTemp];
					[lblTemp release];
					
                    [[cell imageView] setImage:[UIImage imageNamed:@"phone-icon.png"]];
					
					/*UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"imgCall" ofType:@"png"]];
					 UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(235.0, 3.0,50.0, 40.0)];
					 [tmpImageView setImage:tmpImg];
					 [cell addSubview:tmpImageView];
					 [tmpImageView release];
					 [tmpImg release];*/
				}
				else
				{
					UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 15.0, 180.0, 20.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
					lblTemp.textAlignment = UITextAlignmentRight;
					lblTemp.text = @"Home Phone Number";
                    lblTemp.textColor = [UIColor whiteColor];                    
                    lblTemp.backgroundColor = [UIColor clearColor];
					[cell addSubview:lblTemp];
					[lblTemp release];
				}
			}
			else
			{
				if([aPhone count] > 1)
				{
					UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 15.0, 180, 20.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
					lblTemp.textAlignment = UITextAlignmentRight;
					lblTemp.text = @"Work Phone Number ";
                    lblTemp.textColor = [UIColor whiteColor];                    
                    lblTemp.backgroundColor = [UIColor clearColor];
					[cell addSubview:lblTemp];
					[lblTemp release];
					
					lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(280, 15.0, 130.0, 20.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor blackColor];
					lblTemp.textAlignment = UITextAlignmentLeft;
					lblTemp.text = [aPhone objectAtIndex:indexPath.row];
                    lblTemp.textColor = [UIColor whiteColor];                    
                    lblTemp.backgroundColor = [UIColor clearColor];
					[cell addSubview:lblTemp];
					[lblTemp release];
					
					/*UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"imgCall" ofType:@"png"]];
					 UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(235.0, 3.0,50.0, 40.0)];
					 [tmpImageView setImage:tmpImg];
					 [cell addSubview:tmpImageView];
					 [tmpImageView release];
					 [tmpImg release];*/
                    [[cell imageView] setImage:[UIImage imageNamed:@"phone-icon.png"]];
				}
				else
				{
					UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 15.0, 180.0, 20.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
					lblTemp.textAlignment = UITextAlignmentRight;
					lblTemp.text = @"Work Phone Number";
                    lblTemp.textColor = [UIColor whiteColor];                    
                    lblTemp.backgroundColor = [UIColor clearColor];
					[cell addSubview:lblTemp];
					[lblTemp release];
				}
			}
			break;
		}
        case 1:
		{
			if(indexPath.row == 0)
			{
                
                UIImageView *homeAddressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(53, 12, 32, 32)];
                [homeAddressImageView setImage:[UIImage imageNamed:@"house-icon.png"]];
                homeAddressImageView.backgroundColor = [UIColor clearColor];
                [cell addSubview:homeAddressImageView];
                                
                UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 15.0, 150, 20.0)];
				lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
				lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
				lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
				lblTemp.textAlignment = UITextAlignmentRight;
				lblTemp.text = @"Home Address";
                lblTemp.textColor = [UIColor whiteColor];                
                lblTemp.backgroundColor = [UIColor clearColor];
				[cell addSubview:lblTemp];
				[lblTemp release];
				
				if([aAddress count] > 0)
				{
					lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(225.0, 15.0, 230.0, 80.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor blackColor];
					lblTemp.textAlignment = UITextAlignmentLeft;
					lblTemp.numberOfLines = 4;
					lblTemp.text = [aAddress objectAtIndex:0];
                    lblTemp.textColor = [UIColor whiteColor];                    
                    lblTemp.backgroundColor = [UIColor clearColor];
					[cell addSubview:lblTemp];
					[lblTemp release];
				}
			}
			else if(indexPath.row == 1)
			{
				if([aAddress count] > 0)
				{
					cell.textLabel.text = @"View On Map";
					cell.textLabel.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
					UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"maps" ofType:@"png"]];
					UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(645.0, 5.0,40.0, 40.0)];
					[tmpImageView setImage:tmpImg];
//					[cell addSubview:tmpImageView];
                    [[cell imageView] setImage:tmpImg];                    
					[tmpImageView release];
					[tmpImg release];
                    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					
				}
			}
			/*else
			 {
			 cell.textLabel.text = [NSString stringWithFormat: @"              "];
			 if([aAddress count] > 0)
			 cell.textLabel.text = [cell.text stringByAppendingString:[aAddress objectAtIndex:indexPath.row+1]];
			 }*/
			//}
			else if(indexPath.row == 2) 
			{
				/*if(indexPath.row == 4)
				 {*/
				UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 15.0, 150.0, 20.0)];
				lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
				lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
				lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
				lblTemp.textAlignment = UITextAlignmentRight;
				lblTemp.text = @"Work Address";
                    lblTemp.textColor = [UIColor whiteColor];                
                lblTemp.backgroundColor = [UIColor clearColor];
				[cell addSubview:lblTemp];
				[lblTemp release];
				if([aAddress count] > 1)
				{
					lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(222.0, 15.0, 230.0, 80.0)];
					lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
					lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
					lblTemp.textColor = [UIColor blackColor];
					lblTemp.textAlignment = UITextAlignmentLeft;
					lblTemp.numberOfLines = 4;
					lblTemp.text = [aAddress objectAtIndex:1];
                    lblTemp.textColor = [UIColor whiteColor];                    
                    lblTemp.backgroundColor = [UIColor clearColor];
					//lblTemp.text = [lblTemp.text stringByAppendingString:[aAddress objectAtIndex:indexPath.row+1]];
					[cell addSubview:lblTemp];
					[lblTemp release];
					
                    UIImageView *homeAddressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(53, 12, 32, 32)];
                    [homeAddressImageView setImage:[UIImage imageNamed:@"bank-icon.png"]];
                    homeAddressImageView.backgroundColor = [UIColor clearColor];
                    [cell addSubview:homeAddressImageView];
				}
			}
			else if(indexPath.row == 3)
			{
				if([aAddress count] > 1)
				{
					cell.textLabel.text = @"View On Map";
					cell.textLabel.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
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
			/*else
			 {
			 cell.textLabel.text = @"              ";
			 if([aAddress count] > 4)
			 cell.textLabel.text = [cell.text stringByAppendingString:[aAddress objectAtIndex:indexPath.row+1]];
			 }*/
			//}
			break;
		}
		case 2:
		{
            [[cell imageView] setImage:[UIImage imageNamed:@"cake-icon.png"]];
            
			UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 15.0, 120.0, 20.0)];
			lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
			lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			lblTemp.textColor = [UIColor colorWithRed:0.32f green:0.44f blue:0.55f alpha:5.0f];
			lblTemp.textAlignment = UITextAlignmentRight;
			lblTemp.text = @"Date Of Birth ";
                    lblTemp.textColor = [UIColor whiteColor];            
            lblTemp.backgroundColor = [UIColor clearColor];
			[cell addSubview:lblTemp];
			[lblTemp release];
			
			lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 15.0, 100.0, 20.0)];
			lblTemp.font = [UIFont boldSystemFontOfSize:17.00];
			lblTemp.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			lblTemp.textColor = [UIColor blackColor];
			lblTemp.textAlignment = UITextAlignmentRight;
			if(self.sBirthDate == nil)
				lblTemp.text = @" ";
			else
				lblTemp.text = self.sBirthDate;
                    lblTemp.textColor = [UIColor whiteColor];            
            lblTemp.backgroundColor = [UIColor clearColor];
			[cell addSubview:lblTemp];
			[lblTemp release];
			//cell.textLabel.text = 
			if(cell.textLabel.text == nil)
				cell.textLabel.text = @" ";
			break;
		}
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[imagePickerController release];
	[sSelectedCallNo release];
	[sContactName release];
	[sBirthDate release];
	[aPhone release];
	[aAddress release];
	[tmpImage release];
	
	[tableView release];
	[imgView release];
	[lblContactName release];
	[lblContactID release];
	[btnAddPhoto release];
	[objMaps release];
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview

	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
	[tableView release];
	[imgView release];
	[lblContactName release];
	[lblContactID release];
	[btnAddPhoto release];
	[imagePickerController release];
	
	[sSelectedCallNo release];
	[sContactName release];
	[sBirthDate release];
	[aPhone release];
	[aAddress release];
	[tmpImage release];
	[objMaps release];
	[super dealloc];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{

	NSData *imgData = UIImageJPEGRepresentation(image, 0.0);
	[self SaveImage:imgData];
	//imgView.image = image;
    //imgView.contentMode = UIViewContentModeScaleAspectFit;
    [btnAddPhoto setImage:image forState:UIControlStateNormal];
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	// Dismiss the image selection and close the program
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
	//exit(0);
}

- (void) actionSheet: (UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];

	if(buttonIndex == 1)
	{
		imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;
        //imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		[appDelegate.navigationController presentModalViewController:imagePickerController animated:YES];
	}
	else if(buttonIndex == 0)
	{
		imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
            UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Camera Not Available" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
            return;
            
        }


        
		[appDelegate.navigationController presentModalViewController:imagePickerController animated:YES];
	}
	//[[[[UIActionSheet alloc] initWithTitle:@"Select" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Image", @"Voice", nil] autorelease] show];
}


- (void)viewWillAppear:(BOOL)animated 
{
	//[tableView reloadData]; 
}



- (void) SaveImage:(NSData *)imgData
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.blnRefreshContactsPage = TRUE;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
	{
		const char *sql = "Delete from tblEntity_Media where iEntityID = ? and Media_type = 2";
		sqlite3_stmt *statement;      
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
		{
			sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
			sqlite3_step(statement);
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
		
		sql = "Insert Into tblEntity_Media (iEntityID, Media_type, media_blob) values (?, 2, ?)";
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
		{
			sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
			sqlite3_bind_blob(statement, 2, [imgData bytes], [imgData length], SQLITE_TRANSIENT);
			sqlite3_step(statement);
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
}

@end
