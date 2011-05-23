//
//  clsCNNIPageController.h
//  iFACES
//
//  Created by Hardik Zaveri on 31/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "clsTextNote.h"
#import "clsNotesInfo.h"
#import "clsPhotoNote.h"
#import "clsAudioController.h"

@interface clsCNNIPageController : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
	
	BOOL pageControlUsed;
	
	clsTextNote *textNote;
	clsNotesInfo *objNotesInfo;
	clsPhotoNote *photoNote;
	clsAudioController *caseAudioController;

}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) clsTextNote *textNote;
@property (nonatomic, retain) clsNotesInfo *objNotesInfo;
@property (nonatomic, retain) clsPhotoNote *photoNote;
@property (nonatomic, retain) clsAudioController *caseAudioController;

- (IBAction)changePage:(id)sender;

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;


@end
