#import "RoundedImageView.h"
#import "Extensions.h"

@implementation RoundedImageView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self roundTheCorners:YES];
}

@end
