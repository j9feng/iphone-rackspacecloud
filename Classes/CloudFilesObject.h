//
//  Object.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ObjectiveResource.h"


@interface CloudFilesObject : NSObject {
	NSString *name;
	NSString *hash;
	NSString *bytes;
	NSString *contentType;
	
	NSData *data;

	NSMutableArray *objects;
	NSString *object;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *hash;
@property (nonatomic, retain) NSString *bytes;
@property (nonatomic, retain) NSString *contentType;

@property (nonatomic, retain) NSData *data;

@property (nonatomic, retain) NSMutableArray *objects;
@property (nonatomic, retain) NSString *object;

-(NSString *)humanizedBytes;

-(BOOL)createFileWithAccountName:(NSString *)accountName andContainerName:(NSString *)containerName;

@end
