#import "NSUserDefaultsExtensions.h"

#define SuiteNameForExtensions @"group.es.phram.phrames"

@implementation NSUserDefaults (NSUserDefaultsExtensions)

- (void)saveCustomObject:(id)object key:(NSString *)key
{
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults* defaults = [NSUserDefaults.alloc initWithSuiteName:SuiteNameForExtensions];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

- (id)loadCustomObjectWithKey:(NSString *)key
{
    NSUserDefaults* defaults = [NSUserDefaults.alloc initWithSuiteName:SuiteNameForExtensions];
    NSData* encodedObject = [defaults objectForKey:key];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

@end
