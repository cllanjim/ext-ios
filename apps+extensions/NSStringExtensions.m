#import "Extensions.h"

@implementation NSString (NSStringExtensions)

#pragma mark - Files

- (BOOL)fileExists
{
    BOOL isDir;
    BOOL fileExists = [FileManager fileExistsAtPath:self isDirectory:&isDir];
    return fileExists && !isDir;
}

- (unsigned long long)fileSize
{
    NSDictionary* fileAttributes = [FileManager attributesOfItemAtPath:self error:nil];
    return fileAttributes.fileSize;
}


#pragma mark - Files or Directories

- (BOOL)fileOrDirMoveTo:(NSString *)newPath
{
    NSError* error;
    int retryCounter = 5;
    BOOL result;
    
    while (!(result = [FileManager moveItemAtPath:self toPath:newPath error:&error]) && retryCounter > 0)
    {
        retryCounter--;
        // BugFix, suddenly this hapens...
        NSLog(@"Unable to move file/directory, retrying (%d).", 5-retryCounter);
    }
    return result;
}

- (BOOL)fileOrDirRename:(NSString *)aNewFileName
{
    return [self fileOrDirMoveTo:[self.stringByDeletingLastPathComponent pathAppend:aNewFileName]];
}


- (BOOL)fileOrDirCopyTo:(NSString *)newPath
{
    return [FileManager copyItemAtPath:self toPath:newPath error:nil];
}

- (BOOL)fileOrDirDelete
{
    return [FileManager removeItemAtPath:self error:nil];
}


#pragma mark - Directories

- (BOOL)directoryExists
{
    BOOL isDir;
    BOOL fileExists = [FileManager fileExistsAtPath:self isDirectory:&isDir];
    return fileExists && isDir;
}

- (void)directoryEnsureExists
{
    NSFileManager* fm = FileManager;
    BOOL isDir;
    BOOL fileExists = [fm fileExistsAtPath:self isDirectory:&isDir];
    if (fileExists && !isDir)
    {
        [fm removeItemAtPath:self error:nil];
    }
    else if (!fileExists)
    {
        [fm createDirectoryAtPath:self withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)directorySize:(void (^)(unsigned long long directorySize))gotSize
{
    [Run onGlobalQueue:^{
        unsigned long long directorySize = [self directorySize_sync];
        CallBlock(gotSize, directorySize);
    }];
}

- (unsigned long long)directorySize_sync
{
    unsigned long long contentSize = 0;
    NSDirectoryEnumerator *enumerator = [FileManager enumeratorAtURL:[NSURL URLWithString:self] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLFileSizeKey] options:0 errorHandler:NULL];
    NSNumber *value = nil;
    for (NSURL *itemURL in enumerator)
    {
        if ([itemURL getResourceValue:&value forKey:NSURLFileSizeKey error:NULL])
        {
            contentSize += value.unsignedLongLongValue;
        }
    }
    return contentSize;
}

- (NSArray *)directoryGetImagesFilesPaths
{
    return [self directoryGetFilesPathsWithPredicate:@"(self ENDSWITH '.jpg') OR (self ENDSWITH '.jpeg') OR (self ENDSWITH '.png')"];
}

- (NSArray *)directoryGetFilesPathsWithPredicate:(NSString*)predicateWithFormat
{
    NSArray* dirFiles = [FileManager contentsOfDirectoryAtPath:self error:nil];
    NSArray* filteredFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateWithFormat]];
    NSMutableArray* fullPaths = NSMutableArray.new;
    for (NSString* fileName in filteredFiles)
    {
        [fullPaths addObject:[self stringByAppendingPathComponent:fileName]];
    }
    return fullPaths;
}


#pragma mark - Path

- (NSString *)pathAppend:(NSString*)pathToAppend
{
    return [self stringByAppendingPathComponent:pathToAppend];
}


#pragma mark - Conversions

- (long)longValue
{
    return (long)self.longLongValue;
}

#pragma mark - String manipulation

- (NSDate *)timestampMillisecondsToDate
{
    NSTimeInterval aTimestamp = self.doubleValue;
    return [NSDate dateWithTimeIntervalSince1970:aTimestamp / 1000];
}

- (NSDate *)timestampToDate
{
    NSTimeInterval aTimestamp = self.doubleValue;
    return [NSDate dateWithTimeIntervalSince1970:aTimestamp];
}


- (NSURL *)getURL
{
    return [NSURL URLWithString:self];
}

- (NSURL *)getFileURL
{
    return [NSURL fileURLWithPath:self];
}


- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (UIColor *)hexToColor
{
    NSString *noHashString = [self stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]];
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

- (NSString *)concat:(NSString*)firstArg, ...
{
    NSMutableString* concatenation = self.mutableCopy;
    va_list args;
    va_start(args, firstArg);
    for (NSString* arg = firstArg; arg != nil; arg = va_arg(args, NSString*))
    {
        [concatenation appendString:arg];
    }
    va_end(args);
    return concatenation;
}

- (NSString *)pathCombine:(NSString*)firstArg, ...
{
    NSString* combination = self.copy;
    va_list args;
    va_start(args, firstArg);
    for (NSString* arg = firstArg; arg != nil; arg = va_arg(args, NSString*))
    {
        combination = [combination pathAppend:arg];
    }
    va_end(args);
    return combination;
}

#pragma mark - UIImages

- (UIImage *)loadImage
{
    return [UIImage imageWithContentsOfFile:self];
}


@end
