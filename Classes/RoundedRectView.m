//
//  RoundedRectView.m
//
//  Created by Jeff LaMarche on 11/13/08.

#import "RoundedRectView.h"

@implementation RoundedRectView
@synthesize strokeColor;
@synthesize rectColor;
@synthesize strokeWidth;
@synthesize cornerRadius;
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        self.strokeColor = kDefaultStrokeColor;
        self.backgroundColor = [UIColor clearColor];
		super.backgroundColor = [UIColor clearColor];
        self.strokeWidth = kDefaultStrokeWidth;
        self.rectColor = kDefaultRectColor;
        self.cornerRadius = kDefaultCornerRadius;
    }
    return self;
}

- (id)initWithDefaultFrame {
	CGRect rect = CGRectMake(-170, -216, 900, 900);
	self = [self initWithFrame:rect];
	self.rectColor = [UIColor blackColor];
	self.strokeWidth = 0;
	self.alpha = 0;
	self.cornerRadius = 45.0;
	self.backgroundColor = [UIColor clearColor];
	return self;
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code
        self.opaque = NO;
        self.strokeColor = kDefaultStrokeColor;
        self.backgroundColor = [UIColor clearColor];
		super.backgroundColor = [UIColor clearColor];
        self.rectColor = kDefaultRectColor;
        self.strokeWidth = kDefaultStrokeWidth;
        self.cornerRadius = kDefaultCornerRadius;
		
		// add label
		CGRect labelRect = CGRectMake(0, 108, 150, 30);
		UILabel *saving = [[UILabel alloc] initWithFrame:labelRect];
		saving.textColor = [UIColor whiteColor];
		saving.backgroundColor = [UIColor clearColor];
		saving.textAlignment = UITextAlignmentCenter;
		saving.opaque = NO;
		saving.alpha = 1.0;
		saving.text = @"Saving";
		[self addSubview:saving];
		
		// add spinner
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		CGRect spinnerRect = spinner.frame;
		spinnerRect.origin.x = spinnerRect.origin.y = 75 - (spinnerRect.size.width / 2);
		spinner.frame = spinnerRect;
		
		[spinner startAnimating];
		[self addSubview:spinner];
    }
    return self;
}
- (void)setBackgroundColor:(UIColor *)newBGColor
{
    // Ignore any attempt to set background color - backgroundColor must stay set to clearColor
    // We could throw an exception here, but that would cause problems with IB, since backgroundColor
    // is a palletized property, IB will attempt to set backgroundColor for any view that is loaded
    // from a nib, so instead, we just quietly ignore this.
    //
    // Alternatively, we could put an NSLog statement here to tell the programmer to set rectColor...
}
- (void)setOpaque:(BOOL)newIsOpaque
{
    // Ignore attempt to set opaque to YES.
}
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.rectColor.CGColor);
    
    CGRect rrect = self.bounds;
    
    CGFloat radius = cornerRadius;
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;    
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)show {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];	
	self.frame = CGRectMake(85, 108, 150, 150);
	self.alpha = 0.7;
	[UIView commitAnimations];
}

- (void)hide {
	if (self.alpha != 0.0) { // if it's visible
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		self.frame = CGRectMake(-170, -216, 900, 900);
		self.alpha = 0.0;
		[UIView commitAnimations];
	}
}

- (void)dealloc {
    [strokeColor release];
    [rectColor release];
    [super dealloc];
}

@end