//
//  clsCase.h
//  iFACES
//
//  Created by Hardik Zaveri on 10/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface clsCase : NSObject 
{	
	double iEntityID;
	double iCaseID;
    NSString *sCaseName;
    NSString *dtOpenDate;
    NSString *sAssignedTo;
	double iAssignedTo;
}

@property (assign, nonatomic) double iEntityID;
@property (assign, nonatomic) double iCaseID;
@property (copy, nonatomic) NSString *sCaseName;
@property (copy, nonatomic) NSString *dtOpenDate;
@property (copy, nonatomic) NSString *sAssignedTo;
@property (assign, nonatomic) double iAssignedTo;

//- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;


@end
