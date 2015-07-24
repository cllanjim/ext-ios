#import "Extensions.h"

@implementation UISearchBar (UISearchBarExtensions)

- (void)setSearchIconWithColor:(UIColor*)aUIColor
{
    UITextField *searchField = nil;
    for (UIView *subview in [[self.subviews objectAtIndex:0] subviews])
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchField = (UITextField *)subview;
            UIImageView *iconView = (UIImageView*)searchField.leftView;
            iconView.image = [iconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iconView.tintColor = aUIColor;
        }
    }
}

@end
