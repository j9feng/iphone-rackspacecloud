//
//  ProgressCell.h
//  Slicehost
//
//  Created by Michael Mayo on 12/10/08.
//  Copyright 2008 Coupa Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProgressCell : UITableViewCell {
    UITextField *type;
	UIProgressView *progressView;
}

@property (readonly, retain) UITextField *type;
@property (readonly, retain) UIProgressView *progressView;

@end
