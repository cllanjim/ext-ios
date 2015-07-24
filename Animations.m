#import "Animations.h"

@implementation Animations

- (instancetype)init
{
    if (self = [super init])
    {
        _color = [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1];
        _duration = 0.5f;
        _borderWidth = 2;
        _cornerRadius = 50;
        _opacity = 0;
        _initDelay = 0.0f;
    }
    return self;
}

- (void)showCircleShapeAnimationAroundUIElement:(id)anUIElement withTarget:(UIView *)aTarget withSender:(UIView *)aSender
{
    UIColor* stroke = _color;
    UIView *view = anUIElement;
    
    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.fromValue = (id)[UIColor clearColor].CGColor;
    borderAnimation.toValue = (id)stroke.CGColor;
    borderAnimation.duration = _duration;
    [view.layer addAnimation:borderAnimation forKey:nil];
    
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(view.bounds), -CGRectGetMidY(view.bounds), view.bounds.size.width, view.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:_cornerRadius];
    
    CGPoint shapePosition = [aSender convertPoint:view.center fromView:aTarget];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = _opacity;
    circleShape.strokeColor = stroke.CGColor;
    circleShape.lineWidth = _borderWidth;
    
    [aSender.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = _duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

- (void)animateFauxBounceWithView:(UIView *)view {
    [UIView animateWithDuration:0.2
                          delay:(_initDelay)
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut
                     animations:^{
                         view.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
                         view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1 animations:^{
                             view.layer.transform = CATransform3DIdentity;
                         }];
                     }];
}

- (void)disappearWithDissolve:(id)sender
{
    UIView *senderView = (UIView*)sender;
    [UIView animateWithDuration:0.5 animations:^{
                        senderView.alpha = 0.0;
                    }
                    completion:NULL];
}

- (void)reappearWithDissolve:(id)sender
{
    UIView *senderView = (UIView*)sender;
    [UIView animateWithDuration:0.5 animations:^{
        senderView.alpha = 1.0;
    }
                     completion:NULL];
}

@end
