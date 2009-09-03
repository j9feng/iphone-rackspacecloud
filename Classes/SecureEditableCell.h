

#import <UIKit/UIKit.h>

@interface SecureEditableCell : UITableViewCell {
	UITextField *labelField;
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *labelField;
@property (nonatomic, retain) UITextField *textField;

@end
