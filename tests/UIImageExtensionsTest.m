#include "TestBase.h"

@interface UIImageExtensionsTest : TestBase
@end

@implementation UIImageExtensionsTest

- (void)setUp
{
    [super setUp];
    [self setUpTestBundle:@"tests-files/TestImages" withOptionalBundle:@"ExtTestsFiles.bundle"];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_isEqualToImage
{
    NSString* differences = PathCombine(_testFilesDir, @"differences");
    
    UIImage* image = PathCombine(differences, @"reference.png").loadImage;

    UIImage* sameImage = PathCombine(differences, @"reference.png").loadImage;
    XCTAssert([image isEqualToImage:sameImage]);
    
    UIImage* differentImage = PathCombine(differences, @"reference_diff_1pixel.png").loadImage;
    XCTAssertFalse([image isEqualToImage:differentImage]);
    
    UIImage* differentRes = PathCombine(differences, @"different_res.png").loadImage;
    XCTAssertFalse([image isEqualToImage:differentRes]);
}

- (void)test_differencesFromImage
{
    NSString* differences = PathCombine(_testFilesDir, @"differences");
    
    UIImage* image = PathCombine(differences, @"reference.png").loadImage;

    UIImage* sameImage = PathCombine(differences, @"reference.png").loadImage;
    XCTAssertEqual([image differencesFromImage:sameImage withRGBThreshold:0], 0);
    XCTAssertEqual([image differencesFromImage:sameImage withRGBThreshold:1], 0);
    XCTAssertEqual([image differencesFromImage:sameImage withRGBThreshold:100], 0);
    
    UIImage* differentRes = PathCombine(differences, @"different_res.png").loadImage;
    XCTAssertEqual([image differencesFromImage:differentRes withRGBThreshold:10000], 1);
    
    UIImage* tol_54_diff_10 = PathCombine(differences, @"tol_54_diff_10.png").loadImage;
    XCTAssertEqual([image differencesFromImage:tol_54_diff_10 withRGBThreshold:53], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_54_diff_10 withRGBThreshold:54], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_54_diff_10 withRGBThreshold:55], 0);
    
    UIImage* tol_254_diff_10 = PathCombine(differences, @"tol_254_diff_10.png").loadImage;
    XCTAssertEqual([image differencesFromImage:tol_254_diff_10 withRGBThreshold:253], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_254_diff_10 withRGBThreshold:254], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_254_diff_10 withRGBThreshold:255], 0);
    
    UIImage* tol_254_diff_20 = PathCombine(differences, @"tol_254_diff_20.png").loadImage;
    XCTAssertEqual([image differencesFromImage:tol_254_diff_20 withRGBThreshold:253], 0.2);
    XCTAssertEqual([image differencesFromImage:tol_254_diff_20 withRGBThreshold:254], 0.2);
    XCTAssertEqual([image differencesFromImage:tol_254_diff_20 withRGBThreshold:255], 0);
    
    UIImage* tol_254_diff_100 = PathCombine(differences, @"tol_254_diff_100.png").loadImage;
    XCTAssertEqual([image differencesFromImage:tol_254_diff_100 withRGBThreshold:253], 1);
    XCTAssertEqual([image differencesFromImage:tol_254_diff_100 withRGBThreshold:254], 1);
    XCTAssertEqual([image differencesFromImage:tol_254_diff_100 withRGBThreshold:255], 0);
    
    UIImage* tol_255_diff_10 = PathCombine(differences, @"tol_255_diff_10.png").loadImage;
    XCTAssertEqual([image differencesFromImage:tol_255_diff_10 withRGBThreshold:254], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_255_diff_10 withRGBThreshold:255], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_255_diff_10 withRGBThreshold:256], 0);
    
    UIImage* tol_256_diff_10 = PathCombine(differences, @"tol_256_diff_10.png").loadImage;
    XCTAssertEqual([image differencesFromImage:tol_256_diff_10 withRGBThreshold:255], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_256_diff_10 withRGBThreshold:256], 0.1);
    XCTAssertEqual([image differencesFromImage:tol_256_diff_10 withRGBThreshold:257], 0);
}

- (void)test_scaleToFillSize
{
    NSString* fill = PathCombine(_testFilesDir, @"scale/fill");
    UIImage* reference = PathCombine(fill, @"reference.png").loadImage;
    
    UIImage* scaled401x200 = PathCombine(fill, @"reference.png").loadImage;
    UIImage* actualScaled401x200 = [reference scaleToFillSize:CGSizeMake(401, 200)];
    XCTAssert([actualScaled401x200 isEqualToImage:scaled401x200]);
    
    UIImage* scaled100x100 = PathCombine(fill, @"100x100.png").loadImage;
    UIImage* actualScaled100x100 = [reference scaleToFillSize:CGSizeMake(100, 100)];
    XCTAssert([actualScaled100x100 isEqualToImage:scaled100x100]);
    
    UIImage* scaled200x20 = PathCombine(fill, @"200x20.png").loadImage;
    UIImage* actualScaled200x20 = [reference scaleToFillSize:CGSizeMake(200, 20)];
    XCTAssert([actualScaled200x20 isEqualToImage:scaled200x20]);
    
    UIImage* scaled20x200 = PathCombine(fill, @"20x200.png").loadImage;
    UIImage* actualScaled20x200 = [reference scaleToFillSize:CGSizeMake(20, 200)];
    XCTAssert([actualScaled20x200 isEqualToImage:scaled20x200]);
}

- (void)test_scaleToAspectFitSizeWithoutMargin
{
    NSString* aspectFitWithoutMargin = PathCombine(_testFilesDir, @"scale/aspectFitWithoutMargin");
    UIImage* reference = PathCombine(aspectFitWithoutMargin, @"reference.png").loadImage;
    
    UIImage* scaled401x200 = PathCombine(aspectFitWithoutMargin, @"reference.png").loadImage;
    UIImage* actualScaled401x200 = [reference scaleToAspectFitSizeWithoutMargin:CGSizeMake(401, 200)];
    XCTAssert([actualScaled401x200 isEqualToImage:scaled401x200]);
    
    UIImage* scaled100x100 = PathCombine(aspectFitWithoutMargin, @"100x100.png").loadImage;
    UIImage* actualScaled100x100 = [reference scaleToAspectFitSizeWithoutMargin:CGSizeMake(100, 100)];
    XCTAssert([actualScaled100x100 isEqualToImage:scaled100x100]);
    
    UIImage* scaled200x20 = PathCombine(aspectFitWithoutMargin, @"200x20.png").loadImage;
    UIImage* actualScaled200x20 = [reference scaleToAspectFitSizeWithoutMargin:CGSizeMake(200, 20)];
    XCTAssert([actualScaled200x20 isEqualToImage:scaled200x20]);
    
    UIImage* scaled20x200 = PathCombine(aspectFitWithoutMargin, @"20x200.png").loadImage;
    UIImage* actualScaled20x200 = [reference scaleToAspectFitSizeWithoutMargin:CGSizeMake(20, 200)];
    XCTAssert([actualScaled20x200 isEqualToImage:scaled20x200]);
}

- (void)test_scaleToAspectFillSize
{
    NSString* aspectFill = PathCombine(_testFilesDir, @"scale/aspectFill");
    UIImage* reference = PathCombine(aspectFill, @"reference.png").loadImage;
    
    UIImage* scaled401x200 = PathCombine(aspectFill, @"reference.png").loadImage;
    UIImage* actualScaled401x200 = [reference scaleToAspectFillSize:CGSizeMake(401, 200)];
    XCTAssert([actualScaled401x200 isEqualToImage:scaled401x200]);
    
    UIImage* scaled100x100 = PathCombine(aspectFill, @"100x100.png").loadImage;
    UIImage* actualScaled100x100 = [reference scaleToAspectFillSize:CGSizeMake(100, 100)];
    XCTAssert([actualScaled100x100 isEqualToImage:scaled100x100]);
    
    UIImage* scaled200x20 = PathCombine(aspectFill, @"200x20.png").loadImage;
    UIImage* actualScaled200x20 = [reference scaleToAspectFillSize:CGSizeMake(200, 20)];
    XCTAssert([actualScaled200x20 isEqualToImage:scaled200x20]);
    
    UIImage* scaled20x200 = PathCombine(aspectFill, @"20x200.png").loadImage;
    UIImage* actualScaled20x200 = [reference scaleToAspectFillSize:CGSizeMake(20, 200)];
    XCTAssert([actualScaled20x200 isEqualToImage:scaled20x200]);
}

@end