//
//  User.m
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"


@implementation User
@synthesize username, password, managedFolder;

- (id)initWithUserDetails:(NSString *)userName password:(NSString *)pwd managedFolder:(NSString *)folder
{
    self = [super init];
    if (self) {
        self.username = userName;
		self.password = pwd;
		self.managedFolder = folder;
    }
    return self;
}

-(User *)getUser {
	return self;
}

@end
