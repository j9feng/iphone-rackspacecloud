//
//  SpinnerAccessoryCell.h
//  Rackspace Cloud
//
//  Created by Michael Mayo on 9/7/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpinnerAccessoryCell : UITableViewCell {
	UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@end
