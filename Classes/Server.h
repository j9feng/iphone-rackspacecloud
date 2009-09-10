//
//  Server.h
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
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
	NSMutableArray *serverMetaData;
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
