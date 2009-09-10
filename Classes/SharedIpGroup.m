//
//  SharedIpGroup.m
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "SharedIpGroup.h"
#import "ObjectiveResource.h"
#import "RackspaceAppDelegate.h"
#import "Response.h"
#import "ORConnection.h"

@implementation SharedIpGroup

@synthesize sharedIpGroupId, sharedIpGroupName, servers;

-(SharedIpGroup *) init {
	self.servers = [[NSMutableArray alloc] initWithCapacity:1];
	return self;
}

-(void)count {
	return;
}

// Find all items 
+ (NSArray *)findAllRemoteWithResponse:(NSError **)aError {
		
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@shared_ip_groups/detail.xml", app.computeUrl]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [ORConnection sendRequest:request withAuthToken:app.authToken];
	
	if ([res isError] && aError) {
		*aError = res.error;
	}
	
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
}

-(void) dealloc {
	[sharedIpGroupId release];
	[sharedIpGroupName release];
	[servers release];
	[super dealloc];
}

@end
