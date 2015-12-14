#include "TestBase.h"

@interface NSStringExtensionsTest : TestBase

@end

@implementation NSStringExtensionsTest

- (void)test_directorySize
{
    NSString* tempDir = self.getNewTempDir;
    
    NSString* file1 = [tempDir pathAppend:@"fatty1.file"];
    [[NSMutableData.alloc initWithLength:10000] writeToFile:file1 atomically:YES];
    
    NSString* directory1 = [tempDir pathAppend:@"fattyDir1"];
    [directory1 directoryEnsureExists];
    
    XCTAssertEqual([directory1 directorySize_sync], 0);
    
    NSString* file2 = [directory1 pathAppend:@"fatty2.file"];
    [[NSMutableData.alloc initWithLength:20000] writeToFile:file2 atomically:YES];
    
    XCTAssertEqual([directory1 directorySize_sync], 20000);
    
    NSString* directory2 = [directory1 pathAppend:@"fattyDir2"];
    [directory2 directoryEnsureExists];
    
    NSString* file3 = [directory2 pathAppend:@"fatty3.file"];
    NSString* file4 = [directory2 pathAppend:@"fatty4.file"];
    [[NSMutableData.alloc initWithLength:30000] writeToFile:file3 atomically:YES];
    [[NSMutableData.alloc initWithLength:50000] writeToFile:file4 atomically:YES];
    
    XCTAssertEqual([directory1 directorySize_sync], 100000);
    
    NSString* directory3 = [directory2 pathAppend:@"fattyDir3"];
    [directory3 directoryEnsureExists];
    
    NSString* file5 = [directory3 pathAppend:@"fatty5.file"];
    [[NSMutableData.alloc initWithLength:70000] writeToFile:file5 atomically:YES];
    
    XCTAssertEqual([directory1 directorySize_sync], 170000);
}

- (void)test_Concat
{
    BOOL case1 =[@"str1str2" isEqualToString:Concat(@"str1", @"str2")];
    XCTAssert(case1);
    
    BOOL case2 =[@"str1 str2" isEqualToString:Concat(@"str1", @" ", @"str2")];
    XCTAssert(case2);
}

- (void)test_PathCombine
{
    BOOL case1 =[@"/dir1" isEqualToString:PathCombine(@"/dir1", @"/")];
    XCTAssert(case1);
    
    BOOL case2 =[@"/dir1" isEqualToString:PathCombine(@"/dir1/", @"/")];
    XCTAssert(case2);
    
    BOOL case3 =[@"/dir1/dir2" isEqualToString:PathCombine(@"/dir1/", @"/dir2", @"")];
    XCTAssert(case3);
    
    BOOL case4 =[@"/dir1/dir2/dir3" isEqualToString:PathCombine(@"/dir1/", @"dir2", @"dir3")];
    XCTAssert(case4);
    
    BOOL case5 =[@"/dir1/dir2/file.txt" isEqualToString:PathCombine(@"/dir1/", @"/dir2", @"file.txt")];
    XCTAssert(case5);
}

- (void)test_StrFormat
{
    BOOL case1 = [StrFormat(@"str %d %.03f %@", 1, 2.222222, @"3") isEqualToString:@"str 1 2.222 3"];
    XCTAssert(case1);
}

- (void)test_IsStrEmptyOrWhitespace
{
    XCTAssert(IsStrNilOrWhitespace(@""));
    XCTAssert(IsStrNilOrWhitespace(@" "));
    XCTAssert(IsStrNilOrWhitespace(nil));
    XCTAssertFalse(IsStrNilOrWhitespace(@"     a "));
}

@end
