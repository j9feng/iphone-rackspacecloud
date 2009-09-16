//
//  ProgressCell.h
//  Rackspace Cloud
//
//  Created by Michael Mayo on 12/10/08.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProgressCell : UITableViewCell {
    UITextField *type;
	UIProgressView *progressView;
}

@property (readonly, retain) UITextField *type;
@property (readonly, retain) UIProgressView *progressView;

@end
