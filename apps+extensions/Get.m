#import "Extensions.h"

@implementation Get

+ (unsigned long long)freeSpaceOnDisk
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [FileManager attributesOfFileSystemForPath:[paths lastObject] error: nil];
    
    if (dictionary)
    {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        return [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    return 0;
}

@end
