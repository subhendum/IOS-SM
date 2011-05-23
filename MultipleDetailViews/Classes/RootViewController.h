
/*
     File: RootViewController.h
 Abstract: A table view controller that manages two rows. Selecting a row creates a new detail view controller that is added to the split view controller.
 
 */

#import <UIKit/UIKit.h>


/*
 SubstitutableDetailViewController defines the protocol that detail view controllers must adopt. The protocol specifies methods to hide and show the bar button item controlling the popover.

 */
//@protocol SubstitutableDetailViewController
//- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
//- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
//@end


@interface RootViewController : UITableViewController <UISplitViewControllerDelegate> {
	
	UISplitViewController *splitViewController;

	NSArray *menuArray;
	NSArray *menuImageArray;    
//    UIPopoverController *popoverController;    
//    UIBarButtonItem *rootPopoverButtonItem;
}

@property (nonatomic, assign) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) NSArray *menuArray;
@property (nonatomic, retain) NSArray *menuImageArray;
//@property (nonatomic, retain) UIPopoverController *popoverController;
//@property (nonatomic, retain) UIBarButtonItem *rootPopoverButtonItem;

@end
