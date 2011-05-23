//
//  User.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : NSObject {
	
	NSString *username;
	NSString *password;
	NSString *managedFolder;

}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *managedFolder;

-(User *)getUser;
- (id)initWithUserDetails:(NSString *)userName password:(NSString *)pwd managedFolder:(NSString *)folder;


@end
