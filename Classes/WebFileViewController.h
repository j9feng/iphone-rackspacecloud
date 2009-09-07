//
//  WebFileViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 8/29/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CloudFilesObject, Container;

@interface WebFileViewController : UIViewController <UIWebViewDelegate> {
	CloudFilesObject *cfObject;
	Container *container;
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UILabel *loadingLabel;
}

@property (nonatomic, retain) CloudFilesObject *cfObject;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *loadingLabel;

@end
