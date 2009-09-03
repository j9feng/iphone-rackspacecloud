//
//  Image.h
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ObjectiveResource.h"


@interface Image : NSObject {

	NSString *imageId;
	NSString *imageName;
	NSString *timeStamp;
	NSString *status;
	NSString *progress;	
	NSString *serverId; // for backup images
}

@property (nonatomic, retain) NSString *imageId;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *timeStamp;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *progress;
@property (nonatomic, retain) NSString *serverId;

+ (Image *)findLocalWithImageId:(NSString *)imageId;

@end
