//
//  AddServerFlavorController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server, AddServerViewController;

@interface AddServerFlavorController : UITableViewController {
	Server *server;
	AddServerViewController *addServerViewController;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) AddServerViewController *addServerViewController;

@end
