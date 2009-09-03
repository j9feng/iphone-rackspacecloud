//
//  LoginViewController.h
//  Overhrd
//
//  Created by Michael Mayo on 4/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditableLoginCell, SecureEditableLoginCell;

//@interface LoginViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	IBOutlet UITableView *tableView;
	NSString *secondLabel;
	EditableLoginCell *usernameCell;
	SecureEditableLoginCell *apiKeyCell;
	IBOutlet UIImageView *backgroundImage;
	IBOutlet UIView *spinnerView;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) EditableLoginCell *usernameCell;
@property (nonatomic, retain) SecureEditableLoginCell *apiKeyCell;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIView *spinnerView;

@end
