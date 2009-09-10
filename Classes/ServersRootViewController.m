//
//  ServersRootViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 6/20/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ServersRootViewController.h"
#import "ServerCell.h"
#import "SpinnerCell.h"
#import "Server.h"
#import "RackspaceAppDelegate.h"
#import "ServerViewController.h"
#import "AddServerViewController.h"
#import "Image.h"

static UIImage *debianImage = nil;
static UIImage *gentooImage = nil;
static UIImage *ubuntuImage = nil;
static UIImage *archImage = nil;
static UIImage *centosImage = nil;
static UIImage *fedoraImage = nil;
static UIImage *rhelImage = nil;

@implementation ServersRootViewController

@synthesize servers, serversLoaded;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem.enabled = NO;	
	[super viewDidLoad];
}

+ (void)initialize {
    // The images are cached as part of the class, so they need to be explicitly retained.
	debianImage = [[UIImage imageNamed:@"debian.png"] retain];
	gentooImage = [[UIImage imageNamed:@"gentoo.png"] retain];
	ubuntuImage = [[UIImage imageNamed:@"ubuntu.png"] retain];
	archImage = [[UIImage imageNamed:@"arch.png"] retain];
	centosImage = [[UIImage imageNamed:@"centos.png"] retain];
	fedoraImage = [[UIImage imageNamed:@"fedora.png"] retain];
	rhelImage = [[UIImage imageNamed:@"rhel.png"] retain];
}

// thread to load servers
- (void) loadServers {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];

	if (!serversLoaded && app.computeUrl) {
		
		[ObjectiveResourceConfig setSite:app.computeUrl];
		[ObjectiveResourceConfig setAuthToken:app.authToken];
		[ObjectiveResourceConfig setResponseType:JSONResponse];	
		
		self.servers = [NSMutableArray arrayWithArray:[Server findAllRemoteWithResponse:nil]];
		app.servers = [[NSMutableDictionary alloc] initWithCapacity:1];
		
		for (int i = 0; i < [self.servers count]; i++) {
			Server *s = (Server *) [self.servers objectAtIndex:i];
			[app.servers setObject:s forKey:s.serverId];
		}
		
		serversLoaded = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		
		self.tableView.userInteractionEnabled = YES;
		[self.tableView reloadData];
	}
	[autoreleasepool release];	
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	// set up the accelerometer for the "shake to refresh" feature
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 25)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];	

	if (!serversLoaded) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		app.serversRootViewController = self;	
		[NSThread detachNewThreadSelector:@selector(loadServers) toTarget:self withObject:nil];	
	}
	
	[super viewWillAppear:animated];
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
		serversLoaded = NO;
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self.tableView reloadData];
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		app.serversRootViewController = self;	
		[NSThread detachNewThreadSelector:@selector(loadServers) toTarget:self withObject:nil];	
		
	}
}



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		serversLoaded = NO;
    }
    return self;
}

#pragma mark Table Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (serversLoaded) {
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
	if (serversLoaded) {
		return [self.servers count];
	} else {
		return 1;
	}
}

- (UIImage *)imageForServer:(Server *)s {
	
	if ([s.imageId isEqualToString:@"2"]) {
		return centosImage;
	} else if ([s.imageId isEqualToString:@"3"]) {
		return gentooImage;
	} else if ([s.imageId isEqualToString:@"4"]) {
		return debianImage;
	} else if ([s.imageId isEqualToString:@"5"]) {
		return fedoraImage;
	} else if ([s.imageId isEqualToString:@"7"]) {
		return centosImage;
	} else if ([s.imageId isEqualToString:@"8"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"9"]) {
		return archImage;
	} else if ([s.imageId isEqualToString:@"10"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"11"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"12"]) {
		return rhelImage;
	} else if ([s.imageId isEqualToString:@"13"]) {
		return archImage;
	} else if ([s.imageId isEqualToString:@"4056"]) {
		return fedoraImage;
	} else {		
		// might be a backup image, so look for the server id in the image
		// if a server is there, call imageForServer on it
		
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];

		s.imageId;
		
		Image *image = [Image findLocalWithImageId:s.imageId];
		if (image && image.serverId) {
			
			// find the image for the serverId
			// call imageForServer on that server
			Server *server = (Server *) [app.servers objectForKey:image.serverId];
			return [self imageForServer:server];
		}
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (serversLoaded) {
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		Server *s = (Server *) [servers objectAtIndex:indexPath.row];
		cell.textLabel.text = s.serverName;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [s flavorName], [s imageName]];
		cell.imageView.image = [self imageForServer:s];
		
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
	ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerView" bundle:nil];
	vc.server = [servers objectAtIndex:indexPath.row];
	vc.serversRootViewController = self;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];		
}

#pragma mark Button Handlers

-(void) addButtonPressed:(id)sender {
	AddServerViewController *vc = [[AddServerViewController alloc] initWithNibName:@"AddServer" bundle:nil];
	vc.serversRootViewController = self;
	[self.navigationController presentModalViewController:vc animated:YES];
	[vc release];
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
	[servers release];
    [super dealloc];
}


@end
