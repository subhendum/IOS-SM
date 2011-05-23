//
//  clsCICNPageController.h
//  iFACES
//
//  Created by Hardik Zaveri on 31/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "clsContactInfo.h"
#import "clsCaseMedia.h"
#import "clsTextNote.h"
#import "clsPhotoNote.h"
#import "clsAudioController.h"


@interface clsCICNPageController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
{
	IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
		
	BOOL pageControlUsed;
	
	clsContactInfo *objContactInfo;
	clsCaseMedia *objCaseMedia;
	
	clsTextNote *textNote;
	clsAudioController *caseAudioController;
	clsPhotoNote *photoNote;
	

}
@property (nonatomic, retain) clsTextNote *textNote;
@property (nonatomic, retain) clsAudioController *caseAudioController;
@property (nonatomic, retain) clsPhotoNote *photoNote;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, retain) clsContactInfo *objContactInfo;
@property (nonatomic, retain) clsCaseMedia *objCaseMedia;

- (IBAction)changePage:(id)sender;

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

- (void) actionSheet: (UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex;


@end
