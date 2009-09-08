//
//  ORConnection.m
//  
//
//  Created by Ryan Daigle on 7/30/08.
//  Copyright 2008 yFactorial, LLC. All rights reserved.
//

#import "ORConnection.h"
#import "Response.h"
#import "NSData+Additions.h"
#import "NSMutableURLRequest+ResponseType.h"
#import "ConnectionDelegate.h"

//#define debugLog(...) NSLog(__VA_ARGS__)
#ifndef debugLog(...)
	#define debugLog(...)
#endif

@implementation ORConnection

static float timeoutInterval = 5.0;

static NSMutableArray *activeDelegates;

+ (NSMutableArray *)activeDelegates {
	if (nil == activeDelegates) {
		activeDelegates = [NSMutableArray array];
		[activeDelegates retain];
	}
	return activeDelegates;
}

+ (void)setTimeout:(float)timeOut {
	timeoutInterval = timeOut;
}
+ (float)timeout {
	return timeoutInterval;
}

+ (void)logRequest:(NSURLRequest *)request to:(NSString *)url {
	debugLog(@"%@ -> %@", [request HTTPMethod], url);
	if([request HTTPBody]) {
		debugLog([[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] autorelease]);
	}
}

+ (Response *)sendAuthRequest:(NSString *)user andPassword:(NSString *)password {
	
	//lots of servers fail to implement http basic authentication correctly, so we pass the credentials even if they are not asked for
	
	NSURL *url = [NSURL URLWithString:@"https://auth.api.rackspacecloud.com/v1.0"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	if(user && password) {
		//NSString *authString = [[[NSString stringWithFormat:@"%@:%@",user, password] dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
		//[request addValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"]; 
		
		[request addValue:user forHTTPHeaderField:@"X-Auth-User"];
		[request addValue:password forHTTPHeaderField:@"X-Auth-Key"];
		
		NSString *escapedUser = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																					(CFStringRef)user, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
		NSString *escapedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																						(CFStringRef)password, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
		NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@:%@@%@",[url scheme],escapedUser,escapedPassword,[url host],nil];
		if([url port]) {
			[urlString appendFormat:@":%@",[url port],nil];
		}
		[urlString appendString:[url path]];
		if([url query]){
			[urlString appendFormat:@"?%@",[url query],nil];
		}
		[request setURL:[NSURL URLWithString:urlString]];
		[escapedUser release];
		[escapedPassword release];
	}
	
	
	[self logRequest:request to:[url absoluteString]];
	
	ConnectionDelegate *connectionDelegate = [[[ConnectionDelegate alloc] init] autorelease];
	
	[[self activeDelegates] addObject:connectionDelegate];
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate startImmediately:NO] autorelease];
	connectionDelegate.connection = connection;
	
	
	//use a custom runloop
	static NSString *runLoopMode = @"com.yfactorial.objectiveresource.connectionLoop";
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
	[connection start];
	while (![connectionDelegate isDone]) {
		[[NSRunLoop currentRunLoop] runMode:runLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.3]];
	}
	Response *resp = [Response responseFrom:(NSHTTPURLResponse *)connectionDelegate.response 
								   withBody:connectionDelegate.data 
								   andError:connectionDelegate.error];
	[resp log];
	
	[activeDelegates removeObject:connectionDelegate];
	
	//if there are no more active delegates release the array
	if (0 == [activeDelegates count]) {
		NSMutableArray *tempDelegates = activeDelegates;
		activeDelegates = nil;
		[tempDelegates release];
	}
	
	return resp;
}

+ (Response *)sendRequest:(NSMutableURLRequest *)request withUser:(NSString *)user andPassword:(NSString *)password {
	
	//lots of servers fail to implement http basic authentication correctly, so we pass the credentials even if they are not asked for
	NSURL *url = [request URL];
	if(user && password) {
		NSString *authString = [[[NSString stringWithFormat:@"%@:%@",user, password] dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
		[request addValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"]; 
		NSString *escapedUser = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																																								(CFStringRef)user, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
		NSString *escapedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																																										(CFStringRef)password, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
		NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@:%@@%@",[url scheme],escapedUser,escapedPassword,[url host],nil];
		if([url port]) {
			[urlString appendFormat:@":%@",[url port],nil];
		}
		[urlString appendString:[url path]];
		if([url query]){
			[urlString appendFormat:@"?%@",[url query],nil];
		}
		[request setURL:[NSURL URLWithString:urlString]];
		[escapedUser release];
		[escapedPassword release];
	}


	[self logRequest:request to:[url absoluteString]];
	
	ConnectionDelegate *connectionDelegate = [[[ConnectionDelegate alloc] init] autorelease];

	[[self activeDelegates] addObject:connectionDelegate];
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate startImmediately:NO] autorelease];
	connectionDelegate.connection = connection;

	
	//use a custom runloop
	static NSString *runLoopMode = @"com.yfactorial.objectiveresource.connectionLoop";
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
	[connection start];
	while (![connectionDelegate isDone]) {
		[[NSRunLoop currentRunLoop] runMode:runLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.3]];
	}
	Response *resp = [Response responseFrom:(NSHTTPURLResponse *)connectionDelegate.response 
								   withBody:connectionDelegate.data 
								   andError:connectionDelegate.error];
	[resp log];
	
	[activeDelegates removeObject:connectionDelegate];
	
	//if there are no more active delegates release the array
	if (0 == [activeDelegates count]) {
		NSMutableArray *tempDelegates = activeDelegates;
		activeDelegates = nil;
		[tempDelegates release];
	}
	
	return resp;
}


+ (Response *)sendRequest:(NSMutableURLRequest *)request withAuthToken:(NSString *)authToken {
	
	//lots of servers fail to implement http basic authentication correctly, so we pass the credentials even if they are not asked for
	NSURL *url = [request URL];
	if (authToken) {
		[request addValue:authToken forHTTPHeaderField:@"X-Auth-Token"];
		
		NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@",[url scheme],[url host],nil];
		if([url port]) {
			[urlString appendFormat:@":%@",[url port],nil];
		}
		[urlString appendString:[url path]];
		if([url query]){
			[urlString appendFormat:@"?%@",[url query],nil];
		}
		NSLog([NSString stringWithFormat:@"Final URL: %@", urlString]);
		[request setURL:[NSURL URLWithString:urlString]];
	}
	
	
	[self logRequest:request to:[url absoluteString]];
	
	ConnectionDelegate *connectionDelegate = [[[ConnectionDelegate alloc] init] autorelease];
	
	[[self activeDelegates] addObject:connectionDelegate];
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate startImmediately:NO] autorelease];
	connectionDelegate.connection = connection;
	
	
	//use a custom runloop
	static NSString *runLoopMode = @"com.yfactorial.objectiveresource.connectionLoop";
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
	[connection start];
	while (![connectionDelegate isDone]) {
		[[NSRunLoop currentRunLoop] runMode:runLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.3]];
	}
	Response *resp = [Response responseFrom:(NSHTTPURLResponse *)connectionDelegate.response 
								   withBody:connectionDelegate.data 
								   andError:connectionDelegate.error];
	[resp log];
	
	[activeDelegates removeObject:connectionDelegate];
	
	//if there are no more active delegates release the array
	if (0 == [activeDelegates count]) {
		NSMutableArray *tempDelegates = activeDelegates;
		activeDelegates = nil;
		[tempDelegates release];
	}
	
	return resp;
}

+ (Response *)post:(NSString *)body to:(NSString *)url {
	return [self post:body to:url withUser:@"X" andPassword:@"X"];
}

+ (Response *)sendBy:(NSString *)method withBody:(NSString *)body to:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:method];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	return [self sendRequest:request withUser:user andPassword:password];
}

+ (Response *)sendBy:(NSString *)method withBody:(NSString *)body to:(NSString *)url withAuthToken:(NSString *)authToken {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:method];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	return [self sendRequest:request withAuthToken:authToken];
}

+ (Response *)post:(NSString *)body to:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password{
	return [self sendBy:@"POST" withBody:body to:url withUser:user andPassword:password];
}

+ (Response *)post:(NSString *)body to:(NSString *)url withAuthToken:(NSString *)authToken {
	return [self sendBy:@"POST" withBody:body to:url withAuthToken:authToken];
}

+ (Response *)put:(NSString *)body to:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password{
	return [self sendBy:@"PUT" withBody:body to:url withUser:user andPassword:password];
}

+ (Response *)put:(NSString *)body to:(NSString *)url withAuthToken:authToken {
	return [self sendBy:@"PUT" withBody:body to:url withAuthToken:authToken];
}

+ (Response *)get:(NSString *)url {
	return [self get:url withUser:@"X" andPassword:@"X"];
}

+ (Response *)get:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"GET"];
	return [self sendRequest:request withUser:user andPassword:password];
}

+ (Response *)get:(NSString *)url withAuthToken:(NSString *)authToken {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"GET"];
	return [self sendRequest:request withAuthToken:authToken];
}

+ (Response *)delete:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"DELETE"];
	return [self sendRequest:request withUser:user andPassword:password];
}

+ (Response *)delete:(NSString *)url withAuthToken:(NSString *)authToken {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithUrl:[NSURL URLWithString:url] andMethod:@"DELETE"];
	return [self sendRequest:request withAuthToken:authToken];
}

+ (void) cancelAllActiveConnections {
	for (ConnectionDelegate *delegate in activeDelegates) {
		[delegate performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:NO];
	}
}

@end
