#import "FadePushAnimation.h"

@implementation FadePushAnimation
{
    CGFloat _transitionDuration;
}

- (instancetype)init
{
    self = [self initWithDuration:0.3];
    return self;
}

- (instancetype)initWithDuration:(CGFloat)duration
{
    if (self = [super init])
    {
        _transitionDuration = duration;
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* toView = toVC.view;
    UIView* fromView = fromVC.view;
    
    UIView* containerView = transitionContext.containerView;
    [containerView addSubview:toView];
    [containerView sendSubviewToBack:toView];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^
     {
         fromView.alpha = 0.0;
     } completion:^(BOOL finished)
     {
         if (transitionContext.transitionWasCancelled)
         {
             fromView.alpha = 1.0;
         } else {
             [fromView removeFromSuperview];
             fromView.alpha = 1.0;
         }
         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
     }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _transitionDuration;
}

@end
