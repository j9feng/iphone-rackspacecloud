//
//  DetailSpinnerCell.h
//  Rackspace Cloud
//
//  Created by Michael Mayo on 12/12/08.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DetailSpinnerCell : UITableViewCell {
    UITextField *type;
    UITextField *name;
	UIActivityIndicatorView *spinner;
}

@property (readonly, retain) UITextField *type;
@property (nonatomic, retain) UITextField *name;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@end
