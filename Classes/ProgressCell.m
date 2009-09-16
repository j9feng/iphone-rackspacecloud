//
//  ProgressCell.m
//  Rackspace Cloud
//
//  Created by Michael Mayo on 12/10/08.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import "ProgressCell.h"


@implementation ProgressCell

@synthesize type, progressView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {

		
		// Initialize the labels, their fonts, colors, alignment, and background color.

		
        progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
		//progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 50, 0, 0)];
		progressView.progress = 0.5;
        
		
		type = [[UILabel alloc] initWithFrame:CGRectZero];
        type.font = [UIFont boldSystemFontOfSize:12];
        type.textColor = [UIColor darkGrayColor];
        type.textAlignment = UITextAlignmentRight;
        type.backgroundColor = [UIColor clearColor];

//        name = [[UILabel alloc] initWithFrame:CGRectZero];
//        name.font = [UIFont boldSystemFontOfSize:14];
//        name.backgroundColor = [UIColor clearColor];
        
        // Add the labels to the content view of the cell.
        
        // Important: although UITableViewCell inherits from UIView, you should add subviews to its content view
        // rather than directly to the cell so that they will be positioned appropriately as the cell transitions 
        // into and out of editing mode.
        
        [self.contentView addSubview:type];
        [self.contentView addSubview:progressView];
		//self.autoresizesSubviews = YES;
    }
    return self;
}

- (void)dealloc {
    [type release];
    [progressView release];
    [super dealloc];
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
	rect.origin.y += 8;
    rect.size.width = baseRect.size.width - 70;
    progressView.frame = rect;
}

// Update the text color of each label when entering and exiting selected mode.
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        //name.textColor = [UIColor whiteColor];
        type.textColor = [UIColor whiteColor];
//        prompt.textColor = [UIColor whiteColor];
    } else {
//        name.textColor = [UIColor blackColor];
        type.textColor = [UIColor darkGrayColor];
//        prompt.textColor = [UIColor darkGrayColor];
    }
}

@end
