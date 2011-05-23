//
//  TwitterUtil.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterUtil.h"


@implementation TwitterUtil

// This method is used to post a message to the twitter account. theMessage contains data to be posted.
//-(void)sendMessageToTwitter(id):handler {
//	
//	NSString *theMessage = @"test message";
//	
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mformusic:madmax55@twitter.com/statuses/update.xml"] cachePolicy:NSURLRequestUseProtocolPolicy timeoutInterval:60.0];
//	[request setHTTPMethod:@"POST"];
//	[request setHTTPBody:[[NSString stringWithFormat:@"status=%@",theMessage] dataUsingEncoding:NSASCIIStringEncoding]];
//	NSURLResponse *response;
//	NSError *error;
//	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//	NSLog(@"%@", [[[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding] autorelease]);
//}

@end
