//
//  clsContactInfo.h
//  iFACES
//
//  Created by Hardik Zaveri on 16/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "clsMaps.h"


@interface clsContactInfo : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
	IBOutlet UITableView *tableView;
	IBOutlet UIImageView *imgView;
	IBOutlet UILabel *lblContactName;
	IBOutlet UILabel *lblContactID;
	IBOutlet UIButton *btnAddPhoto;
	UIImagePickerController* imagePickerController;
	
	NSString *sSelectedCallNo;
	NSString *sContactName;
	NSString *sBirthDate;
	NSMutableArray *aPhone;
	NSMutableArray *aAddress;
	sqlite3 *database;
	UIImage *tmpImage;
	
	clsMaps *objMaps;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, retain) UILabel *lblContactName;
@property (nonatomic, retain) UILabel *lblContactID;
@property (nonatomic, retain) NSString *sContactName;
@property (nonatomic, retain) UIImage *tmpImage;
@property (nonatomic, retain) NSString *sBirthDate;
@property (nonatomic, retain) NSMutableArray *aPhone;
@property (nonatomic, retain) NSMutableArray *aAddress;
@property (nonatomic, retain) clsMaps *objMaps;


- (IBAction)btnAddPhoto_Click:(id) sender; 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void) SaveImage:(NSData *)imgData;


@end
