#import "UIViewControllerExtensions.h"

@implementation UIViewController (UIViewControllerExtensions)

- (void)showAlertWithTitle:(NSString *)aTitle withMessage:(NSString *)aMessage withButtonString:(NSString *)buttonString
{
    [self showAlertWithTitle:aTitle withMessage:aMessage withButtonString:buttonString withDestructiveAction:NO withButtonCallback:nil withOptionalCancelString:nil withOptionalCancelCallback:nil];
}

- (void)showAlertWithTitle:(NSString *)aTitle withMessage:(NSString *)aMessage withButtonString:(NSString *)buttonString withDestructiveAction:(BOOL)isDestructiveAction withButtonCallback:(VoidBlock)aConfirmCallback withOptionalCancelString:(NSString *)cancelString withOptionalCancelCallback:(VoidBlock)aCancelCallback
{
    [self showAlertControllerWithStyle:UIAlertControllerStyleAlert withTitle:aTitle withMessage:aMessage withButtonString:buttonString withDestructiveAction:isDestructiveAction withSourceView:nil withButtonCallback:aConfirmCallback withOptionalCancelString:cancelString withOptionalCancelCallback:aCancelCallback];
}

- (void)showActionSheetWithTitle:(NSString *)aTitle withMessage:(NSString *)aMessage withButtonString:(NSString *)buttonString withDestructiveAction:(BOOL)isDestructiveAction withSourceView:(UIView *)aSourceView withButtonCallback:(VoidBlock)aConfirmCallback withOptionalCancelString:(NSString *)cancelString withOptionalCancelCallback:(VoidBlock)aCancelCallback
{
    [self showAlertControllerWithStyle:UIAlertControllerStyleActionSheet withTitle:aTitle withMessage:aMessage withButtonString:buttonString withDestructiveAction:isDestructiveAction withSourceView:aSourceView withButtonCallback:aConfirmCallback withOptionalCancelString:cancelString withOptionalCancelCallback:aCancelCallback];
}

- (void)showAlertControllerWithStyle:(UIAlertControllerStyle)controllerStyle withTitle:(NSString *)aTitle withMessage:(NSString *)aMessage withButtonString:(NSString *)buttonString withDestructiveAction:(BOOL)isDestructiveAction withSourceView:(UIView *)aSourceView withButtonCallback:(VoidBlock)aConfirmCallback withOptionalCancelString:(NSString *)cancelString withOptionalCancelCallback:(VoidBlock)aCancelCallback
{
    UIAlertController* alertController = [UIAlertController
                                          alertControllerWithTitle:aTitle
                                          message:aMessage
                                          preferredStyle:controllerStyle];
    UIAlertAction* okAction = [UIAlertAction
                               actionWithTitle:buttonString
                               style:isDestructiveAction ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   CallBlockOnMainQueue(aConfirmCallback);
                               }];
    [alertController addAction:okAction];
    
    if (cancelString != nil)
    {
        UIAlertAction* cancelAction = [UIAlertAction
                                       actionWithTitle:cancelString
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action) {
                                           CallBlockOnMainQueue(aCancelCallback);
                                       }];
        [alertController addAction:cancelAction];
    }
    
    alertController.popoverPresentationController.sourceView = aSourceView;
    alertController.popoverPresentationController.sourceRect = aSourceView.bounds;
    [Run onMainQueue:^{
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (UIBarButtonItem *)showLoadingMenuItem
{
    UIBarButtonItem* defaultConfirmButton = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView* activityView = [UIActivityIndicatorView.alloc initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    UIBarButtonItem* loadingView = [UIBarButtonItem.alloc initWithCustomView:activityView];
    [activityView startAnimating];
    [self.navigationItem setRightBarButtonItem:loadingView];
    return defaultConfirmButton;
}

- (void)hideLoadingMenuItem:(UIBarButtonItem *)loadingItem
{
    [self.navigationItem setRightBarButtonItem:loadingItem];
}

@end
