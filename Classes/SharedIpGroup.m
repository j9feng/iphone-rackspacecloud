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
#import "Connection.h"

@implementation SharedIpGroup

@synthesize sharedIpGroupId, sharedIpGroupName, servers;

-(SharedIpGroup *) init {
	self.servers = [[NSMutableArray alloc] initWithCapacity:1];
	return self;
}

-(void)count {
	return;// nil;
	//return -1;
}

// Find all items 
+ (NSArray *)findAllRemoteWithResponse:(NSError **)aError {
		
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@shared_ip_groups/detail.xml", app.computeUrl]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [Connection sendRequest:request withAuthToken:app.authToken];
	
	NSLog([NSString stringWithFormat:@"app token: %@", app.authToken]);
	if([res isError] && aError) {
		*aError = res.error;
	}
	
	//NSString *fakeResponse = @"<sharedIpGroups xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\"><sharedIpGroup id=\"1234\" name=\"Shared IP Group 1\"><servers><server id=\"422\" /><server id=\"3445\" /></servers></sharedIpGroup><sharedIpGroup id=\"5678\" name=\"Shared IP Group 2\"><servers><server id=\"23203\"/><server id=\"2456\" /><server id=\"9891\" /></servers></sharedIpGroup></sharedIpGroups>";
	
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
	//return [self performSelector:@selector(fromXMLData:) withObject:[fakeResponse dataUsingEncoding:NSASCIIStringEncoding]];
}

-(void) dealloc {
	[sharedIpGroupId release];
	[sharedIpGroupName release];
	[servers release];
	[super dealloc];
}

@end
