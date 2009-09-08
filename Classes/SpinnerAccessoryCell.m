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
	} else {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}	
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.frame = CGRectMake(10, 0, 18, 18);
	[self.contentView addSubview:spinner];
	
//	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"test" message:@"test" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
//	[av show];
//	[av release];
	
}


- (void)dealloc {
    [super dealloc];
}


@end
