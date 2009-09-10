//
//  Server.m
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "Server.h"
#import "ObjectiveResource.h"
#import "RackspaceAppDelegate.h"
#import "Response.h"
#import "ORConnection.h"
#import "Image.h"
#import "Flavor.h"

@implementation Server

@synthesize serverId, serverName, imageId, flavorId, hostId, addresses, serverMetaData, status, progress, newPassword;

- (Response *)resize {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers/%@/action", app.computeUrl, self.serverId]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	NSString *body = [NSString stringWithFormat:@"{ \"resize\" : { \"flavorId\" : %@ } }", self.flavorId];
	[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];		
	return [ORConnection sendRequest:request withAuthToken:app.authToken];
}

- (Response *)confirmResize {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers/%@/action", app.computeUrl, self.serverId]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	NSString *body = @"{ \"confirmResize\" : null }";
	[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];		
	return [ORConnection sendRequest:request withAuthToken:app.authToken];
}

- (Response *)revertResize {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers/%@/action", app.computeUrl, self.serverId]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	NSString *body = @"{ \"revertResize\" : null }";
	[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];		
	return [ORConnection sendRequest:request withAuthToken:app.authToken];
}

- (Response *)saveRemote {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers/%@", app.computeUrl, self.serverId]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"PUT"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSString *body;
	
	if (self.newPassword) {
		body = [NSString stringWithFormat:@"{ \"server\" : { \"name\" : \"%@\", \"adminPass\" : \"%@\" } }", self.serverName, self.newPassword];
	} else {
		body = [NSString stringWithFormat:@"{ \"server\" : { \"name\" : \"%@\" } }", self.serverName];
	}	
	[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];	
	
	return [ORConnection sendRequest:request withAuthToken:app.authToken];
}

+ (Server *)findRemoteWithId:(NSString *)serverId andResponse:(NSError **)aError {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers/%@.xml", app.computeUrl, serverId]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [ORConnection sendRequest:request withAuthToken:app.authToken];
	
	if ([res isError] && aError) {
		*aError = res.error;
	}
	
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
}

// Find all items 
+ (NSArray *)findAllRemoteWithResponse:(NSError **)aError {
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers/detail.xml", app.computeUrl]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [ORConnection sendRequest:request withAuthToken:app.authToken];
	
	if ([res isError] && aError) {
		*aError = res.error;
	}
	
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
}

-(Response *)sendRebootRequest:(NSString *)rebootType {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers/%@/action", app.computeUrl, self.serverId]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	NSString *body = [NSString stringWithFormat:@"{ \"reboot\" : { \"type\" : \"%@\" } }", rebootType];
	[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];	
	return [ORConnection sendRequest:request withAuthToken:app.authToken];	
}

-(Response *)create {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@servers", app.computeUrl, self.serverId]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	NSString *body = [NSString stringWithFormat:@"{ \"server\" : { \"name\" : \"%@\", \"imageId\" : %@, \"flavorId\" : %@ } }", self.serverName, self.imageId, self.flavorId];
	[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];		
	return [ORConnection sendRequest:request withAuthToken:app.authToken];
}

-(Response *)softReboot {
	return [self sendRebootRequest:@"SOFT"];
}

-(Response *)hardReboot {
	return [self sendRebootRequest:@"HARD"];
}

-(NSString *)imageName {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	for (int i = 0; i < [app.images count]; i++) {
		Image *image = [app.images objectAtIndex:i];
		if ([image.imageId isEqualToString:self.imageId]) {
			return image.imageName;
		}
	}
	return @"";
}

-(NSString *)flavorName {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	for (int i = 0; i < [app.flavors count]; i++) {
		Flavor *flavor = [app.flavors objectAtIndex:i];
		if ([flavor.flavorId isEqualToString:self.flavorId]) {
			return flavor.flavorName;
		}
	}
	return @"";
}

-(void) dealloc {
	[serverId release];
	[serverName release];
	[imageId release];
	[flavorId release];
	[hostId release];
	[addresses release];
	[serverMetaData release];
	[status release];
	[progress release];
	[newPassword release];
	[super dealloc];
}

@end
