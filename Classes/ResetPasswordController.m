//
//  ResetPasswordController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/26/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ResetPasswordController.h"
#import "SecureEditableCell.h"
#import "Server.h"
#import "ServerViewController.h"
#import "RoundedRectView.h"
#import "Response.h"

@implementation ResetPasswordController

@synthesize passwordCell, confirmPasswordCell, server, serverViewController, spinnerView, footerView;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.passwordCell = [[SecureEditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"PasswordCell"];
		self.confirmPasswordCell = [[SecureEditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ConfirmPasswordCell"];
		
		self.passwordCell.labelField.text = @"Password";
		self.confirmPasswordCell.labelField.text = @"Confirm Password";
		
		self.navigationItem.title = @"Reset Password";
		
		self.passwordCell.textField.keyboardType = UIKeyboardTypeDefault;
		self.passwordCell.textField.delegate = self;	
		self.confirmPasswordCell.textField.keyboardType = UIKeyboardTypeDefault;
		self.confirmPasswordCell.textField.delegate = self;	
		
		//[self.passwordCell.textField becomeFirstResponder];
		
		// show a rounded rect view
		self.spinnerView = [[RoundedRectView alloc] initWithDefaultFrame];
		[self.view addSubview:self.spinnerView];

		self.tableView.scrollEnabled = NO;
		
    }
    return self;
}

- (void)viewDidLoad {
	
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, footerView.frame.size.height);
	footerView.backgroundColor = [UIColor clearColor];
	footerView.frame = newFrame;
	self.tableView.tableFooterView = self.footerView;	// note this will override UITableView's 'sectionFooterHeight' property

    [super viewDidLoad];	
}	
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Keyboard Handler

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if ([self.passwordCell.textField isFirstResponder]) {
		[self.confirmPasswordCell.textField becomeFirstResponder];
	} else {

		[self.confirmPasswordCell.textField resignFirstResponder];
		
		// see if they match, and if so, set it and pop the view controller
		if ([self.passwordCell.textField.text isEqualToString:@""] || [self.confirmPasswordCell.textField.text isEqualToString:@""]) {
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"The password and confirmation cannot be blank and must be the same value." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//			[alert show];
//			[alert release];
		} else if (![self.passwordCell.textField.text isEqualToString:self.confirmPasswordCell.textField.text]) {
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"The password and confirmation cannot be blank and must be the same value." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//			[alert show];
//			[alert release];
		} else {
			// all is well, so set it to the server object
			//self.server.newPassword = self.passwordCell.textField.text;
			//self.serverViewController.saveButton.enabled = YES;
			//[self.navigationController popToViewController:self.serverViewController animated:YES];
		}
	}
	
	return YES;
}


#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return @"Enter a new password";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"The root password will be updated and the server will be restarted. Please note that this process will only work if you have a user line for \"root\" in your passwd or shadow file.";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return passwordCell;
	} else {
		return confirmPasswordCell;
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
//	Flavor *flavor = [app.flavors objectAtIndex:indexPath.row];
//	self.server.flavorId = flavor.flavorId;
//	[aTableView reloadData];
//	self.serverViewController.saveButton.enabled = YES;
//	[self.serverViewController.tableView reloadData];
//	[self.navigationController popToViewController:serverViewController animated:YES];
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
	
	// see if they match, and if so, set it and pop the view controller
	if ([self.passwordCell.textField.text isEqualToString:@""] || [self.confirmPasswordCell.textField.text isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"The password and confirmation cannot be blank and must be the same value." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	} else if (![self.passwordCell.textField.text isEqualToString:self.confirmPasswordCell.textField.text]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"The password and confirmation cannot be blank and must be the same value." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	self.server.newPassword = self.passwordCell.textField.text;
	
	[self showSpinnerView];
	
	BOOL success = NO;
	BOOL overRateLimit = NO;
	// TODO: lose potentially wasteful save call
	
	Response *saveResponse = [self.server saveRemote];
	success = [saveResponse isSuccess];
	overRateLimit = (saveResponse.statusCode == 413);
	
	[self hideSpinnerView];
	
	if (!success) {
		UIAlertView *av;
		if (overRateLimit) {
			av = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
											message:@"Your new password was not saved because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later." 
										   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		} else {
			av = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
											message:@"Your new password was not saved.  Please check your connection or the data you entered." 
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
	[passwordCell release];
	[confirmPasswordCell release];
	[server release];
	[serverViewController release];
	[spinnerView release];
	[footerView release];
    [super dealloc];
}


@end
