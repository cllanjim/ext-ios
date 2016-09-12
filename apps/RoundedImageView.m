#import "RoundedImageView.h"
#import "AppExtensions.h"

@implementation RoundedImageView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setCornersRounded:YES withRasterization:YES];
}

@end
