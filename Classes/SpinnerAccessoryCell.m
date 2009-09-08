//
//  SpinnerAccessoryCell.m
//  Rackspace
//
//  Created by Michael Mayo on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpinnerAccessoryCell.h"


@implementation SpinnerAccessoryCell

//- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
//        // Initialization code
//    }
//
//    return self;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
	if (selected) {
		self.accessoryType = UITableViewCellAccessoryNone;
		UIActivityIndicatorView *spinner;
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(253.0, 12.0, 20.0, 20.0)];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);	
		[spinner startAnimating];
		[self.contentView addSubview:spinner];

	} else {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}	
	self.accessoryType = UITableViewCellAccessoryNone;	
}


- (void)dealloc {
    [super dealloc];
}


@end
