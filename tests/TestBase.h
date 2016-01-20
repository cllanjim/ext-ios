#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "Extensions.h"
#import <OCMock/OCMock.h>

@interface TestBase : XCTestCase
{
    NSString* _testFilesDir;
}

- (void)setUpTestBundle:(NSString*)aPathInsideBundle;

- (void)setUpTestBundle:(NSString *)aPathInsideBundle withOptionalBundle:(NSString *)bundleName;

- (void)setupTempDir;

- (id)addMock:(id)mock;

- (NSString*)getTempFilePath:(NSString*)filePath;

- (NSString*)getNewTempDir;

- (NSUInteger)getDifferencesBetween:(NSData*)actualData and:(NSData*)expectedData;

- (void)asyncTest1_begin;

- (void)asyncTest2_endOfAsyncCallback;

- (void)asyncTest3_end;

- (NSDate *)testDate;

@end