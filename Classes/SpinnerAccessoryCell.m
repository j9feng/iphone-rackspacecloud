//
//  SpinnerAccessoryCell.m
//  Rackspace Cloud
//
//  Created by Michael Mayo on 9/7/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "SpinnerAccessoryCell.h"


@implementation SpinnerAccessoryCell

@synthesize spinner;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.accessoryType = UITableViewCellAccessoryNone;
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(283.0, 13.0, 20.0, 20.0)];
		spinner.hidesWhenStopped = YES;
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[self addSubview:spinner];
    }

    return self;
}

- (void)dealloc {
	[spinner release];
    [super dealloc];
}


@end
