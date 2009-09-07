//
//  WebFileViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 8/29/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "WebFileViewController.h"
#import "CloudFilesObject.h"
#import "Container.h"

@implementation WebFileViewController

@synthesize cfObject, webView, container, spinner, loadingLabel;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = @"Preview";
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.container.cdnUrl, self.cfObject.name];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url]; 
	[self.webView loadRequest: request];
	self.webView.scalesPageToFit = YES;
	
	[request release]; 
	[url release]; 	
	[super viewWillAppear:animated];
}

#pragma mark Web View Delegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
	self.webView.userInteractionEnabled = NO;
	spinner.hidden = NO;
	loadingLabel.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	self.webView.userInteractionEnabled = YES;
	spinner.hidden = YES;
	loadingLabel.hidden = YES;
}

#pragma mark Memory Management

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
	webView.delegate = nil; // you must get rid of the delegate before releasing
	[webView release];
	[spinner release];
	[loadingLabel release];
	[container release];
    [super dealloc];
}


@end
