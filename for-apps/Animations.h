@interface Animations : NSObject

@property UIColor *color;
@property float duration;
@property NSUInteger borderWidth;
@property NSUInteger cornerRadius;
@property NSUInteger opacity;
@property CGFloat initDelay;

- (instancetype)init;
- (void)showCircleShapeAnimationAroundUIElement:(id)anUIElement withTarget:(UIView *)aTarget withSender:(UIView *)aSender;
- (void)animateFauxBounceWithView:(UIView *)view;
- (void)disappearWithDissolve:(id)sender;
- (void)reappearWithDissolve:(id)sender;

@end
