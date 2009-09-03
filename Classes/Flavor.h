//
//  Flavor.h
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ObjectiveResource.h"


@interface Flavor : NSObject {

	NSString *flavorId;
	NSString *flavorName;
	NSString *ram; // in MB
	NSString *disk; // in GB
	
}

@property (nonatomic, retain) NSString *flavorId;
@property (nonatomic, retain) NSString *flavorName;
@property (nonatomic, retain) NSString *ram;
@property (nonatomic, retain) NSString *disk;

@end
