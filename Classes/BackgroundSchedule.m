//
//  BackgroundSchedule.m
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "BackgroundSchedule.h"


@implementation BackgroundSchedule

@synthesize status, weekly, daily;

-(void) dealloc {
	[status release];
	[weekly release];
	[daily release];
	[super dealloc];
}

@end
