//
//  clsCICLPageController.h
//  iFACES
//
//  Created by Hardik Zaveri on 31/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "clsCaseInfo.h"
#import "clsCaseContacts.h"

@interface clsCICLPageController : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
	
	clsCaseContacts *objContacts;
	clsCaseInfo *objCaseInfo;
	
	BOOL pageControlUsed;

}
@property (nonatomic, retain) clsCaseInfo *objCaseInfo;
@property (nonatomic, retain) clsCaseContacts *objContacts;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

- (IBAction)changePage:(id)sender;

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end
