#import <UIKit/UIKit.h>

@interface NSString (NSStringExtensions)

- (BOOL)fileExists;

- (BOOL)directoryExists;

- (BOOL)fileOrDirMoveTo:(NSString *)newPath;

- (BOOL)fileOrDirRename:(NSString *)aNewFileName;

- (BOOL)fileOrDirCopyTo:(NSString *)newPath;

- (BOOL)fileOrDirDelete;

- (unsigned long long)fileSize;

- (void)directoryEnsureExists;

- (void)directorySize:(void (^)(unsigned long long directorySize))gotSize;

- (unsigned long long)directorySize_sync;

- (NSArray *)directoryGetImagesFilesPaths;

- (NSArray *)directoryGetFilesPathsWithPredicate:(NSString*)predicateWithFormat;

- (NSString *)pathAppend:(NSString*)pathToAppend;

- (long)longValue;

- (NSDate *)timestampMillisecondsToDate;

- (NSDate *)timestampToDate;

- (NSURL *)getURL;

- (NSURL *)getFileURL;

- (NSString *)trim;

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

- (UIColor *)hexToColor;

- (NSString *)concat:(NSString*)firstArg, ... NS_REQUIRES_NIL_TERMINATION;

- (NSString *)pathCombine:(NSString*)firstArg, ... NS_REQUIRES_NIL_TERMINATION;

- (BOOL)isEmptyOrWhitespace;

- (UIImage *)loadImage;

@end
