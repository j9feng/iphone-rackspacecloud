//
//  Server.h
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ObjectiveResource.h"

@class Response;

@interface Server : NSObject {

	NSString *serverId;
	NSString *serverName;
	NSString *imageId;
	NSString *flavorId;
	NSString *hostId;
	
	NSMutableDictionary *addresses;
	// addresses => public => ip (attrs), private => ip (attrs)

	
	NSMutableArray *serverMetaData;
//	<serverMetaData> 
//	<serverMetaDataKey>Server Label</serverMetaDataKey> 
//	<serverMetaDataValue>DB 1</serverMetaDataValue> 
//	</serverMetaData> 
//	<serverMetaData> 
//	<serverMetaDataKey>My Image Version</serverMetaDataKey> 
//	<serverMetaDataValue>2.1</serverMetaDataValue> 
//	</serverMetaData> 

	NSString *status;
	NSString *progress;

	NSString *newPassword;
	
}

@property (nonatomic, retain) NSString *serverId;
@property (nonatomic, retain) NSString *serverName;
@property (nonatomic, retain) NSString *imageId;
@property (nonatomic, retain) NSString *flavorId;
@property (nonatomic, retain) NSString *hostId;
@property (nonatomic, retain) NSMutableDictionary *addresses;
@property (nonatomic, retain) NSMutableArray *serverMetaData;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *progress;

@property (nonatomic, retain) NSString *newPassword;

-(NSString *)imageName;
-(NSString *)flavorName;
-(Response *)softReboot;
-(Response *)hardReboot;
-(Response *)resize;
-(Response *)confirmResize;
-(Response *)revertResize;
+ (Server *)findRemoteWithId:(NSString *)serverId andResponse:(NSError **)aError;
-(Response *)create;
-(Response *)saveRemote;

@end
