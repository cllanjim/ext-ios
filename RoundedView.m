#import "RoundedView.h"
#import "Extensions.h"

@implementation RoundedView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self roundTheCorners];
}

@end
