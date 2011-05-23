//
//  clsCaseContacts.h
//  iFACES
//
//  Created by Hardik Zaveri on 11/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "clsCICNPageController.h"
 
@interface clsCaseContacts : UIViewController 
{
	IBOutlet UITableView *tableView;
	sqlite3 *database;
	NSMutableArray *contacts;
	
	clsCICNPageController *objCICNPageController;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *contacts;

@property (nonatomic, retain) clsCICNPageController *objCICNPageController;


-(void) getContacts;
-(UIImage *)getImageforContact:(double)iEntityId;

@end
