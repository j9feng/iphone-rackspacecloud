//
//  RackspaceAppDelegate.m
//  Rackspace
//
//  Created by Michael Mayo on 5/25/09.
//  Copyright Rackspace Hosting 2009. All rights reserved.
//

#import "RackspaceAppDelegate.h"
#import "LoginViewController.h"
#import "ObjectiveResource.h"
#import "ServersRootViewController.h"

@implementation RackspaceAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize loginViewController;
@synthesize usernamePreference, apiKeyPreference;
@synthesize computeUrl;
@synthesize storageUrl;
@synthesize cdnManagementUrl;
@synthesize authToken;
@synthesize serversRootViewController;
@synthesize flavors, images, servers;
@synthesize imageScrollView;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    	
	[ObjectiveResourceConfig setResponseType:JSONResponse];	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	self.usernamePreference = [defaults stringForKey:@"username_preference"];
	self.apiKeyPreference = [defaults stringForKey:@"api_key_preference"];

	[window addSubview:tabBarController.view];	
	
	loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];	
	[window addSubview:loginViewController.view];
	
}

- (void)dealloc {
    [tabBarController release];
	[loginViewController release];
    [window release];
	[usernamePreference release];
	[apiKeyPreference release];
	[computeUrl release];
	[storageUrl release];
	[cdnManagementUrl release];
	[authToken release];
	[serversRootViewController release];
	[flavors release];
	[images release];
	[servers release];
	[imageScrollView release];
    [super dealloc];
}

@end

