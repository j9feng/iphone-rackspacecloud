//
//  LoginViewController.m
//  Rackspace Cloud
//
//  Created by Michael Mayo on 4/11/09.
//  Copyright 2009 Rackspace Cloud. All rights reserved.
//

#import "LoginViewController.h"
#import "EditableLoginCell.h"
#import "SecureEditableLoginCell.h"
#import "RackspaceAppDelegate.h"
#import "ORConnection.h"
#import "Response.h"
#import "Flavor.h"
#import "Image.h"

@implementation LoginViewController

@synthesize tableView, usernameCell, apiKeyCell, backgroundImage, spinnerView;

- (void)viewWillAppear:(BOOL)animated {
	
	usernameCell = [[EditableLoginCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UsernameCell"];
	apiKeyCell = [[SecureEditableLoginCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ApiKeyCell"];	
	
	// pre-load the text box values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	usernameCell.textField.text = [defaults stringForKey:@"username_preference"];
	apiKeyCell.textField.text = [defaults stringForKey:@"api_key_preference"];
	
	tableView.backgroundColor = [UIColor clearColor];
	
	self.spinnerView.hidden = YES;
	
	if (usernameCell.textField.text && apiKeyCell.textField.text 
			&& ![usernameCell.textField.text isEqualToString:@""]
			&& ![apiKeyCell.textField.text isEqualToString:@""]) {
		self.spinnerView.hidden = NO;
		self.tableView.hidden = YES;
	} else {
		// choose which text box to default to
		if (usernameCell.textField.text
			&& ![usernameCell.textField.text isEqualToString:@""]) {
			[apiKeyCell.textField becomeFirstResponder];
		} else {
			[usernameCell.textField becomeFirstResponder];	
		}
	}		
	
    [super viewWillAppear:animated];
}

- (void)handleSuccessfulLogin:(Response *)response {

	// load the app delegate with server and auth info for the other controllers
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	//app.computeUrl = [response.headers objectForKey:@"X-Compute-Url"];
	app.computeUrl = [NSString stringWithFormat:@"%@/", [response.headers objectForKey:@"X-Server-Management-Url"]];
	app.storageUrl = [response.headers objectForKey:@"X-Storage-Url"];
	app.cdnManagementUrl = [response.headers objectForKey:@"X-Cdn-Management-Url"];
	app.authToken = [response.headers objectForKey:@"X-Auth-Token"];
	
	// load flavors and images here
	app.flavors = [NSMutableArray arrayWithArray:[Flavor findAllRemoteWithResponse:nil]];
	app.images = [NSMutableArray arrayWithArray:[Image findAllRemoteWithResponse:nil]];
	
	NSMutableArray *newImages = [[NSMutableArray alloc] initWithCapacity:10];
	// remove images that don't have status of ACTIVE
	for (int i = 0; i < [app.images count]; i++) {
		Image *image = (Image *) [app.images objectAtIndex:i];
		if ([image.status isEqualToString:@"ACTIVE"]) {
			[newImages addObject:image];
		}
	}
	
	app.images = [NSMutableArray arrayWithArray:newImages];
	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	CGRect disappearFrame = self.view.frame;
	disappearFrame.origin.x -= 320;
	self.view.frame = disappearFrame;	
	[UIView commitAnimations];
	
	// force the servers list to actually load
	[NSThread detachNewThreadSelector:@selector(loadServers) toTarget:app.serversRootViewController withObject:nil];	
	
}

- (void)handleFailedLogin {
	// animate or alert failure, and then show the login fields
	self.tableView.alpha = 0.0;
	self.tableView.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75];
	self.tableView.alpha = 1.0;
	self.spinnerView.alpha = 0.0;
	[UIView commitAnimations];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failure" 
											  message:@"Please check your User Name and API Key."
											  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	// put focus on user name text box
	[self.usernameCell.textField becomeFirstResponder];
}

- (void)handleFailedConnection {
	// animate or alert failure, and then show the login fields
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75];
	self.spinnerView.alpha = 0.0;
	[UIView commitAnimations];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" 
													message:@"Please check your connection and try again."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
}


// this is called after the control/spinner fade in animation completes
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSString *userName = [defaults stringForKey:@"username_preference"];
	NSString *apiKey = [defaults stringForKey:@"api_key_preference"];
	
	// only try to authenticate if a user name and api key are provided
	if (userName && ![userName isEqualToString:@""] && apiKey && ![apiKey isEqualToString:@""]) {
		Response *response = [ORConnection sendAuthRequest:userName andPassword:apiKey];
		
		if (response.statusCode == 204) {
			[self handleSuccessfulLogin:response];
		} else if (response.statusCode == 0) { // connection failure
			[self handleFailedConnection];
		} else { // authentication failure
			[self handleFailedLogin];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	
	CGRect vr = self.view.frame;
	vr.size.height += 20; // makes it black all the way to the bottom
	self.view.frame = vr;
	
	// pull up the logo for a sexy effect
	CGRect r = self.backgroundImage.frame;
	r.origin.y -= 120;
	
	self.tableView.alpha = 0.0;
	self.spinnerView.alpha = 0.0;
	
	// logo pull up animation block
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75];
	self.backgroundImage.frame = r;
	[UIView commitAnimations];
	
	// text box or spinner fade in animation block
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:1.75];
	[UIView setAnimationDelegate:self]; // delegate for sending auth request if necessary
	self.tableView.alpha = 1.0;
	self.spinnerView.alpha = 1.0;
	[UIView commitAnimations];
	
    [super viewDidAppear:animated];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6; // doing this to push the first row down a bit
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	if (section == 5) {
		return 2;
	} else {
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    EditableLoginCell *cell = (EditableLoginCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[EditableLoginCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    	
	usernameCell.textField.keyboardType = UIKeyboardTypeDefault;
	usernameCell.textField.delegate = self;	
	apiKeyCell.textField.keyboardType = UIKeyboardTypeDefault;
	apiKeyCell.textField.delegate = self;	
	
    // Set up the cell...
	if (indexPath.row == 0) {
		usernameCell.labelField.text = @"User Name";
		return usernameCell;
	} else {
		apiKeyCell.labelField.text = @"API Key";
		return apiKeyCell;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	CGRect r = self.view.frame;
//	r.origin.y += 720;
//	
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.65];
//	
//	self.view.frame = r;
//	
//	[UIView commitAnimations];
	
	
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject:self.usernameCell.textField.text forKey:@"username_preference"];
	[defaults setObject:self.apiKeyCell.textField.text forKey:@"api_key_preference"];
	
	if ([self.usernameCell.textField isFirstResponder]) {
		[self.apiKeyCell.textField becomeFirstResponder];
	} else {
		
	}

	if (usernameCell.textField.text && apiKeyCell.textField.text 
		&& ![usernameCell.textField.text isEqualToString:@""]
		&& ![apiKeyCell.textField.text isEqualToString:@""]) {
		
		// only attempt login if pressing return from the api key field
		if (textField == self.apiKeyCell.textField) {		
			self.spinnerView.alpha = 0.0;
			self.spinnerView.hidden = NO;
		
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			self.tableView.alpha = 0.0;
			[UIView commitAnimations];

			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationDelay:0.75];
			[UIView setAnimationDelegate:self]; // delegate for sending auth request if necessary
			self.spinnerView.alpha = 1.0;
			[UIView commitAnimations];
		}
		
		
	}
	
	
	[textField resignFirstResponder];
	[self.tableView reloadData];
	
	return YES;
}

- (void)dealloc {
	[usernameCell release];
	[apiKeyCell release];
	[tableView release];
	[backgroundImage release];
	[spinnerView release];
    [super dealloc];
}


@end

