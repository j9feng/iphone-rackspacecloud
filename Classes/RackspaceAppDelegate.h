//
//  RackspaceAppDelegate.h
//  Rackspace
//
//  Created by Michael Mayo on 5/25/09.
//  Copyright Rackspace Hosting 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class LoginViewController, ServersRootViewController;

@interface RackspaceAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	LoginViewController *loginViewController;
	ServersRootViewController *serversRootViewController;
	
	NSMutableArray *flavors;
	NSMutableArray *images;
	NSMutableDictionary *servers;
	
	NSString *computeUrl;
	NSString *storageUrl;
	NSString *cdnManagementUrl;
	NSString *authToken;
	
	NSString *usernamePreference;
	NSString *apiKeyPreference;
	
	UIScrollView *imageScrollView;
	
	MPMoviePlayerController *moviePlayer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) ServersRootViewController *serversRootViewController;

@property (nonatomic, retain) NSMutableArray *flavors;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableDictionary *servers;

@property (nonatomic, retain) NSString *computeUrl;
@property (nonatomic, retain) NSString *storageUrl;
@property (nonatomic, retain) NSString *cdnManagementUrl;
@property (nonatomic, retain) NSString *authToken;

@property (nonatomic, retain) NSString *usernamePreference;
@property (nonatomic, retain) NSString *apiKeyPreference;

@property (nonatomic, retain) UIScrollView *imageScrollView;

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;

-(void)initAndPlayMovie:(NSURL *)movieURL;
-(void)setMoviePlayerUserSettings;

@end
