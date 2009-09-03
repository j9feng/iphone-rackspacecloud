//
//  ServersRootViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 6/20/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServersRootViewController : UITableViewController <UIAccelerometerDelegate> {
	NSMutableArray *servers;
	UIAccelerationValue	myAccelerometer[3];
	BOOL serversLoaded;
}

@property (nonatomic, retain) NSMutableArray *servers;
@property (nonatomic) BOOL serversLoaded;

-(void) addButtonPressed:(id)sender;

@end
