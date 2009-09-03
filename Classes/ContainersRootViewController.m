//
//  ContainersRootViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ContainersRootViewController.h"
#import "Account.h"
#import "Container.h"
#import "RackspaceAppDelegate.h"
#import "SpinnerCell.h"
#import "Response.h"
#import "ListObjectsViewController.h"

@implementation ContainersRootViewController

@synthesize account, cdnAccount;

BOOL containersLoaded = NO;

// thread to load containers
- (void) loadContainers {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	if (!containersLoaded) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		[ObjectiveResourceConfig setSite:app.storageUrl];	
		[ObjectiveResourceConfig setAuthToken:app.authToken];
		[ObjectiveResourceConfig setResponseType:JSONResponse];	
	
		self.account = [Account findRemote:@"1" withResponse:nil];
	
		self.cdnAccount = [Account findCDNRemote:@"1" withResponse:nil];
		
		// loop through the CDN containers and assign attributes to the regular containers
		// consider container name to be the key
		for (int i = 0; i < [self.account.containers count]; i++) {
			Container *container = [self.account.containers objectAtIndex:i];
			for (int j = 0; j < [self.cdnAccount.containers count]; j++) {
				Container *cdnContainer = [self.cdnAccount.containers objectAtIndex:j];
				if ([container.name isEqualToString:cdnContainer.name]) {
					container.cdnEnabled = cdnContainer.cdnEnabled;
					container.ttl = cdnContainer.ttl;
					container.logRetention = cdnContainer.logRetention;
					container.cdnUrl = cdnContainer.cdnUrl;
					break;
				}
			}
		}
		
		
		containersLoaded = YES;
		self.tableView.userInteractionEnabled = YES;
		[self.tableView reloadData];
	}
	[autoreleasepool release];	
	
}


- (void)viewWillAppear:(BOOL)animated {

	// set up the accelerometer for the "shake to refresh" feature
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 25)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];	
	
	//NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	[NSThread detachNewThreadSelector:@selector(loadContainers) toTarget:self withObject:nil];	
	//[autoreleasepool release];	
	
	//[self loadContainers];
	
//	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
//	[ObjectiveResourceConfig setSite:app.storageUrl];	
//	[ObjectiveResourceConfig setAuthToken:app.authToken];
//	[ObjectiveResourceConfig setResponseType:JSONResponse];	
//	
//	self.account = [Account findRemote:@"1" withResponse:nil];
//	
//	containersLoaded = YES;
//	self.tableView.userInteractionEnabled = YES;
//	[self.tableView reloadData];
	
	[super viewWillAppear:animated];
}

#pragma mark Table Methods

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 50;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (containersLoaded) {
		return [account.containers count];
	} else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (containersLoaded) {
		return 44; // this is the apple default
	} else {
		return 460;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (containersLoaded) {
		
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
    
		Container *c = (Container *) [account.containers objectAtIndex:indexPath.row];	
		cell.textLabel.text = c.name;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [c humanizedCount], [c humanizedBytes]];
	
		return cell;
		
	} else { // show the spinner cell

		static NSString *CellIdentifier = @"SpinnerCell";
		SpinnerCell *cell = (SpinnerCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SpinnerCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.userInteractionEnabled = NO;
			self.tableView.userInteractionEnabled = NO;
		}
		
		return cell;
	
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ListObjectsViewController *vc = [[ListObjectsViewController alloc] initWithNibName:@"ListObjects" bundle:nil];
	vc.account = self.account;
	vc.container = [account.containers objectAtIndex:indexPath.row];
	vc.containerName = vc.container.name;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];		
}

#pragma mark Shake Feature
- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	UIAccelerationValue length, x, y, z;
	
	// Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * 0.1 + myAccelerometer[0] * (1.0 - 0.1);
	myAccelerometer[1] = acceleration.y * 0.1 + myAccelerometer[1] * (1.0 - 0.1);
	myAccelerometer[2] = acceleration.z * 0.1 + myAccelerometer[2] * (1.0 - 0.1);
	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[1];
	z = acceleration.z - myAccelerometer[2];
	
	// Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);
	
	// see if they shook hard enough to refresh
	if (length >= 3.0) {
		//do what you want when there is a big shake here
		containersLoaded = NO;
		[self.tableView reloadData];
		[NSThread detachNewThreadSelector:@selector(loadContainers) toTarget:self withObject:nil];	
		
	}
}


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
	[account release];
	[cdnAccount release];
    [super dealloc];
}

@end
