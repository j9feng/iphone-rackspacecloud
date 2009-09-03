//
//  ServerNameController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddServerViewController;

@interface ServerNameController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	AddServerViewController *addServerViewController;
}

@property (nonatomic, retain) AddServerViewController *addServerViewController;

@end
