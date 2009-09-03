//
//  SliceCell.h
//  Slicehost
//
//  Created by Michael Mayo on 3/6/09.
//  Copyright 2009 Coupa Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server;

@interface ServerCell : UITableViewCell {
	Server *server;

	UILabel *nameLabel;
	UILabel *bandwidthLabel;
	UIImageView *logoImage;
	
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *bandwidthLabel;
@property (nonatomic, retain) UIImageView *logoImage;

@end
