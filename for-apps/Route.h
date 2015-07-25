@interface Route : NSObject

@property NSString* path;
@property NSDictionary* parameters;

- (instancetype)initWithPath:(NSString *)aPath parameters:(NSDictionary *)someParameters;

- (NSString *)getUrl;

- (NSURL *)getURL;

+ (Route *)routeWithPath:(NSString *)aPath;

+ (Route *)routeWithPath:(NSString *)aPath parameters:(NSDictionary *)someParameters;

@end
