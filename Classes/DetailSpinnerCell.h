//
//  DetailSpinnerCell.h
//  Slicehost
//
//  Created by Michael Mayo on 12/12/08.
//  Copyright 2008 Coupa Software. All rights reserved.
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
