//
//  clsContacts.h
//  iFACES
//
//  Created by Hardik Zaveri on 11/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface clsContacts : NSObject 
{
	double iContactID;
	double iContactEntityID;
    NSString *sContactName;
	NSString *sContactEntityType;
	UIImage *tmpImage;
	
}
@property (assign, nonatomic) double iContactID;
@property (assign, nonatomic) double iContactEntityID;
@property (nonatomic, retain) UIImage *tmpImage;
@property (copy, nonatomic) NSString *sContactName;
@property (copy, nonatomic) NSString *sContactEntityType;

@end
