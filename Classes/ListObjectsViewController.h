//
//  ListObjectsViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Container, Account, RoundedRectView;

@interface ListObjectsViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAccelerometerDelegate> {
	NSString *containerName;
	Container *container;
	Account *account;
	UIAccelerationValue	myAccelerometer[3];
	UISwitch *cdnSwitch;
	UISwitch *logSwitch;
	RoundedRectView *spinnerView;
}

@property (nonatomic, retain) NSString *containerName;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) UISwitch *cdnSwitch;
@property (nonatomic, retain) UISwitch *logSwitch;
@property (nonatomic, retain) RoundedRectView *spinnerView;

- (void)showSpinnerView;
- (void)hideSpinnerView;

@end
