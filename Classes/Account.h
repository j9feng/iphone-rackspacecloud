//
//  Account.h
//  Rackspace
//
//  Created by Michael Mayo on 6/21/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ObjectiveResource.h"

@class Container;

@interface Account : NSObject {
	NSMutableArray *containers;
	NSString *container;
}

@property (nonatomic, retain) NSMutableArray *containers;
@property (nonatomic, retain) NSString *container;

+ (id)findCDNRemote:(NSString *)elementId withResponse:(NSError **)aError;

@end
