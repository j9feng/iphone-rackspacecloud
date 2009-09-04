//
//  RenameServerController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/23/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server;

@interface RenameServerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	Server *server;
}

@property (nonatomic, retain) Server *server;

-(void)saveButtonPressed:(id)sender;

@end
