//
//  clsMedia.h
//  iFACES
//
//  Created by Hardik Zaveri on 18/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>


@interface clsMedia : NSObject 
{
	double iMediaID;
	int iMediaType;
    NSString *sFileName;
	NSString *sTitle;
	NSData *img;
}

@property (assign, nonatomic) double iMediaID;
@property (assign, nonatomic) int iMediaType;
@property (nonatomic, retain) NSString *sFileName;
@property (nonatomic, retain) NSString *sTitle;
@property (nonatomic, retain) NSData *img;


@end
