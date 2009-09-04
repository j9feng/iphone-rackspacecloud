//
//  ConfirmResizeServerController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/25/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server, ServerViewController;

@interface ConfirmResizeServerController : UITableViewController {
	Server *server;
	ServerViewController *serverViewController;
	UIActivityIndicatorView *confirmSpinner;
	UIActivityIndicatorView *rollbackSpinner;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) ServerViewController *serverViewController;
@property (nonatomic, retain) UIActivityIndicatorView *confirmSpinner;
@property (nonatomic, retain) UIActivityIndicatorView *rollbackSpinner;

@end
