//
//  Object.m
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "CloudFilesObject.h"
#import "RackspaceAppDelegate.h"
#import "ORConnection.h"
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
	
	accountName = [Container urlencode:accountName];
	containerName = [Container urlencode:containerName];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", app.storageUrl, [containerName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"PUT"];
	[request setValue:[NSString stringWithFormat:@"%i", data.length] forHTTPHeaderField:@"Content-Length"];
	[request setValue:self.contentType forHTTPHeaderField:@"Content-Type"];	
	[request setHTTPBody:data];
	Response *response = [ORConnection sendRequest:request withAuthToken:app.authToken];	
	
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
