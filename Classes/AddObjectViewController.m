//
//  AddObjectViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/19/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "AddObjectViewController.h"
#import "RackspaceAppDelegate.h"
#import "CloudFilesObject.h"

@implementation AddObjectViewController

- (void) cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Table Methods

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return @"Choose a file type";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 1;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		rows++;
	}
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		rows++;
	}	
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Text File";
			break;
		case 1:
			cell.textLabel.text = @"Image from Photo Library";
			break;
		case 2:
			cell.textLabel.text = @"Image from Camera";
			break;
		default:
			break;
	}
	
	return cell;		
}


// TODO: make sure you cover ipod touch with the camera stuff

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
		
	} else if (indexPath.row == 1) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			UIImagePickerController *camera = [[UIImagePickerController alloc] init];		
			camera.delegate = self;
			camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentModalViewController:camera animated:YES];
			[camera release];
		}
	} else if (indexPath.row == 2) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			UIImagePickerController *camera = [[UIImagePickerController alloc] init];		
			camera.delegate = self;
			camera.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentModalViewController:camera animated:YES];
			[camera release];
		}
	}
	
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark Camera Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"showed an image!");
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	UIImageView *iv = [[UIImageView alloc] initWithImage:image];
	//RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	//[app.window addSubview:iv];
	
	// TODO: use this to PUT to Cloud Files
	NSData *imageData = UIImagePNGRepresentation(image);
	
	CloudFilesObject *co = [[CloudFilesObject alloc] init];
	
	co.name = @"miketest.png";
	co.contentType = @"image/png";
	co.data = imageData;
	[co createFileWithAccountName:@"MossoCloudFS_56ad0327-43d6-4ac4-9883-797f5690238e" andContainerName:@"overhrd.com"];
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:3.75];
	iv.alpha = 0.0;
	[UIView commitAnimations];
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
    [super dealloc];
}


@end
