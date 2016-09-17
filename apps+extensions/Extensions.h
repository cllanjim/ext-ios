#import "NSStringExtensions.h"
#import "NSDateExtensions.h"
#import "NSUserDefaultsExtensions.h"
#import "UIImageExtensions.h"
#import "NSArrayExtensions.h"
#import "Get.h"
#import "Run.h"

#define LongToString(value)         [NSString stringWithFormat:@"%ld", (value)]
#define LongLongToString(value)     [NSString stringWithFormat:@"%lld", (value)]
#define IntToString(value)          [NSString stringWithFormat:@"%d", (value)]
#define UIntToString(value)         [NSString stringWithFormat:@"%lu", (unsigned long)(value)]
#define FloatToString(value)        [NSString stringWithFormat:@"%f", (value)]
#define StrFormat(string, ...)      [NSString stringWithFormat:string, __VA_ARGS__,nil]
#define Concat(string, ...)         [string concat:__VA_ARGS__,nil]
#define PathCombine(string, ...)    [string pathCombine:__VA_ARGS__,nil]
#define RandomInt(min, max)         ((min) + arc4random_uniform((max) - (min) + 1))

#define IsStrNilOrWhitespace(str) ((str) == nil || ((NSString *)(str)).isEmptyOrWhitespace)


#define DeviceScreenRect        UIScreen.mainScreen.bounds
#define DeviceScreenSize        UIScreen.mainScreen.bounds.size
#define WindowRect         UIApplication.sharedApplication.delegate.window.bounds
#define WindowSize         UIApplication.sharedApplication.delegate.window.bounds.size

#define isRunningInFullScreen (CGRectEqualToRect(WindowRect, DeviceScreenRect))

#define isIpad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isIphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define isIpad2 (isIpad && ((DeviceScreenSize.width == 768 && DeviceScreenSize.height == 1024) || (DeviceScreenSize.width == 1024 && DeviceScreenSize.height == 768)))
#define iPhone4_5_6_6p(value4,value5,value6,value6p) (DeviceScreenSize.height < 568 ? (value4) : (DeviceScreenSize.width < 375 ? (value5) : (DeviceScreenSize.width > 375 ? (value6p) : (value6))))
#define iPhone_iPad(iPhoneValue,iPadValue) (isIpad ? (iPadValue) : (iPhoneValue))
#define iOS10OrNewer (NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 10)

#define Limit(number,min,max) ((number) < (min) ? min : ((number) > (max) ? (max) : (number)))

#define NavigationBarHeight                 44

#define CallBlock(blockName, ...)               if(blockName) blockName(__VA_ARGS__);
#define CallBlockOnMainQueue(blockName, ...)    if(NSThread.isMainThread) {CallBlock(blockName, __VA_ARGS__);} else {dispatch_async(dispatch_get_main_queue(), ^{ CallBlock(blockName, __VA_ARGS__); });}
#define CallBlockOnGlobalQueue(blockName, ...)  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{ CallBlock(blockName, __VA_ARGS__); });
#define VoidBlock void(^)(void)
#define Weaken(name) __weak typeof(name) name##Weak = name;

#define SendNotificationWithInfo(notificationName, info) dispatch_async(dispatch_get_main_queue(), ^{ [NSNotificationCenter.defaultCenter postNotificationName:notificationName object:self userInfo:info]; });
#define SendNotification(notificationName) dispatch_async(dispatch_get_main_queue(), ^{ [NSNotificationCenter.defaultCenter postNotificationName:notificationName object:self]; });
#define RegisterNotification(notificationName, methodName) [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(methodName) name:notificationName object:nil];
#define UnRegisterNotification(notificationName) [NSNotificationCenter.defaultCenter removeObserver:self name:notificationName object:nil];

#define IgnoringInteraction                     (UIApplication.sharedApplication.isIgnoringInteractionEvents)
#define DisableInteraction                      [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#define EnableInteraction                       if (IgnoringInteraction){[UIApplication.sharedApplication endIgnoringInteractionEvents];}

#define Throw(exceptionString)                  [NSException raise:@"Exception" format:@"%@", exceptionString];
#define ThrowWithFormat(exceptionString, ...)   [NSException raise:@"Exception" format:exceptionString, __VA_ARGS__];

#define ThisClassName                   NSStringFromClass(self.class)
#define ClassName(theClass)             NSStringFromClass(theClass.class)
#define CFLog(format, ...)              NSLog(Concat(@"%@: ", (format)), NSStringFromClass(self.class), __VA_ARGS__);
#define CLog(message)                   CFLog(@"%@", (message));
#define CountReferences(object)         CFGetRetainCount((__bridge CFTypeRef)object)

#define NotImplemented                  { [NSException raise:@"Not implemented" format:@"Not implemented"]; }
#define NotImplementedRet               { NotImplemented return nil; }
#define NotImplementedRetNum            { NotImplemented return 0; }

#define GenerateGUID            NSUUID.UUID.UUIDString
#define FileManager             NSFileManager.defaultManager
#define DocumentsPath           ((NSString*)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])
#define CachesPath              ((NSString*)[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0])
#define TempPath                NSTemporaryDirectory()
#define Language                [[NSLocale.preferredLanguages objectAtIndex:0] substringWithRange:NSMakeRange(0, 2)]

#define Localize(string, ...)   [NSBundle.mainBundle localizedStringForKey:(string) value:@"" table:nil]
#define Pause(seconds)          [NSThread sleepForTimeInterval:(seconds)]

#if TARGET_IPHONE_SIMULATOR
#   define ReturnIfSimulator return;
#   define ReturnIfNotSimulator ;
#else
#   define ReturnIfSimulator ;
#   define ReturnIfNotSimulator return;
#endif
