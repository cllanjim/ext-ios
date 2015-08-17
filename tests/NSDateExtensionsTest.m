#import "TestBase.h"

@interface NSDateExtensionsTest : TestBase

@end

@implementation NSDateExtensionsTest

- (void)test_javaCompatibleUTCDate
{
    NSString* javaDate = self.testDate.javaCompatibleUTCDate;
    XCTAssert([javaDate isEqualToString: @"Feb 01, 1970 06:07:08 AM"]);
}

- (void)test_sortableDateTimeWithOptionalTimeZoneAbbreviation
{
    NSString* javaDate = [self.testDate sortableDateTimeWithOptionalTimeZoneAbbreviation:@"CEST"];
    XCTAssert([javaDate isEqualToString: @"1970-02-01 07.07.08"]);
}

@end
