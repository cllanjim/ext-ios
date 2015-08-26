#import "TestBase.h"

@interface GetTest : TestBase
@end

@implementation GetTest
{
    NSString* _fattyDataFile;
}

- (void)setUp
{
    [super setUp];
    
    _fattyDataFile = [DocumentsPath pathAppend:@"StaticsGetTestFile"];
}

- (void)tearDown
{
    if (_fattyDataFile)
    {
        [_fattyDataFile fileOrDirDelete];
    }
    [super tearDown];
}

- (void)test_freeSpaceOnDisk
{
    for (int retry = 0; retry < 10; retry++)
    {
        int fattyDataSize = 5000000;
        NSData* fattyData = [NSMutableData.alloc initWithLength:fattyDataSize];
        [_fattyDataFile fileOrDirDelete];
        
        unsigned long long initialFreeSpace = Get.freeSpaceOnDisk;
        [fattyData writeToFile:_fattyDataFile atomically:NO];
        unsigned long long finalFreeSpace = Get.freeSpaceOnDisk;
        
        int difference = (int)(initialFreeSpace - finalFreeSpace);
        if (ABS(difference - fattyDataSize) < (fattyDataSize / 10))
        {
            XCTAssert(YES);
            return;
        }
    }
    XCTFail();
}


@end
