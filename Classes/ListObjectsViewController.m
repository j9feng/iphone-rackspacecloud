//
//  ListObjectsViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ListObjectsViewController.h"
#import "Container.h"
#import "CloudFilesObject.h"
#import "SpinnerCell.h"
#import "RackspaceAppDelegate.h"
#import "CFAccount.h"
#import "AddObjectViewController.h"
#import "ObjectViewController.h"
#import "RoundedRectView.h"
#import "Response.h"
#import "EditableCell.h"

#define kContainerDetails 0
#define kCDN -1
#define kFiles 1

@implementation ListObjectsViewController

@synthesize account, container, containerName, cdnSwitch, logSwitch, spinnerView, objectsContainer;

BOOL objectsLoaded = NO;

// thread to load containers
- (void) loadObjects {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	if (!objectsLoaded) {
		RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
		[ObjectiveResourceConfig setSite:app.storageUrl];	
		[ObjectiveResourceConfig setAuthToken:app.authToken];
		[ObjectiveResourceConfig setResponseType:XmlResponse];	
		
		// the objectsContainer is a temporary holder for the files list
		self.objectsContainer = [Container findRemote:self.containerName withResponse:nil];
		self.container.objects = self.objectsContainer.objects;
		
		objectsLoaded = YES;
		self.tableView.userInteractionEnabled = YES;
		[self.tableView reloadData];		
	}
	[autoreleasepool release];
}

- (void)showSaveError:(Response *)response {
	UIAlertView *alert;
	if (response.statusCode == 413) {
		alert = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
										   message:@"This container was not saved because you have exceeded the API rate limit.  Please contact the Rackspace Cloud to increase your limit or try again later."
										  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	} else {
		alert = [[UIAlertView alloc] initWithTitle:@"Error Saving" 
										   message:@"This container was not saved.  Please check your connection or data and try again."
										  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	}
	[alert show];
	[alert release];	
}

- (void)cdnSwitchAction:(id)sender {
	NSLog(@"switchAction: value = %d", [sender isOn]);
	
	[self showSpinnerView];

	if ([sender isOn]) {
		self.container.cdnEnabled = @"True";
	} else {
		self.container.cdnEnabled = @"False";
	}
	Response *response = [self.container save];
	[self hideSpinnerView];
	if (![response isSuccess]) {
		[self showSaveError:response];
	}
}

- (UISwitch *)cdnSwitch {
    if (cdnSwitch == nil) {
        CGRect frame = CGRectMake(198.0, 9.0, 94.0, 27.0);
        cdnSwitch = [[UISwitch alloc] initWithFrame:frame];

        [cdnSwitch addTarget:self action:@selector(cdnSwitchAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        cdnSwitch.backgroundColor = [UIColor clearColor];
		
		cdnSwitch.tag = 1;	// tag this view for later so we can remove it from recycled table cells
    }
    return cdnSwitch;
}

- (void)logSwitchAction:(id)sender {
	NSLog(@"switchAction: value = %d", [sender isOn]);

	[self showSpinnerView];

	if ([sender isOn]) {
		self.container.logRetention = @"True";
	} else {
		self.container.logRetention = @"False";
	}
	Response *response = [self.container save];
	[self hideSpinnerView];
	if (![response isSuccess]) {
		[self showSaveError:response];
	}
}

- (UISwitch *)logSwitch {
    if (logSwitch == nil) {
        CGRect frame = CGRectMake(198.0, 9.0, 94.0, 27.0);
        logSwitch = [[UISwitch alloc] initWithFrame:frame];
		
        [logSwitch addTarget:self action:@selector(logSwitchAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        logSwitch.backgroundColor = [UIColor clearColor];
		
		logSwitch.tag = 2;	// tag this view for later so we can remove it from recycled table cells
    }
    return logSwitch;
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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"showed an image!");
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	UIImageView *iv = [[UIImageView alloc] initWithImage:image];
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	[app.window addSubview:iv];
	
	// TODO: use this to PUT to Cloud Files
	//NSData *imageData = UIImagePNGRepresentation(image);
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:3.75];
	iv.alpha = 0.0;
	[UIView commitAnimations];
	
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == kFiles) {

		if (kRackspaceVersion >= 1.1) {
			CloudFilesObject *o = (CloudFilesObject *) [container.objects objectAtIndex:indexPath.row];	
			ObjectViewController *vc = [[ObjectViewController alloc] initWithNibName:@"ObjectView" bundle:nil];
			vc.cfObject = o;
			vc.container = self.container;
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			[aTableView deselectRowAtIndexPath:indexPath animated:NO];
		}
		
		/* // code to load image viewer
		if ((kRackspaceVersion >= 1.1) && [o.contentType rangeOfString:@"image/"].location == 0) {		
			
			RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
			app.tapDetectingImageView.image = nil; // to not show previously view image behind status bar

			self.navigationController.navigationBar.translucent = YES;
			self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

			ImageViewController *vc = [[ImageViewController alloc] initWithNibName:@"ImageView" bundle:nil];
			vc.account = self.account;
			vc.container = self.container;
			vc.containerName = self.containerName;
			vc.cfObject = [container.objects objectAtIndex:indexPath.row];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			[aTableView deselectRowAtIndexPath:indexPath animated:NO];		
		}
		*/
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"cancel camera");
	[picker dismissModalViewControllerAnimated:YES];
	
}

- (void)addButtonPressed {
	AddObjectViewController *vc = [[AddObjectViewController alloc] initWithNibName:@"AddObject" bundle:nil];
	[self presentModalViewController:vc animated:YES];	
}

- (void)showCamera {
	//if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		
		NSLog(@"time to show the camera");
		UIImagePickerController *camera = [[UIImagePickerController alloc] init];		
		camera.delegate = self;
		camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		//camera.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:camera animated:YES];
		
	//}
}

- (void)viewDidLoad {
    [super viewDidLoad];	
	// TODO: restore when ready to add files again
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
	//self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient.jpg"]];

	// show a rounded rect view
	self.spinnerView = [[RoundedRectView alloc] initWithDefaultFrame];
	[self.view addSubview:self.spinnerView];
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	// set up the accelerometer for the "shake to refresh" feature
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 25)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];	
	
	self.navigationItem.title = self.containerName;
	[NSThread detachNewThreadSelector:@selector(loadObjects) toTarget:self withObject:nil];	
	[super viewWillAppear:animated];
}

#pragma mark Table Methods

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 50;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == kContainerDetails) {
		return @"Container Details";
	} else if (section == kCDN) {
		return @"Content Delivery Network";
	} else if (section == kFiles) {
		return @"Files";
	} else {
		return @"";
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if (section == kContainerDetails) {
		rows = 2;
	} else if (section == kCDN) {
		rows = 3;
	} else { // if (section == kFiles) {
		if (objectsLoaded) {
			rows = [container.objects count];
		} else {
			rows = 1;
		}
	}
	return rows;
}

// not needed for grouped table view
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	CGFloat height = 44; // this is the apple default	
//	if (!objectsLoaded && indexPath.section == kFiles) {
//		height = 460;
//	}
//	return height;
//}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == kContainerDetails) {
		static NSString *CellIdentifier = @"ContainerDetailsCell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Name";
				cell.detailTextLabel.text = self.container.name;
				break;
			case 1:
				cell.textLabel.text = @"Size";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [self.container humanizedCount], [self.container humanizedBytes]];
				break;
		}
		
		return cell;

	} else if (indexPath.section == kCDN) {
		static NSString *CellIdentifier = @"CDNCell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		static NSString *CDNSwitchCellIdentifier = @"CDNSwitchCell";
		UITableViewCell *cdnSwitchCell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CDNSwitchCellIdentifier];
		if (cdnSwitchCell == nil) {
			cdnSwitchCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDNSwitchCellIdentifier] autorelease];
			cdnSwitchCell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		static NSString *LogSwitchCellIdentifier = @"LogSwitchCell";
		UITableViewCell *logSwitchCell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:LogSwitchCellIdentifier];
		if (logSwitchCell == nil) {
			logSwitchCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LogSwitchCellIdentifier] autorelease];
			logSwitchCell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		static NSString *CDNURLCellIdentifier = @"CDNURLCell";
		cdnURLCell = (EditableCell *) [aTableView dequeueReusableCellWithIdentifier:CDNURLCellIdentifier];
		if (cdnURLCell == nil) {
			cdnURLCell = [[EditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CDNURLCellIdentifier];
			cdnURLCell.selectionStyle = UITableViewCellSelectionStyleNone;
			cdnURLCell.textField.delegate = self;
			
			// hide the clear button, since this field is not editable
			cdnURLCell.textField.clearButtonMode = UITextFieldViewModeNever;
			
			// move the text over a little bit
			CGRect labelRect = cdnURLCell.labelField.frame;
			labelRect.origin.x -= 15;
			cdnURLCell.labelField.frame = labelRect;
			
			CGRect textRect = cdnURLCell.textField.frame;
			textRect.origin.x += 10;
			textRect.size.width -= 10; // to prevent scrolling off the side
			cdnURLCell.textField.frame = textRect;
			
		}
		
		switch (indexPath.row) {
			case 0:
				cdnSwitchCell.textLabel.text = @"Publish to CDN";
				//cell.detailTextLabel.text = self.container.cdnEnabled;
				if (self.container.cdnEnabled && [self.container.cdnEnabled isEqualToString:@"True"]) {
					cdnSwitch.on = YES;
				}
				[cdnSwitchCell.contentView addSubview:self.cdnSwitch];
				return cdnSwitchCell;
				break;
			case 1:
				logSwitchCell.textLabel.text = @"Log Retention";
				//cell.detailTextLabel.text = self.container.logRetention;
				if (self.container.logRetention && [self.container.logRetention isEqualToString:@"True"]) {
					logSwitch.on = YES;
				}
				[logSwitchCell.contentView addSubview:self.logSwitch];
				return logSwitchCell;
				break;
			case 2:
				cell.textLabel.text = @"TTL";
				cell.detailTextLabel.text = self.container.ttl;
				break;
			case 3:
				cdnURLCell.labelField.text = @"CDN URL";
				cdnURLCell.textField.text = self.container.cdnUrl;
				return cdnURLCell;
				break;
		}
		
		return cell;			
			
	} else if (indexPath.section == kFiles) {
		
		if (objectsLoaded) {
			
			static NSString *CellIdentifier = @"ObjectCell";
			UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
				
				if (kRackspaceVersion >= 1.1) {
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				} else {
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				}
			}
			
			CloudFilesObject *o = (CloudFilesObject *) [container.objects objectAtIndex:indexPath.row];	
			cell.textLabel.text = o.name;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", o.contentType, [o humanizedBytes]];

			if (kRackspaceVersion >= 1.1) {
	//			if ([o.contentType rangeOfString:@"image/"].location == 0) {
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//			} else {
	//				cell.accessoryType = UITableViewCellAccessoryNone;
	//			}
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
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
	return nil;
}

#pragma mark Text Field Delegate Methods for CDN URL Cell

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[textField resignFirstResponder];
	return NO; // contents are not editable.  it's a text field to allow users to easily copy/paste
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO; // contents are not editable.  it's a text field to allow users to easily copy/paste
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[textField resignFirstResponder];
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
		objectsLoaded = NO;
		[self.tableView reloadData];		
		[NSThread detachNewThreadSelector:@selector(loadObjects) toTarget:self withObject:nil];	
		
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
	self.objectsContainer = nil;
	objectsLoaded = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	self.objectsContainer = nil;
	objectsLoaded = NO;
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[account release];
	[container release];
	[containerName release];
	[cdnSwitch release];
	[logSwitch release];
	[spinnerView release];
	[objectsContainer release];
    [super dealloc];
}


@end
