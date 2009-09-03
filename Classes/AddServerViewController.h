//
//  AddServerViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server, EditableCell, ServersRootViewController;

@interface AddServerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	Server *server;
	EditableCell *nameCell;
	UITableViewCell *flavorCell;
	UITableViewCell *imageCell;
	ServersRootViewController *serversRootViewController;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) EditableCell *nameCell;
@property (nonatomic, retain) ServersRootViewController *serversRootViewController;

-(void) cancelButtonPressed:(id)sender;
-(void) saveButtonPressed:(id)sender;

@end
