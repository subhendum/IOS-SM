//
//  DownloadedFile.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DownloadedFile : NSObject {
	
	NSString *fileName;
	NSString *fileSize;
	NSString *modifiedDate;
}

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileSize;
@property (nonatomic, retain) NSString *modifiedDate;

@end
