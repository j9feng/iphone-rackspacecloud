

#import <UIKit/UIKit.h>

@interface EditableCell : UITableViewCell {
	UITextField *labelField;
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *labelField;
@property (nonatomic, retain) UITextField *textField;

@end
