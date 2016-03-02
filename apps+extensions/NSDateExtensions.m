#import "Extensions.h"

@implementation NSDate (NSDateExtensions)

- (NSString *)javaCompatibleUTCDate
{
    NSDateFormatter* formatter = NSDateFormatter.new;
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setLocale:[NSLocale.alloc initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"MMM dd, yyyy hh:mm:ss a"];
    return [formatter stringFromDate:self];
}

- (NSString *)sortableDateTime
{
    return [self sortableDateTimeWithOptionalTimeZoneAbbreviation:nil];
}

- (NSString *)sortableDateTimeWithOptionalTimeZoneAbbreviation:(NSString *)timeZoneAbbreviation
{
    NSDateFormatter* formatter = NSDateFormatter.new;
    if (timeZoneAbbreviation)
    {
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithAbbreviation:timeZoneAbbreviation];
        [formatter setTimeZone:timeZone];
    }
    [formatter setLocale:[NSLocale.alloc initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH.mm.ss"];
    return [formatter stringFromDate:self];
}

- (NSString *)formatForPhotos
{
    NSDateFormatter* dateFormatter = NSDateFormatter.new;
    dateFormatter.timeStyle = kCFDateFormatterShortStyle;
    dateFormatter.dateStyle = kCFDateFormatterMediumStyle;
    dateFormatter.locale = NSLocale.autoupdatingCurrentLocale;
    dateFormatter.doesRelativeDateFormatting = YES;
    return [dateFormatter stringFromDate:self];
}

@end
