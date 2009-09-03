//
//  IPGroupViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SharedIpGroup;

@interface IPGroupViewController : UITableViewController {
	SharedIpGroup *ipGroup;
}

@property (nonatomic, retain) SharedIpGroup *ipGroup;

@end
