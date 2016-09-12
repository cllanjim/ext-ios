#import "Extensions.h"

@implementation UISearchBar (UISearchBarExtensions)

- (void)setIconColor:(UIColor *)aSearchIconColor withPlaceholderText:(NSString *)aPlaceholderText withPlaceholderColor:(UIColor *)aPlaceholderColor
{
    UITextField* searchField = nil;
    for (UIView* subview in [[self.subviews objectAtIndex:0] subviews])
    {
        if ([subview isKindOfClass:UITextField.class])
        {
            searchField = (UITextField *)subview;
            UIImageView* iconView = (UIImageView *)searchField.leftView;
            iconView.image = [iconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iconView.tintColor = aSearchIconColor;
            
            NSAttributedString* placeholderString = [NSAttributedString.alloc initWithString:aPlaceholderText
                                                                                  attributes:
                                                     @{
                                                       NSForegroundColorAttributeName : aPlaceholderColor
                                                       }];
            UITextField* textField = (UITextField *)subview;
            textField.attributedPlaceholder = placeholderString;
        }
    }
}

@end
