#import "YuvFrame.h"

@implementation YuvFrame
{
    BOOL _internalAllocation;
    
    uint8_t* _planes[3];
    NSUInteger _planeSizes[3];
}

#pragma mark - Overrides

- (void)dealloc
{
    if (_internalAllocation)
        for (int planeIndex = 0; planeIndex < 3; planeIndex++)
            free(_planes[planeIndex]);
}


#pragma mark - Public

- (instancetype)initWithYPlaneSize:(NSUInteger)yPlaneSize uPlaneSize:(NSUInteger)uPlaneSize vPlaneSize:(NSUInteger)vPlaneSize
{
    if (self = [super init])
    {
        _planeSizes[0] = yPlaneSize;
        _planeSizes[1] = uPlaneSize;
        _planeSizes[2] = vPlaneSize;
        
        _internalAllocation = YES;
        for (int planeIndex = 0; planeIndex < 3; planeIndex++)
            _planes[planeIndex] = malloc(_planeSizes[planeIndex]);
    }
    return self;
}

- (instancetype)initWithYPlane:(uint8_t *)yPlane yPlaneSize:(NSUInteger)yPlaneSize uPlane:(uint8_t *)uPlane uPlaneSize:(NSUInteger)uPlaneSize vPlane:(uint8_t *)vPlane vPlaneSize:(NSUInteger)vPlaneSize
{
    if (self = [super init])
    {
        _planeSizes[0] = yPlaneSize;
        _planeSizes[1] = uPlaneSize;
        _planeSizes[2] = vPlaneSize;
        
        _planes[0] = yPlane;
        _planes[1] = uPlane;
        _planes[2] = vPlane;
    }
    return self;
}

- (uint8_t *)yPlane
{
    return _planes[0];
}

- (uint8_t *)uPlane
{
    return _planes[1];
}

- (uint8_t *)vPlane
{
    return _planes[2];
}

- (NSUInteger)yPlaneSize
{
    return _planeSizes[0];
}

- (NSUInteger)uPlaneSize
{
    return _planeSizes[1];
}

- (NSUInteger)vPlaneSize
{
    return _planeSizes[2];
}

- (uint8_t *)planeWithIndex:(NSUInteger)planeIndex
{
    return _planes[planeIndex];
}

- (NSUInteger)planeSizeWithIndex:(NSUInteger)planeIndex
{
    return _planeSizes[planeIndex];
}

@end
