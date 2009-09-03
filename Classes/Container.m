//
//  Container.m
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "Container.h"
#import "RackspaceAppDelegate.h"
#import "Response.h"
#import "Connection.h"

@implementation Container

@synthesize name, count, bytes, objects, object;

// CDN attributes
@synthesize cdnEnabled, ttl, logRetention, cdnUrl;

-(Container *)init {
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

-(NSString *)humanizedCount {
	NSInteger c = [self.count intValue];
	NSString *noun = @"files";
	if (c == 1) {
		noun = @"file";
	}
	return [NSString stringWithFormat:@"%i %@", c, noun];
}

-(NSString *)object {
	return object;
}

-(void)setObject:(NSString *)anObject {
	// viscious hack!  rackspace doesn't return a <object> inside of <objects>, so hack the setter
	// to pretend it's in a <objects> element
	if (!objects) {
		//objects = [NSMutableArray array];
		objects = [NSMutableArray arrayWithCapacity:10];
	}
	[objects addObject:anObject];
}

//simple API that encodes reserved characters according to:
//RFC 3986
//http://tools.ietf.org/html/rfc3986
+(NSString *) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", @" ", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", @"%20", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	
    return out;
}

// overriding because accounts don't follow the typical url format for restful resources
+ (id)findRemote:(NSString *)elementId withResponse:(NSError **)aError {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSLog(@"FULL URL");
	// not escaping!  yay!

	//NSLog([Container urlencode:[NSString stringWithFormat:@"%@/%@?format=xml", app.storageUrl, elementId]]);
	NSLog([NSString stringWithFormat:@"%@/%@?format=xml", app.storageUrl, [elementId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
	//NSLog([NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?format=xml", app.storageUrl, [Container urlencode:elementId]]]);

	NSLog([Container urlencode:elementId]);
	
	// https://storage.clouddrive.com/v1/MossoCloudFS_56ad0327-43d6-4ac4-9883-797f5690238e/overhrd.com?format=xml

	elementId = [Container urlencode:elementId];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?format=xml", app.storageUrl, [elementId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];	
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	Response *res = [Connection sendRequest:request withAuthToken:app.authToken];	
	if([res isError] && aError) {
		*aError = res.error;
	}
	//return [self performSelector:@selector(fromJSONData:) withObject:res.body];	
	return [self performSelector:@selector(fromXMLData:) withObject:res.body];
}

// example post:
//POST /<api version>/<account>/<container> HTTP/1.1 
//Host: cdn.clouddrive.com 
//X-Auth-Token: eaaafd18-0fed-4b3a-81b4-663c99ec1cbb 
//X-TTL: 86400 
//X-CDN-Enabled: True 
//X-Log-Retention: True 
- (Response *)save {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];	

	NSLog([NSString stringWithFormat:@"%@/%@?format=xml", app.cdnManagementUrl, [self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", app.storageUrl, [self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];	

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"PUT"];
	//[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	
	[request setValue:self.ttl forHTTPHeaderField:@"X-TTL"];
	[request setValue:self.cdnEnabled forHTTPHeaderField:@"X-CDN-Enabled"];
	//[request setValue:self.logRetention forHTTPHeaderField:@"X-Log-Retention"];
	
	NSString *body = @""; //[NSString stringWithFormat:@"{ \"resize\" : { \"flavorId\" : %@ } }", self.flavorId];
	[request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];		
	
	// look for X-CDN-URI header
	return [Connection sendRequest:request withAuthToken:app.authToken];
}



-(void)dealloc {
	[name release];
	[count release];
	[bytes release];
	[objects release];
	[cdnEnabled release];
	[ttl release];
	[logRetention release];
	[cdnUrl release];
	[super dealloc];
}

@end
