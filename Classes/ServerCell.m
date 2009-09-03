//
//  ServerCell.m
//  Rackspace
//
//  Created by Michael Mayo on 3/6/09.
//  Copyright 2009 Michael Mayo. All rights reserved.
//

#import "ServerCell.h"
#import "Server.h"

static UIImage *debianImage = nil;
static UIImage *gentooImage = nil;
static UIImage *ubuntuImage = nil;
static UIImage *archImage = nil;
static UIImage *centosImage = nil;
static UIImage *fedoraImage = nil;

@interface ServerCell()
- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
@end

@implementation ServerCell

@synthesize server, nameLabel, bandwidthLabel, logoImage;

+ (void)initialize
{
    // The images are cached as part of the class, so they need to be explicitly retained.
	debianImage = [[UIImage imageNamed:@"debian.png"] retain];
	gentooImage = [[UIImage imageNamed:@"gentoo.png"] retain];
	ubuntuImage = [[UIImage imageNamed:@"ubuntu.png"] retain];
	archImage = [[UIImage imageNamed:@"arch.png"] retain];
	centosImage = [[UIImage imageNamed:@"centos.png"] retain];
	fedoraImage = [[UIImage imageNamed:@"fedora.png"] retain];
}


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        UIView *myContentView = self.contentView;
        
        // Add an image view to display the server logo
		self.logoImage = [[UIImageView alloc] initWithImage:debianImage];
		[myContentView addSubview:self.logoImage];
        [self.logoImage release];
        
        // A label that displays the location of the earthquake.
        self.nameLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:18.0 bold:YES]; 
		self.nameLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.nameLabel];
		[self.nameLabel release];
        
        // A label that displays the date of the earthquake.
        self.bandwidthLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:14.0 bold:NO];
		self.bandwidthLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.bandwidthLabel];
		[self.bandwidthLabel release];
        
        // A label that displays the magnitude of the earthquake.
//        self.earthquakeMagnitudeLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:24.0 bold:YES];
//		self.earthquakeMagnitudeLabel.textAlignment = UITextAlignmentRight;
//		[myContentView addSubview:self.earthquakeMagnitudeLabel];
//		[self.earthquakeMagnitudeLabel release];
        
        // Position the magnitudeImageView above all of the other views so
        // it's not obscured. It's a transparent image, so any views
        // that overlap it will still be visible.
        [myContentView bringSubviewToFront:self.logoImage];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIImage *)imageForServer:(Server *)s {

	if ([s.imageId isEqualToString:@"2"]) {
		return centosImage;
	} else if ([s.imageId isEqualToString:@"3"]) {
		return gentooImage;
	} else if ([s.imageId isEqualToString:@"4"]) {
		return debianImage;
	} else if ([s.imageId isEqualToString:@"5"]) {
		return fedoraImage;
	} else if ([s.imageId isEqualToString:@"9"]) {
		return archImage;
	} else if ([s.imageId isEqualToString:@"10"]) {
		return ubuntuImage;
	} else if ([s.imageId isEqualToString:@"11"]) {
		return ubuntuImage;
	}

	return nil;
}


// Rather than using one of the standard UITableViewCell content properties like 'text',
// we're using a custom property called 'quake' to populate the table cell. Whenever the
// value of that property changes, we need to call [self setNeedsDisplay] to force the
// cell to be redrawn.
- (void)setServer:(Server *)newServer
{
    [newServer retain];
    [server release];
    server = newServer;
    
    self.nameLabel.text = newServer.serverName;
	//self.bandwidthLabel.text = [NSString stringWithFormat:@"%@ GB in / %@ GB out", newServer.bwIn, newServer.bwOut];
	self.bandwidthLabel.text = @"Ubuntu 8.0.4 - 2 GB";
    self.logoImage.image = [self imageForServer:newServer];
    
    [self setNeedsDisplay];
}



- (void)layoutSubviews {
    
	#define LEFT_COLUMN_OFFSET 10
	#define LEFT_COLUMN_WIDTH 200
	
	#define MIDDLE_COLUMN_OFFSET 50
	#define MIDDLE_COLUMN_WIDTH 100
	
	#define UPPER_ROW_TOP 4
	#define LOWER_ROW_TOP 28
    
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	
	// we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		
        CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
        
        // Place the location label.
		frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP + 4, 35, 35);

 		self.logoImage.frame = frame;        
        
        // Place the date label.
		frame = CGRectMake(boundsX + 4 + MIDDLE_COLUMN_OFFSET, LOWER_ROW_TOP, LEFT_COLUMN_WIDTH, 18);
		self.bandwidthLabel.frame = frame;
        
        // Place the waveform image.
//        frame = [self.logoImage frame];
//		frame.origin.x = boundsX + MIDDLE_COLUMN_OFFSET;
//		frame.origin.y = 0;

		frame = CGRectMake(boundsX + 4 + MIDDLE_COLUMN_OFFSET, UPPER_ROW_TOP, LEFT_COLUMN_WIDTH, 22);

 		//imageView.frame = frame;        
		self.nameLabel.frame = frame;
    }
}


- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    /*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.
	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = [UIColor whiteColor];
	newLabel.font = font;
	
	return newLabel;
}

@end
