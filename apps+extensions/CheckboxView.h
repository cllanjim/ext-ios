typedef NS_ENUM( NSUInteger, CheckboxViewStyle )
{
    CheckboxViewStyleOpenCircle,
    CheckboxViewStyleGrayedOut
};

@interface CheckboxView : UIView

- (BOOL)checked;

- (void)setChecked:(BOOL)checked;

- (CheckboxViewStyle)style;

- (void)setStyle:(CheckboxViewStyle)aStyle;

@end
