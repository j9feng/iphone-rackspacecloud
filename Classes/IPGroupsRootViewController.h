//
//  IPGroupsRootViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 6/20/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPGroupsRootViewController : UITableViewController <UIAccelerometerDelegate> {
	NSMutableArray *ipGroups;
	IBOutlet UIBarButtonItem *addButton;
	UIAccelerationValue	myAccelerometer[3];
}

@property (nonatomic, retain) NSMutableArray *ipGroups;

@end
