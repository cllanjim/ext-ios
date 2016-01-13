#import "RoundedImageView.h"
#import "Extensions.h"

@implementation RoundedImageView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setCornersRounded:YES withRasterization:YES];
}

@end
