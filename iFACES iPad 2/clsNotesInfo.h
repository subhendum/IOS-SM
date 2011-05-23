//
//  clsNotesInfo.h
//  iFACES
//
//  Created by Hardik Zaveri on 03/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "clsMaps.h"


@interface clsNotesInfo : UIViewController
{
	NSString *sTitle;
	NSString *sAddDate;
	NSString *sUpdateDate;
	NSString *sLatitude;
	NSString *sLongitude;
	NSString *sTags;
	IBOutlet UITableView *tableView;

	clsMaps *objMaps;
	sqlite3 *database;
	NSString *sTagsTmp;
}

@property (nonatomic, retain) NSString *sLatitude;
@property (nonatomic, retain) NSString *sLongitude;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *sTitle;
@property (nonatomic, retain) NSString *sAddDate;
@property (nonatomic, retain) NSString *sUpdateDate;
@property (nonatomic, retain) NSString *sTags;
@property (nonatomic, retain) clsMaps *objMaps;
@property (nonatomic, retain) NSString *sTagsTmp;

@end
