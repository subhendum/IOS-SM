//
//  clsCaseInfo.h
//  iFACES
//
//  Created by Hardik Zaveri on 11/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "clsMaps.h"

@interface clsCaseInfo : UIViewController 
{
	IBOutlet UITableView *tableView;
	NSString *str_nbr;
	NSString *str_nme;
	NSString *zipCode;
	NSString *cty_nme;
    
    NSString *fullAddress;
	
	sqlite3 *database;
	clsMaps *objMaps;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *str_nbr;
@property (nonatomic, retain) NSString *str_nme;
@property (nonatomic, retain) NSString *zipCode;
@property (nonatomic, retain) NSString *cty_nme;
@property (nonatomic, retain) clsMaps *objMaps;
@property (nonatomic, retain) NSString *fullAddress;


@end
