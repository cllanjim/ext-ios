#import "NSUserDefaultsExtensions.h"

@implementation NSUserDefaults (NSUserDefaultsExtensions)

- (void)saveCustomObject:(id)object key:(NSString *)key withSuiteName:(NSString *)aSuiteName
{
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults* defaults = [NSUserDefaults.alloc initWithSuiteName:aSuiteName];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

- (id)loadCustomObjectWithKey:(NSString *)key withSuiteName:(NSString *)aSuiteName
{
    NSUserDefaults* defaults = [NSUserDefaults.alloc initWithSuiteName:aSuiteName];
    NSData* encodedObject = [defaults objectForKey:key];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

@end
