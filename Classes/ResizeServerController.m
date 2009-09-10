//
//  ResizeServerController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/21/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ResizeServerController.h"
#import "RackspaceAppDelegate.h"
#import "Flavor.h"
#import "Server.h"
#import "ServerViewController.h"
#import "RoundedRectView.h"
#import "Response.h"
#import "ServersRootViewController.h"

@implementation ResizeServerController

@synthesize server, serverViewController, spinnerView, serversRootViewController;

NSString *initialFlavorId;
NSString *selectedFlavorId;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.navigationItem.title = @"Resize Server";
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonPressed:)];		
		self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// show a rounded rect view
	self.spinnerView = [[RoundedRectView alloc] initWithDefaultFrame];
	[self.view addSubview:self.spinnerView];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	// save the original flavor
	initialFlavorId = [self.server.flavorId copy];
	selectedFlavorId = initialFlavorId;
	
	[super viewWillAppear:animated];
}

#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return @"Choose a Flavor";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	return [app.flavors count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"ChooseFlavorCell";
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	Flavor *flavor = [app.flavors objectAtIndex:indexPath.row];
	cell.textLabel.text = flavor.flavorName;
	
	if ([flavor.flavorId isEqualToString:selectedFlavorId]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@MB RAM - %@GB Disk", flavor.ram, flavor.disk];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	Flavor *flavor = [app.flavors objectAtIndex:indexPath.row];
	selectedFlavorId = flavor.flavorId;
	
	if (![initialFlavorId isEqualToString:selectedFlavorId]) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	} else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	
	[aTableView reloadData];
}

#pragma mark Spinner Methods

- (void)showSpinnerViewInThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.tableView.contentOffset = CGPointMake(0, 0);
	[self.spinnerView show];
	[pool release];
}

- (void)hideSpinnerViewInThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self.spinnerView hide];
	[pool release];
}

- (void)showSpinnerView {
	self.view.userInteractionEnabled = NO;
	[NSThread detachNewThreadSelector:@selector(showSpinnerViewInThread) toTarget:self withObject:nil];
}

- (void)hideSpinnerView {
	self.view.userInteractionEnabled = YES;
	[NSThread detachNewThreadSelector:@selector(hideSpinnerViewInThread) toTarget:self withObject:nil];
}

#pragma mark Button Handlers

- (void)saveButtonPressed:(id)sender {
	
	self.server.flavorId = selectedFlavorId;
	
	[self showSpinnerView];
	
	BOOL success = NO;
	BOOL overRateLimit = NO;
	
	if (![self.server.flavorId isEqualToString:initialFlavorId]) {
		
		Response *response = [self.server resize];
		success = [response isSuccess];
		overRateLimit = (response.statusCode == 413);

	}
	
	[self hideSpinnerView];
	
	if (success) {
		// all is well, so disable the save button and hide the keyboard
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		// force the servers list to refresh
		self.serversRootViewController.serversLoaded = NO;
		[self.serversRootViewController.tableView reloadData];
		
		// fake out the first resize status to force the server view to poll progress
		self.server.status = @"QUEUE_RESIZE";
		self.server.progress = @"0";

		[self.serverViewController detachProgressPollingThread];
		
		// pop back to server view
		[self.serverViewController.tableView reloadData];
		[self.navigationController popToViewController:serverViewController animated:YES];
		
	} else {
		UIAlertView *av;
		if (overRateLimit) {
			av = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
											message:@"Your server was not resized because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later." 
										   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		} else {
			av = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
											message:@"Your server was not resized.  Please check your connection or the data you entered." 
										   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		}
	    [av show];
		[av release];
	}
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
	[server release];
	[serverViewController release];
	[spinnerView release];
	[serversRootViewController release];
    [super dealloc];
}


@end
