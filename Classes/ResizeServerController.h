//
//  ResizeServerController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/21/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server, ServerViewController, RoundedRectView, ServersRootViewController;

@interface ResizeServerController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	Server *server;
	ServerViewController *serverViewController;
	RoundedRectView *spinnerView;
	ServersRootViewController *serversRootViewController;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) ServerViewController *serverViewController;
@property (nonatomic, retain) RoundedRectView *spinnerView;
@property (nonatomic, retain) ServersRootViewController *serversRootViewController;

@end
