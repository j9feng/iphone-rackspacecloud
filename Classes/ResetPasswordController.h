//
//  ResetPasswordController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/26/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SecureEditableCell, Server, ServerViewController, RoundedRectView;

@interface ResetPasswordController : UITableViewController <UITextFieldDelegate> {
	SecureEditableCell *passwordCell;
	SecureEditableCell *confirmPasswordCell;
	
	Server *server;
	ServerViewController *serverViewController;
	
	RoundedRectView *spinnerView;
	IBOutlet UIView *footerView;
}

@property (nonatomic, retain) SecureEditableCell *passwordCell;
@property (nonatomic, retain) SecureEditableCell *confirmPasswordCell;
@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) ServerViewController *serverViewController;
@property (nonatomic, retain) RoundedRectView *spinnerView;
@property (nonatomic, retain) UIView *footerView;

- (void)saveButtonPressed:(id)sender;

@end
