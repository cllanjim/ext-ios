#import "NSUserDefaults.h"

@implementation NSUserDefaults (NSUserDefaultsExtensions)

- (void)saveCustomObject:(id)object key:(NSString *)key
{
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

- (id)loadCustomObjectWithKey:(NSString *)key
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData* encodedObject = [defaults objectForKey:key];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

@end
