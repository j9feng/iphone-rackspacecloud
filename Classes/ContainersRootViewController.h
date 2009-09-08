//
//  ContainersRootViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CFAccount;

@interface ContainersRootViewController : UITableViewController <UIAccelerometerDelegate> {
	CFAccount *account;
	CFAccount *cdnAccount;
	UIAccelerationValue	myAccelerometer[3];
}

@property (nonatomic, retain) CFAccount *account;
@property (nonatomic, retain) CFAccount *cdnAccount;

@end
