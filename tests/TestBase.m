#import "TestBase.h"

@implementation TestBase
{
    NSString* _tempDir;
    XCTestExpectation* _asyncExpectation;
    NSMutableArray<OCMockObject *>* _mocks;
}

- (void)setUp
{
    [super setUp];
    _mocks = NSMutableArray.new;
}

- (void)tearDown
{
    if (_tempDir)
    {
        [FileManager removeItemAtPath:_tempDir error:nil];
    }
    if (_asyncExpectation)
    {
        XCTFail(@"Error: asyncTest3_after not called!");
    }
    for (OCMockObject* mock in _mocks)
    {
        [mock verify];
    }
    [super tearDown];
}

- (void)setUpTestBundle:(NSString *)aPathInsideBundle
{
    [self setUpTestBundle:aPathInsideBundle withOptionalBundle:nil];
}

- (void)setUpTestBundle:(NSString *)aPathInsideBundle withOptionalBundle:(NSString *)bundleName
{
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* bundlePath = [bundle resourcePath];
    _testFilesDir = [bundlePath pathAppend:[(bundleName ? bundleName : @"TestFiles.bundle") pathAppend:aPathInsideBundle]];
}

- (void)setupTempDir
{
    if (_tempDir == nil)
    {
        _tempDir = [TempPath pathAppend:@"TestingDir"];
        [_tempDir fileOrDirDelete];
        XCTAssertTrue([FileManager createDirectoryAtPath:_tempDir withIntermediateDirectories:NO attributes:nil error:nil]);
    }
}

- (id)addMock:(id)mock
{
    [_mocks addObject:(OCMockObject *)mock];
    return mock;
}

- (NSString*)getTempFilePath:(NSString*)filePath
{
    [self setupTempDir];
    return [_tempDir pathAppend:filePath];
}

- (NSString*)getNewTempDir
{
    [self setupTempDir];
    NSString* newTempDir = [_tempDir pathAppend:GenerateGUID];
    [newTempDir directoryEnsureExists];
    return newTempDir;
}

- (NSUInteger)getDifferencesBetween:(NSData*)actualData and:(NSData*)expectedData
{
    uint8_t* actualBytes = (uint8_t*)[actualData bytes];
    uint8_t* expectedBytes = (uint8_t*)[expectedData bytes];
    
    NSUInteger commonLength = MIN([actualData length], [expectedData length]);
    NSUInteger differencesCount = 0;
    for (NSUInteger i = 0 ; i <  commonLength; ++i)
    {
        if (actualBytes[i] != expectedBytes[i])
        {
            differencesCount++;
        }
    }
    
    return differencesCount + ABS([actualData length] - [expectedData length]);
}

- (void)asyncTest1_begin
{
    _asyncExpectation = [self expectationWithDescription:@"async expectation"];
}

- (void)asyncTest2_endOfAsyncCallback
{
    [_asyncExpectation fulfill];
}

- (void)asyncTest3_end
{
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error){ }];
    _asyncExpectation = nil;
}

- (NSDate *)testDate // Returns: Feb 01, 1970 06:07:08 AM : 12345678 fractional seconds
{
    return [NSDate dateWithTimeIntervalSince1970:2700428.12345678];
}

@end
