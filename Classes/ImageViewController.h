//
//  ImageViewController.h
//  Rackspace
//
//  Created by Michael Mayo on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"

@class Account, Container, CloudFilesObject, TapDetectingImageView;

@interface ImageViewController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate> {
	Account *account;
	Container *container;
	NSString *containerName;
	CloudFilesObject *cfObject;
	//IBOutlet UIImageView *imageView;
	IBOutlet TapDetectingImageView *imageView;
	IBOutlet UIActivityIndicatorView *spinner;
	UIImage *img;
}

@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) NSString *containerName;
@property (nonatomic, retain) CloudFilesObject *cfObject;
//@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) TapDetectingImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIImage *img;

-(void) hideChrome:(NSTimer *)timer;
-(void) showChrome:(NSTimer *)timer;
-(UIImage *) resizeImage:(UIImage *)image;
-(UIImage*)imageByScalingToSize:(CGSize)targetSize withImage:(UIImage *)image;

@end


