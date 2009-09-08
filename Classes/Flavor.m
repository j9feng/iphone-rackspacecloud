//
//  Flavor.m
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "Flavor.h"
#import "ObjectiveResource.h"
#import "RackspaceAppDelegate.h"
#import "Response.h"
#import "ORConnection.h"

@implementation Flavor

@synthesize flavorId, flavorName, ram, disk;

// Find all items 
+ (NSArray *)findAllRemoteWithResponse:(NSError **)aError {
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@flavors/detail.xml", app.computeUrl]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	Response *res = [ORConnection sendRequest:request withAuthToken:app.authToken];	
	if([res isError] && aError) {
		*aError = res.error;
	}
	
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
	//return [self performSelector:@selector(fromXMLData:) withObject:[fakeResponse dataUsingEncoding:NSASCIIStringEncoding]];
	//return [self performSelector:@selector(fromJSONData:) withObject:res.body];
	//return [self performSelector:@selector(fromJSONData:) withObject:[fakeJSON dataUsingEncoding:NSASCIIStringEncoding]];
}


-(void) dealloc {
	[flavorId release];
	[flavorName release];
	[ram release];
	[disk release];
	[super dealloc];
}

@end
