//
//  SharedIpGroup.h
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ObjectiveResource.h"


@interface SharedIpGroup : NSObject {
	NSString *sharedIpGroupId;
	NSString *sharedIpGroupName;
	NSMutableArray *servers;
//	<servers> 
//	<serverId>23203</serverId> 
//	<serverId>2456</serverId> 
//	<serverId>9891</serverId> 
//	</servers> 
}

@property (nonatomic, retain) NSString *sharedIpGroupId;
@property (nonatomic, retain) NSString *sharedIpGroupName;
@property (nonatomic, retain) NSMutableArray *servers;

-(void)count;
@end
