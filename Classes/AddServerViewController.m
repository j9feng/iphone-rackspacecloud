//
//  AddServerViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AddServerViewController.h"
#import "Server.h"
#import "ServerNameController.h"
#import "EditableCell.h"
#import "AddServerFlavorController.h"
#import "AddServerImageController.h"
#import "RackspaceAppDelegate.h"
#import "Flavor.h"
#import "Image.h"
#import "Response.h"
#import "ServersRootViewController.h"

#define kServerDetails 0
#define kFlavor 1
#define kImage 2

static UIImage *debianImage = nil;
static UIImage *gentooImage = nil;
static UIImage *ubuntuImage = nil;
static UIImage *archImage = nil;
static UIImage *centosImage = nil;
static UIImage *fedoraImage = nil;
static UIImage *rhelImage = nil;

@implementation AddServerViewController

@synthesize server, nameCell, serversRootViewController;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.server = [[Server alloc] init];
		self.server.serverName = @"";
		self.server.flavorId = @"";
		self.server.imageId = @"";
		self.nameCell = [[EditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NameCell"];
		self.nameCell.labelField.text = @"Name";
		self.nameCell.textField.placeholder = @"";
		self.nameCell.accessoryType = UITableViewCellAccessoryNone;		

		self.nameCell.textField.keyboardType = UIKeyboardTypeDefault;
		self.nameCell.textField.delegate = self;
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancelle" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonPressed:)];
	}
    return self;
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

- (UIImage *)imageForImage:(Image *)i {
	
	if ([i.imageId isEqualToString:@"2"]) {
		return centosImage;
	} else if ([i.imageId isEqualToString:@"3"]) {
		return gentooImage;
	} else if ([i.imageId isEqualToString:@"4"]) {
		return debianImage;
	} else if ([i.imageId isEqualToString:@"5"]) {
		return fedoraImage;
	} else if ([i.imageId isEqualToString:@"7"]) {
		return centosImage;
	} else if ([i.imageId isEqualToString:@"8"]) {
		return ubuntuImage;
	} else if ([i.imageId isEqualToString:@"9"]) {
		return archImage;
	} else if ([i.imageId isEqualToString:@"10"]) {
		return ubuntuImage;
	} else if ([i.imageId isEqualToString:@"11"]) {
		return ubuntuImage;
	} else if ([i.imageId isEqualToString:@"12"]) {
		return rhelImage;
	} else if ([i.imageId isEqualToString:@"13"]) {
		return archImage;
	} else if ([i.imageId isEqualToString:@"4056"]) {
		return fedoraImage;
	} else {		
		// might be a backup image, so look for the server id in the image
		// if a server is there, call imageForServer on it
		
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		
		
		Server *aServer = (Server *) [app.servers objectForKey:i.serverId];
		Image *image = [Image findLocalWithImageId:aServer.imageId];
		if (image) { // && image.serverId) {
			
			// find the image for the serverId
			// call imageForServer on that server
			return [self imageForImage:image];
		}
	}		
	return nil;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Table Delegate Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == kServerDetails) {
		return @"Server Details";
	} else if (section == kFlavor) {
		return @"Choose a Flavor";
	} else if (section == kImage) {
		return @"Choose an Image";
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	if (section == kServerDetails) {
		return 1;
	} else if (section == kFlavor) {
		return [app.flavors count];
	} else if (section == kImage) {
		return [app.images count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	flavorCell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:@"AddServerFlavorCell"];
	if (flavorCell == nil) {
		flavorCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddServerFlavorCell"] autorelease];
		flavorCell.accessoryType = UITableViewCellAccessoryNone;
	}

	imageCell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:@"AddServerImageCell"];
	if (imageCell == nil) {
		imageCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddServerImageCell"] autorelease];
		imageCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];

	if (indexPath.section == kServerDetails) {
		return self.nameCell;
	} else if (indexPath.section == kFlavor) {
		Flavor *flavor = (Flavor *) [app.flavors objectAtIndex:indexPath.row];
		flavorCell.textLabel.text = flavor.flavorName;
		flavorCell.detailTextLabel.text = [NSString stringWithFormat:@"%@MB RAM - %@GB Disk", flavor.ram, flavor.disk];
		
		// show or hide selection style
		if ([flavor.flavorId isEqualToString:self.server.flavorId]) {
			flavorCell.accessoryType = UITableViewCellAccessoryCheckmark;
			flavorCell.textLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
			flavorCell.detailTextLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
			[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			flavorCell.accessoryType = UITableViewCellAccessoryNone;
			flavorCell.textLabel.textColor = [UIColor blackColor];
			flavorCell.detailTextLabel.textColor = [UIColor blackColor];
		}
		
		return flavorCell;
	} else if (indexPath.section == kImage) {
		Image *image = (Image *) [app.images objectAtIndex:indexPath.row];
		
		imageCell.textLabel.text = image.imageName;
		imageCell.imageView.image = [self imageForImage:image];

		// show or hide selection style
		if ([image.imageId isEqualToString:self.server.imageId]) {
			imageCell.accessoryType = UITableViewCellAccessoryCheckmark;
			imageCell.textLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
			[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			imageCell.accessoryType = UITableViewCellAccessoryNone;
			imageCell.textLabel.textColor = [UIColor blackColor];
			
		}
		
		return imageCell;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kServerDetails) {
		ServerNameController *vc = [[ServerNameController alloc] initWithNibName:@"ServerNameController" bundle:nil];
		vc.addServerViewController = self;
		[self.navigationController presentModalViewController:vc animated:YES];
		[vc release];
	} else if (indexPath.section == kFlavor) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		Flavor *flavor = [app.flavors objectAtIndex:indexPath.row];
		self.server.flavorId = flavor.flavorId;
		[aTableView reloadData];
	} else if (indexPath.section == kImage) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		Image *image = [app.images objectAtIndex:indexPath.row];
		self.server.imageId = image.imageId;
		[aTableView reloadData];
	}
	//[aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Keyboard Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self.server.serverName = textField.text;
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.server.serverName = textField.text;
	NSLog([NSString stringWithFormat:@"server name = %@", self.server.serverName]);
	[textField resignFirstResponder];
	return YES;
}

#pragma mark Button Handlers

-(void) cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void) saveButtonPressed:(id)sender {
	
	self.server.serverName = self.nameCell.textField.text;
	
	// check for a name, flavor, and image
	BOOL isValid = ![self.server.serverName isEqualToString:@""] && ![self.server.flavorId isEqualToString:@""] && ![self.server.imageId isEqualToString:@""];
	
	if (isValid) {
		
		// send the save request
		Response *response = [self.server create];
		
		if ([response isSuccess]) {
			// set serversRootController serversLoaded = NO to refresh the list
			self.serversRootViewController.serversLoaded = NO;
			[self.serversRootViewController.tableView reloadData];

			[self dismissModalViewControllerAnimated:YES];
		} else {
			// handle 413 for rate limit, or isSuccess
			UIAlertView *alert;			
			if (response.statusCode == 413) {				
				alert = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
												   message:@"Your server was not saved because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later." 
												  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			} else {
				alert = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
												   message:@"Your server was not saved.  Please check your connection or the data you entered and try again." 
												  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			}
			[alert show];
			[alert release];
		}
		
	} else { // it's not valid to post
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"All fields are required." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
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
	[nameCell release];
	[serversRootViewController release];
    [super dealloc];
}


@end
