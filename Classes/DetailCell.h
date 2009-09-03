/*
     File: DetailCell.h
 Abstract: 
 Custom table cell used in the main view's table. Capable of displaying in two modes - a "type:name" mode for existing
 data and a "prompt" mode when used as a placeholder for data creation.
 
  Version: 1.1
 */

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell {
    UITextField *type;
    UITextField *name;
    UITextField *prompt;
    BOOL promptMode;
}

@property (readonly, retain) UITextField *type;
@property (readonly, retain) UITextField *name;
@property (readonly, retain) UITextField *prompt;
@property BOOL promptMode;

@end
