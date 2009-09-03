//
//  SpinnerCell.h
//  Slicehost
//
//  Created by Michael Mayo on 12/12/08.
//  Copyright 2008 Coupa Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SpinnerCell : UITableViewCell {
	UIActivityIndicatorView *spinner;
	UILabel *message;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *message;

@end
