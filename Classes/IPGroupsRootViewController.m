//
//  IPGroupsRootViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 6/20/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "IPGroupsRootViewController.h"
#import "RackspaceAppDelegate.h"
#import "ObjectiveResource.h"
#import "SharedIpGroup.h"
#import "SpinnerCell.h"
#import "IPGroupViewController.h"

@implementation IPGroupsRootViewController

@synthesize ipGroups;

BOOL ipGroupsLoaded = NO;

// thread to load containers
- (void) loadIPGroups {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	if (!ipGroupsLoaded && app.computeUrl) {
		[ObjectiveResourceConfig setSite:app.computeUrl];
		[ObjectiveResourceConfig setAuthToken:app.authToken];
		[ObjectiveResourceConfig setResponseType:JSONResponse];	
		
		//NSObject *o = [SharedIpGroup findAllRemoteWithResponse:nil];
		
		self.ipGroups = [NSMutableArray arrayWithArray:[SharedIpGroup findAllRemoteWithResponse:nil]];
		
		ipGroupsLoaded = YES;
		self.tableView.userInteractionEnabled = YES;
		[self.tableView reloadData];
	}
	[autoreleasepool release];	
	
}

- (void)viewWillAppear:(BOOL)animated {
	// set up the accelerometer for the "shake to refresh" feature
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 25)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];	
	
	[NSThread detachNewThreadSelector:@selector(loadIPGroups) toTarget:self withObject:nil];
	[super viewWillAppear:animated];
}

#pragma mark Table Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (ipGroupsLoaded) {
		return 50;
	} else {
		return 460;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (ipGroupsLoaded) {
		return [self.ipGroups count];
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (ipGroupsLoaded) {
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		
		SharedIpGroup *s = (SharedIpGroup *) [self.ipGroups objectAtIndex:indexPath.row];
		cell.textLabel.text = s.sharedIpGroupName;
		//cell.detailTextLabel.text = @"5 servers";
		
		cell.detailTextLabel.text = [s.servers description];
		
		if ([s.servers class] == NSClassFromString(@"NSCFString") || [s.servers count] == 0) {
			cell.detailTextLabel.text = @"0 servers"; // i have no idea why this happens
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		} else if ([s.servers count] == 1) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%i server", [s.servers count]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%i servers", [s.servers count]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		return cell;		
		
	} else {
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
	SharedIpGroup *s = (SharedIpGroup *) [self.ipGroups objectAtIndex:indexPath.row];
	if (!([s.servers class] == NSClassFromString(@"NSCFString") || [s.servers count] == 0)) {
		IPGroupViewController *vc = [[IPGroupViewController alloc] initWithNibName:@"IPGroupView" bundle:nil];
		vc.ipGroup = [self.ipGroups objectAtIndex:indexPath.row];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		[aTableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {	
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:YES];
	if (editing) {
		addButton.enabled = NO;
	} else {
		addButton.enabled = YES;
	}	
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	[self.tableView beginUpdates]; 
	if (editingStyle == UITableViewCellEditingStyleDelete) { 
		
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES]; 
		
		SharedIpGroup *ipGroup = (SharedIpGroup *) [self.ipGroups objectAtIndex:indexPath.row];
		[ipGroup destroyRemote];
		
		[self.ipGroups removeObjectAtIndex:indexPath.row];
	} 
	[self.tableView endUpdates];   
	[self.tableView reloadData];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
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
		ipGroupsLoaded = NO;
		[self.tableView reloadData];
		[NSThread detachNewThreadSelector:@selector(loadIPGroups) toTarget:self withObject:nil];
		
	}
}


- (void)dealloc {
	[ipGroups release];
    [super dealloc];
}


@end
