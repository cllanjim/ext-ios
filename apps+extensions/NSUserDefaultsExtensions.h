@interface NSUserDefaults (NSUserDefaultsExtensions)

- (void)saveCustomObject:(id)object key:(NSString *)key withSuiteName:(NSString *)aSuiteName;

- (id)loadCustomObjectWithKey:(NSString *)key withSuiteName:(NSString *)aSuiteName;

@end
