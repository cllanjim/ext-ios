#import "RoundedView.h"
#import "AppExtensions.h"

@implementation RoundedView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setCornersRounded:YES withRasterization:YES];
}

@end
