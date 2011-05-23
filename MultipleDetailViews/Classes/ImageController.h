//
//  ImageController.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageController : UIViewController {
	
	UIImageView *imageView;
	NSString *file;

}


@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSString *file;
@end
