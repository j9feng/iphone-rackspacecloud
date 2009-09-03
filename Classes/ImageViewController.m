//
//  ImageViewController.m
//  Rackspace
//
//  Created by Michael Mayo on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"
#import "Account.h"
#import "Container.h"
#import "CloudFilesObject.h"
#import "RackspaceAppDelegate.h"
#import "Connection.h"
#import "Response.h"
#import "TapDetectingImageView.h"

#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

#define ZOOM_VIEW_TAG 100

@implementation ImageViewController

@synthesize account, container, containerName, cfObject, imageView, spinner, img;

//simple API that encodes reserved characters according to:
//RFC 3986
//http://tools.ietf.org/html/rfc3986
+(NSString *) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", @" ", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", @"%20", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	
    return out;
}

// thread to load image
- (void) loadImage {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	containerName = [ImageViewController urlencode:containerName];
	cfObject.name = [ImageViewController urlencode:cfObject.name];
	
	NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", app.storageUrl, [containerName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [cfObject.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURL *url = [NSURL URLWithString:urlString];
	NSLog(urlString);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	Response *res = [Connection sendRequest:request withAuthToken:app.authToken];	
	
	//self.img = [UIImage imageWithData:res.body];
	UIImage *tempImage = [UIImage imageWithData:res.body];
	self.img = [self resizeImage:tempImage];
	//self.img = [self imageByScalingToSize:CGSizeMake(640.0, 480.0) withImage:tempImage];
	
	
	//[tempImage release];
	
	// make UIScrollView at 320x480, then insert UIImageView with real size
	
	app.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	[app.imageScrollView setMultipleTouchEnabled:YES];
	app.imageScrollView.delegate = self;
	

	app.tapDetectingImageView = [[TapDetectingImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	app.tapDetectingImageView.image = img;
	[app.tapDetectingImageView setMultipleTouchEnabled:YES];
	[app.tapDetectingImageView setDelegate:self];
	

	[app.imageScrollView addSubview:app.tapDetectingImageView];
	[app.imageScrollView setBackgroundColor:[UIColor blackColor]];
	[app.imageScrollView setCanCancelContentTouches:NO];
	//app.imageScrollView.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
	app.imageScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[app.imageScrollView setContentSize:CGSizeMake(img.size.width, img.size.height)];
	[app.imageScrollView setScrollEnabled:YES];

	[app.imageScrollView setBouncesZoom:YES];
	
	[app.tapDetectingImageView setTag:ZOOM_VIEW_TAG];
	
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [app.imageScrollView frame].size.width  / [app.tapDetectingImageView frame].size.width;    
//	[app.imageScrollView setMinimumZoomScale:minimumScale];
    [app.imageScrollView setZoomScale:minimumScale animated:NO];
	
	
	// adding a little to the minimum scale so scrolling can always happen
	app.imageScrollView.minimumZoomScale = minimumScale + 0.01;
	app.imageScrollView.zoomScale = minimumScale;
	app.imageScrollView.maximumZoomScale = 2.0;
	
	[app.imageScrollView zoomToRect:app.imageScrollView.frame animated:YES];
	
	
	//self.spinner.hidden = YES;
	
	// to show the scroll view with image under the chrome
	self.view.hidden = YES;
	
	// putting two UIImages to make the tab bar fade look slick
	//app.pinchImageView.alpha = 0.0;
	
	[app.window addSubview:app.imageScrollView];
	//[app.window addSubview:app.tapDetectingImageView];
	
	
	// to keep controls over the image
	[app.window bringSubviewToFront:app.tabBarController.view];
	
	
	//sleep(2.0);
	[self hideChrome:nil];

//	sleep(3.0);
//	[self showChrome:nil];
	
	//	[NSTimer scheduledTimerWithTimeInterval:2.0 
//			 target:self selector:@selector(hideChrome:) userInfo:nil repeats:NO];

//	[NSTimer scheduledTimerWithTimeInterval:5.0 
//									 target:self selector:@selector(showChrome:) userInfo:nil repeats:NO];

	//hitTest:withEvent
	//[app.imageScrollView setUserInteractionEnabled:NO];
	//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
	
	
	[autoreleasepool release];
}

-(void) hideChrome:(NSTimer *)timer {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	// fade away the tab bar controller
	sleep(3.0);
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	if (!app.imageScrollView.hidden) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.35];
		app.tabBarController.view.alpha = 0.0;
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
		[UIView commitAnimations];
	}
	[autoreleasepool release];
}

-(void) showChrome:(NSTimer *)timer {
	// fade away the tab bar controller
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.35];
	app.tabBarController.view.alpha = 1.0;
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[UIView commitAnimations];
	[NSThread detachNewThreadSelector:@selector(hideChrome:) toTarget:self withObject:nil];
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
    return [app.imageScrollView viewWithTag:ZOOM_VIEW_TAG];
}

/************************************** NOTE **************************************/
/* The following delegate method works around a known bug in zoomToRect:animated: */
/* In the next release after 3.0 this workaround will no longer be necessary      */
/**********************************************************************************/
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
	[self showChrome:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self showChrome:nil];
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"yay");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"yay");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"wtf");
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
	NSLog(@"got a single tap!");
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
	NSLog(@"got a double tap!");
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	return YES;
//}

/* */
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization	
    }
    return self;
}
//*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/* */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = cfObject.name;
//	[self.imageView setMultipleTouchEnabled:YES];
//	self.imageView.exclusiveTouch = YES;
	[NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];	
}
/* */




-(UIImage*)imageByScalingToSize:(CGSize)targetSize withImage:(UIImage *)image {
	
	UIImage* sourceImage = image; 
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGImageRef imageRef = [sourceImage CGImage];
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
	if (bitmapInfo == kCGImageAlphaNone) {
		bitmapInfo = kCGImageAlphaNoneSkipLast;
	}
	
	CGContextRef bitmap;
	
	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
	}	
	
	
	// In the right or left cases, we need to switch scaledWidth and scaledHeight,
	// and also the thumbnail point
	if (sourceImage.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationUp) {
		// NOTHING
	} else if (sourceImage.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
		CGContextRotateCTM (bitmap, radians(-180.));
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return newImage; 
}

-(UIImage *)resizeImage:(UIImage *)image {
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	int width, height;
	
	width = 640;
	height = 480;
	
	CGContextRef bitmap;
	
	if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);		
	}
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		NSLog(@"image orientation left");
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		NSLog(@"image orientation right");
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		NSLog(@"image orientation up");	
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		NSLog(@"image orientation down");	
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, radians(-180.));
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;	
}






/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// hide and unhide the imageScrollView so it doesn't interfere with other tabs
- (void)viewWillDisappear:(BOOL)animated {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	app.imageScrollView.hidden = YES;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
	RackspaceAppDelegate *app = (RackspaceAppDelegate *) [[UIApplication sharedApplication] delegate];
	app.imageScrollView.hidden = NO;	
	
	// hide the chrome so they can still play with the image
	[NSThread detachNewThreadSelector:@selector(hideChrome:) toTarget:self withObject:nil];
	
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
}

- (void)dealloc {
//	[account release];
//	[container release];
//	[containerName release];
//	[cfObject release];
//	[imageView release];
//	[spinner release];
	
	//[img release];
    [super dealloc];
}


@end
