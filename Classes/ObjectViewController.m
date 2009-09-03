//
//  ObjectViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ObjectViewController.h"
#import "CloudFilesObject.h"
#import "WebFileViewController.h"
#import "Container.h"

#define kFileDetails 0
#define kActions 1

@implementation ObjectViewController

@synthesize cfObject, container;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = self.cfObject.name;
	[super viewWillAppear:animated];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

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
	if (section == kFileDetails) {
		return @"File Details";
	} else {
		return @"";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == kFileDetails) {
		return 3;
	} else if (section == kActions) {
		return 1;
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == kFileDetails) {
		
		static NSString *CellIdentifier = @"FileDetailsCell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Name";
				cell.detailTextLabel.text = self.cfObject.name;
				break;
			case 1:
				cell.textLabel.text = @"Size";
				cell.detailTextLabel.text = [self.cfObject humanizedBytes];
				break;
			case 2:
				cell.textLabel.text = @"File Type";
				cell.detailTextLabel.text = self.cfObject.contentType;
				break;
			case 3:
				cell.textLabel.text = @"Object";
				cell.detailTextLabel.text = self.cfObject.object;
				break;
		}
		
		return cell;
		
	} else if (indexPath.section == kActions) {
		static NSString *CellIdentifier = @"FileActionCell";
		UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		cell.textLabel.text = @"Preview File";
		return cell;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	WebFileViewController *vc = [[WebFileViewController alloc] initWithNibName:@"WebFileViewController" bundle:nil];
	vc.cfObject = self.cfObject;
	vc.container = self.container;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];		
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
	[cfObject release];
	[container release];
    [super dealloc];
}


@end
