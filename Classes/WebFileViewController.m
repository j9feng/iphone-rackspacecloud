//
//  WebFileViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 8/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebFileViewController.h"
#import "CloudFilesObject.h"
#import "Container.h"

@implementation WebFileViewController

@synthesize cfObject, webView, container;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = @"Preview";		
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.container.cdnUrl, self.cfObject.name];
	//NSURL *url = [[NSURL alloc] initWithString:@"http://c0162922.cdn.cloudfiles.rackspacecloud.com/mike.jpeg"];
	NSLog(urlString);
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url]; 
	[self.webView loadRequest: request];
	self.webView.scalesPageToFit = YES;
	
	[request release]; 
	[url release]; 	
	[super viewWillAppear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[cfObject release];
	[webView release];
	[container release];
    [super dealloc];
}


@end
