//
//  Object.m
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "CloudFilesObject.h"
#import "RackspaceAppDelegate.h"
#import "Connection.h"
#import "Response.h"
#import "Container.h"

@implementation CloudFilesObject

@synthesize name, hash, bytes, contentType, data;

@synthesize objects, object;

-(CloudFilesObject *)init {
	self.objects = [NSMutableArray arrayWithCapacity:10];
	return self;
}

-(NSString *)humanizedBytes {
	NSInteger b = [self.bytes intValue];
	NSString *result;	
	if (b >= 1024000000) {
		result = [NSString stringWithFormat:@"%.2f GB", b / 1024000000.0];
	} else if (b >= 1024000) {
		result = [NSString stringWithFormat:@"%.2f MB", b / 1024000.0];
	} else if (b >= 1024) {
		result = [NSString stringWithFormat:@"%.2f KB", b / 1024.0];
	} else {
		result = [NSString stringWithFormat:@"%@ bytes", self.bytes];
	}
	return result;
}

-(BOOL)createFileWithAccountName:(NSString *)accountName andContainerName:(NSString *)containerName {
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	//	PUT /<api version>/<account>/<container>/<object> HTTP/1.1 
	//Host: storage.clouddrive.com 
	//	X-Auth-Token: eaaafd18-0fed-4b3a-81b4-663c99ec1cbb 
	//ETag: 8a964ee2a5e88be344f36c22562a6486 
	//	Content-Length: 512000 
	//	X-Object-Meta-PIN: 1234 
	//	
	//	[ ... ] 
	
	NSLog([NSString stringWithFormat:@"File URL: %@", [NSString stringWithFormat:@"%@/%@/%@", app.storageUrl,  containerName, self.name]]);
	
	accountName = [Container urlencode:accountName];
	containerName = [Container urlencode:containerName];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", app.storageUrl, [containerName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"PUT"];
	NSLog([NSString stringWithFormat:@"Content-Length: %i", data.length]);
	[request setValue:[NSString stringWithFormat:@"%i", data.length] forHTTPHeaderField:@"Content-Length"];
	
	[request setValue:self.contentType forHTTPHeaderField:@"Content-Type"];
	
	//NSString *body = [NSString stringWithFormat:@"{ \"reboot\" : { \"type\" : \"%@\" } }", rebootType];
	//[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
	
	[request setHTTPBody:data];
	Response *response = [Connection sendRequest:request withAuthToken:app.authToken];	
	
	if ([response isError]) {
		NSLog(@"status code is not good");
		return NO;
	} else {
		return YES;
	}
	
}

-(void)dealloc {
	[name release];
	[hash release];
	[bytes release];
	[contentType release];
	
	[object release];
	[objects release];
	
	[data release];
	
	[super dealloc];
}

@end
