//
//  ProductsTabViewController.h
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductsTabViewController : UITableViewController {
	
	
	NSArray *listOfProductCategories;
	NSString *selectedProductCategory;
	

}

@property (nonatomic, retain) NSArray *listOfProductCategories;
@property (nonatomic, retain) NSString *selectedProductCategory;	


@end
