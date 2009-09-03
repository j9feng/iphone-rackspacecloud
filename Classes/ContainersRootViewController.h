//
//  ContainersRootViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Account;

@interface ContainersRootViewController : UITableViewController <UIAccelerometerDelegate> {
	Account *account;
	Account *cdnAccount;
	UIAccelerationValue	myAccelerometer[3];
}

@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Account *cdnAccount;

@end
