//
//  BackgroundSchedule.h
//  Rackspace
//
//  Created by Michael Mayo on 6/7/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BackgroundSchedule : NSObject {
	NSString *status;
	NSString *weekly;
	NSString *daily;	
}

@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *weekly;
@property (nonatomic, retain) NSString *daily;

@end
