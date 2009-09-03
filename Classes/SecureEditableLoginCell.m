#import "SecureEditableLoginCell.h"

@implementation SecureEditableLoginCell

@synthesize labelField, textField;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		
        labelField = [[UILabel alloc] initWithFrame:CGRectZero];
        labelField.font = [UIFont boldSystemFontOfSize:12];
        labelField.textColor = [UIColor darkGrayColor];
        labelField.textAlignment = UITextAlignmentLeft;
        labelField.backgroundColor = [UIColor clearColor];
		[self addSubview:labelField];
		
		// Set the frame to CGRectZero as it will be reset in layoutSubviews
        textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //textField.font = [UIFont systemFontOfSize:32.0];
        //textField.textColor = [UIColor purpleColor];
		textField.textColor = [UIColor blackColor];
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.returnKeyType = UIReturnKeyDone;
		
		textField.secureTextEntry = YES;	// make the text entry secure (bullets)
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
        [self addSubview:textField];
    }
    return self;
}

- (void)dealloc {
    // Release allocated resources.
	[labelField release];
    [textField release];
    [super dealloc];
}

- (void)layoutSubviews {
    // Place the subviews appropriately.
    CGRect baseRect = CGRectInset(self.contentView.bounds, 18, 0);
    CGRect labelRect = baseRect;
    CGRect textRect = baseRect;
	
	//rect.origin.x += 15;
    
	// Position each label with a modified version of the base rect.
	labelRect.origin.x += 5;
	labelRect.size.width = 90;
	labelField.frame = labelRect;
	
	textRect.origin.x += 90;
	textRect.size.width -= 90; // to prevent scrolling off the side
	textField.frame = textRect;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Update text color so that it matches expected selection behavior.
    if (selected) {
        textField.textColor = [UIColor whiteColor];
    } else {
        textField.textColor = [UIColor blackColor];
    }
}

@end
