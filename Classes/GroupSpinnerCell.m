//
//  GroupSpinnerCell.m
//  Rackspace Cloud
//
//  Created by Michael Mayo on 9/15/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "GroupSpinnerCell.h"


@implementation GroupSpinnerCell

@synthesize spinner, message;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		// Initialize the labels, their fonts, colors, alignment, and background color.
		message = [[UILabel alloc] initWithFrame:CGRectZero];
		message.textColor = [UIColor grayColor];
        message.backgroundColor = [UIColor clearColor];
		message.text = @"Loading...";
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(90, 0, 20.0, 20.0)];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);
		[self.contentView addSubview:spinner];
		[spinner startAnimating];		
		[self.contentView addSubview:message];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Start with a rect that is inset from the content view by 10 pixels on all sides.
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 10);
    CGRect rect = baseRect;
    rect.origin.x += 30;
    
	// Position each label with a modified version of the base rect.
    // prompt.frame = rect;
	//rect.origin.y -= 200;
    rect.size.width = 60;
	
    rect.size.width = baseRect.size.width - 70;
	message.frame = rect;
	rect.origin.x -= 30;
	rect.origin.y += 2;
	rect.size.width = 20;
	rect.size.height = 20;
	spinner.frame = rect;
}

// Update the text color of each label when entering and exiting selected mode.
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
		message.textColor = [UIColor whiteColor];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        message.textColor = [UIColor grayColor];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}


- (void)dealloc {
    [spinner release];
	[message release];
    [super dealloc];
}

@end
