//
//  WebFileViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 8/29/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CloudFilesObject, Container;

@interface WebFileViewController : UIViewController {
	CloudFilesObject *cfObject;
	Container *container;
	IBOutlet UIWebView *webView;
}

@property (nonatomic, retain) CloudFilesObject *cfObject;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) UIWebView *webView;

@end
