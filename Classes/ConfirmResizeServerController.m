//
//  ConfirmResizeServerController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/25/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ConfirmResizeServerController.h"
#import "Server.h"
#import "ServerViewController.h"
#import "Response.h"

@implementation ConfirmResizeServerController

@synthesize server, serverViewController;
@synthesize confirmSpinner, rollbackSpinner;

BOOL sendingRequest = NO;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.navigationItem.title = @"Verify Resize";
    }
    return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Is everything working properly?";
	} else {
		return @"Would you like to revert back to the original size?";
	} 
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"After verification, the old server will be deleted and will be billed at a prorated amount.";
	} else {
		return @"If no verification is made, the resize will be automatically verified after 12 hours.";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor = [UIColor colorWithRed:0.222 green:0.326 blue:0.540 alpha:1.0];
	}
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	CGRect r = spinner.frame;
	r.origin.x += 280;
	r.origin.y += 13;
	spinner.frame = r;
	[cell addSubview:spinner];
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Confirm Resize";
		self.confirmSpinner = spinner;
	} else {
		cell.textLabel.text = @"Rollback Resize";
		self.rollbackSpinner = spinner;
	}	
	
	return cell;		
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!sendingRequest) {
		sendingRequest = YES;
		if (indexPath.section == 0) {
			[self.confirmSpinner startAnimating];
			[NSThread detachNewThreadSelector:@selector(confirmResize:) toTarget:self withObject:self.serverViewController];			
		} else {
			[self.rollbackSpinner startAnimating];
			[NSThread detachNewThreadSelector:@selector(revertResize:) toTarget:self withObject:self.serverViewController];			
		}
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		[aTableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

#pragma mark Server Requests

- (void) reloadTableData {
	[self.serverViewController.tableView reloadData];
}

- (void) stopConfirmSpinner {
	[self.confirmSpinner stopAnimating];
}

- (void) stopRollbackSpinner {
	[self.rollbackSpinner stopAnimating];
}

- (void) setServerStatus:(Server *)aServer {
	self.serverViewController.server.status = aServer.status;
	//self.serverViewController.server.status = @"WTF";
	[self reloadTableData];
}

- (void) confirmResize:(ServerViewController *)svc {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Response *response = [self.server confirmResize];
	
	if ([response isSuccess]) {
		BOOL statusChanged = NO;
		
		while (!statusChanged) {
			Server *s = [Server findRemoteWithId:self.server.serverId andResponse:nil];
			if (s) {
				svc.server.flavorId = [s.flavorId copy];
				if (![self.serverViewController.server.status isEqualToString:s.status]) {
					statusChanged = YES;
					svc.server.status = [s.status copy];
					//svc.server.status = @"WTF";
					[self performSelectorOnMainThread:@selector(setServerStatus:) withObject:s waitUntilDone:YES];
				}
				[self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:YES];
			}
			
		}
		[self.navigationController popToViewController:svc animated:YES];
	} else {
		UIAlertView *alert;
		if (response.statusCode == 413) {
			alert = [[UIAlertView alloc] initWithTitle:@"Error Confirming" 
											   message:@"Your resize was not confirmed because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later." 
											  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		} else {
			alert = [[UIAlertView alloc] initWithTitle:@"Error Confirming" 
											   message:@"Your resize was not confirmed.  Please check your connection and try again." 
											  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		}
		[alert show];
		[alert release];
		[self performSelectorOnMainThread:@selector(stopConfirmSpinner) withObject:nil waitUntilDone:YES];
		sendingRequest = NO;
	}
	
	[pool release];
}

- (void) revertResize:(ServerViewController *)svc {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Response *response = [self.server revertResize];
	
	if ([response isSuccess]) {
		BOOL statusChanged = NO;
		
		while (!statusChanged) {
			Server *s = [Server findRemoteWithId:self.server.serverId andResponse:nil];
			if (s) {
				svc.server.flavorId = [s.flavorId copy];
				if (![self.serverViewController.server.status isEqualToString:s.status]) {
					statusChanged = YES;
					svc.server.status = [s.status copy];
					//svc.server.status = @"WTF";
					[self performSelectorOnMainThread:@selector(setServerStatus:) withObject:s waitUntilDone:YES];
				}
				[self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:YES];
			}
			
		}
		[self.navigationController popToViewController:svc animated:YES];
	} else {
		UIAlertView *alert;
		if (response.statusCode == 413) {
			alert = [[UIAlertView alloc] initWithTitle:@"Error Reverting" 
											   message:@"Your resize was not reverted because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later." 
											  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		} else {
			alert = [[UIAlertView alloc] initWithTitle:@"Error Reverting" 
											   message:@"Your resize was not reverted.  Please check your connection and try again." 
											  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		}
		[alert show];
		[alert release];
		[self performSelectorOnMainThread:@selector(stopConfirmSpinner) withObject:nil waitUntilDone:YES];
		sendingRequest = NO;
	}
	
	[pool release];
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
	//[server release]; // TODO: put back?
	[serverViewController release];
	[confirmSpinner release];
	[rollbackSpinner release];
    [super dealloc];
}


@end
