//
//  DetailSpinnerCell.m
//  Slicehost
//
//  Created by Michael Mayo on 12/12/08.
//  Copyright 2008 Coupa Software. All rights reserved.
//

#import "DetailSpinnerCell.h"


@implementation DetailSpinnerCell

@synthesize type, name, spinner;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialize the labels, their fonts, colors, alignment, and background color.
        type = [[UILabel alloc] initWithFrame:CGRectZero];
        type.font = [UIFont boldSystemFontOfSize:12];
        type.textColor = [UIColor darkGrayColor];
        type.textAlignment = UITextAlignmentRight;
        type.backgroundColor = [UIColor clearColor];
        name = [[UILabel alloc] initWithFrame:CGRectZero];
        //name.font = [UIFont boldSystemFontOfSize:14];
		name.font = [name.font fontWithSize:12];
		name.textColor = [UIColor grayColor];
        name.backgroundColor = [UIColor clearColor];
		name.text = @"Loading...";
        
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 12, 18.0, 18.0)];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);
		[self.contentView addSubview:spinner];
		[spinner startAnimating];		
		
		
        // Add the labels to the content view of the cell.
        
        // Important: although UITableViewCell inherits from UIView, you should add subviews to its content view
        // rather than directly to the cell so that they will be positioned appropriately as the cell transitions 
        // into and out of editing mode.
        
        [self.contentView addSubview:type];
        [self.contentView addSubview:name];
		//        self.autoresizesSubviews = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Start with a rect that is inset from the content view by 10 pixels on all sides.
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 10);
    CGRect rect = baseRect;
    rect.origin.x += 15;
    // Position each label with a modified version of the base rect.
    rect.origin.x -= 15;
    rect.size.width = 60;
    type.frame = rect;
    rect.origin.x += 70;
    rect.size.width = baseRect.size.width - 70;
    name.frame = rect;
}

// Update the text color of each label when entering and exiting selected mode.
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        name.textColor = [UIColor whiteColor];
        type.textColor = [UIColor whiteColor];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        name.textColor = [UIColor grayColor];
        type.textColor = [UIColor darkGrayColor];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}


- (void)dealloc {
	[type release];
	[name release];
    [spinner release];
    [super dealloc];
}

@end
