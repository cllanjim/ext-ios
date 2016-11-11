@interface YuvFrame : NSObject

- (instancetype)initWithYPlaneSize:(NSUInteger)yPlaneSize uPlaneSize:(NSUInteger)uPlaneSize vPlaneSize:(NSUInteger)vPlaneSize;

- (instancetype)initWithYPlane:(uint8_t *)yPlane yPlaneSize:(NSUInteger)yPlaneSize uPlane:(uint8_t *)uPlane uPlaneSize:(NSUInteger)uPlaneSize vPlane:(uint8_t *)vPlane vPlaneSize:(NSUInteger)vPlaneSize;

- (uint8_t *)yPlane;

- (uint8_t *)uPlane;

- (uint8_t *)vPlane;

- (NSUInteger)yPlaneSize;

- (NSUInteger)uPlaneSize;

- (NSUInteger)vPlaneSize;

- (uint8_t *)planeWithIndex:(NSUInteger)planeIndex;

- (NSUInteger)planeSizeWithIndex:(NSUInteger)planeIndex;

@end
