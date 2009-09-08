//
//  ListObjectsViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Container, CFAccount, RoundedRectView, EditableCell;

@interface ListObjectsViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAccelerometerDelegate, UITextFieldDelegate> {
	NSString *containerName;
	Container *container;
	Container *objectsContainer;
	CFAccount *account;
	UIAccelerationValue	myAccelerometer[3];
	UISwitch *cdnSwitch;
	UISwitch *logSwitch;
	RoundedRectView *spinnerView;
	EditableCell *cdnURLCell;
}

@property (nonatomic, retain) NSString *containerName;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) Container *objectsContainer;
@property (nonatomic, retain) CFAccount *account;
@property (nonatomic, retain) UISwitch *cdnSwitch;
@property (nonatomic, retain) UISwitch *logSwitch;
@property (nonatomic, retain) RoundedRectView *spinnerView;

- (void)showSpinnerView;
- (void)hideSpinnerView;

@end
