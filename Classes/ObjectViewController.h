//
//  ObjectViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/3/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class CloudFilesObject, Container;

@interface ObjectViewController : UITableViewController <MFMailComposeViewControllerDelegate> {
	CloudFilesObject *cfObject;
	Container *container;
}

@property (nonatomic, retain) CloudFilesObject *cfObject;
@property (nonatomic, retain) Container *container;

@end
