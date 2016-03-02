@interface NSDate (NSDateExtensions)

- (NSString*)javaCompatibleUTCDate;

- (NSString *)sortableDateTime;

- (NSString *)sortableDateTimeWithOptionalTimeZoneAbbreviation:(NSString *)timeZoneWithAbbreviation;

- (NSString *)formatForPhotos;

@end
