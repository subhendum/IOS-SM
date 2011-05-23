//
//  GDFileViewController.h
//  GoogleDocSync
//
//  Created by Suyash Kaulgud on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface GDFileViewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {

	UIWebView *fileDetailsView;
	NSString *selectedFile;
	NSString *source;	
}

@property (nonatomic, retain) UIWebView *fileDetailsView;
@property (nonatomic, retain) NSString *selectedFile;
@property (nonatomic, retain) NSString *source;

- (void) moviePlayBackDidFinish:(NSNotification*) aNotification;


@end
