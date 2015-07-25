#import <MessageUI/MessageUI.h>

@interface SendMail : UIViewController

- (instancetype)initWithViewController:(UIViewController *)aViewController withDelegate:(id<MFMailComposeViewControllerDelegate>)aDelegate withSubject:(NSString *)aSubject withTextBody:(NSString *)aTextBody withRecipient:(NSString *)aRecipient withModalTransitionStyle:(UIModalTransitionStyle)aModalTransitionStyle;

- (void)showComposer;

@end
