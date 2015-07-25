#import "Route.h"

@implementation Route

- (instancetype)initWithPath:(NSString *)aPath parameters:(NSDictionary *)someParameters
{
    if (self = [super init])
    {
        _path = aPath;
        _parameters = someParameters;
    }
    return self;
}

- (NSString *)getUrl
{
    NSMutableString* paramsString = nil;
    
    if (_parameters) {
        //build a simple url encoded param string
        paramsString = [NSMutableString stringWithString:@"?"];
        for (NSString* key in [[_parameters allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            [paramsString appendFormat:@"%@=%@&", key, [Route urlEncode:_parameters[key]] ];
        }
        if ([paramsString hasSuffix:@"&"]) {
            paramsString = [[NSMutableString alloc] initWithString: [paramsString substringToIndex: paramsString.length-1]];
        }
        return [NSString stringWithFormat:@"%@%@", _path, paramsString];
    }
    return _path;
}

- (NSURL *)getURL
{
    return [NSURL URLWithString:self.getUrl];
}

+ (Route *)routeWithPath:(NSString *)aPath
{
    return [Route.alloc initWithPath:aPath parameters:nil];
}

+ (Route *)routeWithPath:(NSString *)aPath parameters:(NSDictionary *)someParameters
{
    return [Route.alloc initWithPath:aPath parameters:someParameters];
}

+ (NSString *)urlEncode:(id<NSObject>)value
{
    //make sure param is a string
    if ([value isKindOfClass:NSNumber.class]) {
        value = [(NSNumber*)value stringValue];
    }
    
    NSAssert([value isKindOfClass:NSString.class], @"request parameters can be only of NSString or NSNumber classes. '%@' is of class %@.", value, value.class);
    
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes
                                         (
                                          NULL,
                                          (__bridge CFStringRef) value,
                                          NULL,
                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                          kCFStringEncodingUTF8));
}


@end