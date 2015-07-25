#import "SendMail.h"

@implementation SendMail
{
    UIViewController* _viewController;
    id<MFMailComposeViewControllerDelegate> _delegate;
    NSString* _subject;
    NSString* _textBody;
    NSString* _recipient;
    UIModalTransitionStyle _modalTransitionStyle;
}

- (instancetype)initWithViewController:(UIViewController *)aViewController withDelegate:(id<MFMailComposeViewControllerDelegate>)aDelegate withSubject:(NSString *)aSubject withTextBody:(NSString *)aTextBody withRecipient:(NSString *)aRecipient withModalTransitionStyle:(UIModalTransitionStyle)aModalTransitionStyle
{
    self = [super init];
    if (self)
    {
        _viewController = (UIViewController<MFMailComposeViewControllerDelegate>*)aViewController;
        _delegate = aDelegate;
        _subject = aSubject;
        _textBody = aTextBody;
        _recipient = aRecipient;
        _modalTransitionStyle = aModalTransitionStyle;
    }
    return self;
}


#pragma mark - Custom

- (void)showComposer
{
    MFMailComposeViewController* mailComposer = MFMailComposeViewController.new;
    if (mailComposer == nil) return;
    
    mailComposer.mailComposeDelegate = _delegate;
    mailComposer.subject = _subject;
    [mailComposer setMessageBody:_textBody isHTML:NO];
    mailComposer.modalTransitionStyle = _modalTransitionStyle;
    mailComposer.toRecipients = [NSArray arrayWithObject:_recipient];
    [_viewController presentViewController:mailComposer animated:YES completion:NULL];
}

@end
