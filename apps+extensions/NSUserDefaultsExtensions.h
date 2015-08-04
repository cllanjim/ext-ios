@interface NSUserDefaults (NSUserDefaultsExtensions)

- (void)saveCustomObject:(id)object key:(NSString *)key;

- (id)loadCustomObjectWithKey:(NSString *)key;

@end
