//
//  Image.m
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "Image.h"
#import "ObjectiveResource.h"
#import "RackspaceAppDelegate.h"
#import "Response.h"
#import "ORConnection.h"
#import "Server.h"

@implementation Image

@synthesize imageId, imageName, timeStamp, status, progress, serverId;

- (NSString *)imageName {
	NSString *name = imageName;
	if (self.serverId) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
		Server *aServer = (Server *) [app.servers objectForKey:self.serverId];	
		if (aServer) {
			name = [NSString stringWithFormat:@"%@ (%@)", imageName, aServer.serverName];
		}
	} 
	return name;
}

// Find all items 
+ (NSArray *)findAllRemoteWithResponse:(NSError **)aError {
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@images/detail.xml", app.computeUrl]];
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

+ (Image *)findLocalWithImageId:(NSString *)imageId {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	Image *image = nil;
	for (int i = 0; i < [app.images count]; i++) {
		Image *tempImage = (Image *) [app.images objectAtIndex:i];
		if ([tempImage.imageId isEqualToString:imageId]) {
			image = tempImage;
			break;
		}
	}
	return image;
}

-(void) dealloc {
	[imageId release];
	[imageName release];
	[timeStamp release];
	[status release];
	[progress release];
	[serverId release];
	[super dealloc];
}

@end
