//
//  Account.m
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "Account.h"
#import "Response.h"
#import "Connection.h"
#import "RackspaceAppDelegate.h"

@implementation Account

@synthesize containers;

-(NSString *)container {
	return container;
}

-(Account *)init {
	self.containers = [NSMutableArray arrayWithCapacity:10];
	return self;
}

-(void)setContainer:(NSString *)aContainer {
	// viscious hack!  rackspace doesn't return a <container> inside of <containers>, so hack the setter
	// to pretend it's in a <containers> element
	if (!containers) {
		containers = [NSMutableArray array];
	}
	[containers addObject:aContainer];
}

// overriding because accounts don't follow the typical url format for restful resources
+ (id)findRemote:(NSString *)elementId withResponse:(NSError **)aError {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=xml", app.storageUrl]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [Connection sendRequest:request withAuthToken:app.authToken];	
	if ([res isError] && aError) {
		*aError = res.error;
	}
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
}

// overriding because accounts don't follow the typical url format for restful resources
+ (id)findCDNRemote:(NSString *)elementId withResponse:(NSError **)aError {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=xml", app.cdnManagementUrl]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [Connection sendRequest:request withAuthToken:app.authToken];	
	if ([res isError] && aError) {
		*aError = res.error;
	}
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
}

-(void)dealloc {
	[containers dealloc];
	[super dealloc];
}

@end
