#import "Extensions.h"

@interface UIViewController (UIViewControllerExtensions)

- (void)showAlertWithTitle:(NSString *)aTitle withMessage:(NSString *)aMessage withButtonString:(NSString *)buttonString;

- (void)showAlertWithTitle:(NSString *)aTitle withMessage:(NSString *)aMessage withButtonString:(NSString *)buttonString withDestructiveAction:(BOOL)isDestructiveAction withButtonCallback:(void(^)(void))aConfirmCallback withOptionalCancelString:(NSString *)cancelString withOptionalCancelCallback:(void(^)(void))aCancelCallback;

- (void)showActionSheetWithTitle:(NSString *)aTitle withMessage:(NSString *)aMessage withButtonString:(NSString *)buttonString withDestructiveAction:(BOOL)isDestructiveAction withButtonCallback:(void(^)(void))aConfirmCallback withOptionalCancelString:(NSString *)cancelString withOptionalCancelCallback:(void(^)(void))aCancelCallback;

- (UIBarButtonItem *)showLoadingMenuItem;

- (void)hideLoadingMenuItem:(UIBarButtonItem *)loadingItem;

@end