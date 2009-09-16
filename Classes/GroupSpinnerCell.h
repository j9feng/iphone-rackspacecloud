//
//  GroupSpinnerCell.h
//  Rackspace Cloud
//
//  Created by Michael Mayo on 9/15/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GroupSpinnerCell : UITableViewCell {
	UIActivityIndicatorView *spinner;
	UILabel *message;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *message;

@end
