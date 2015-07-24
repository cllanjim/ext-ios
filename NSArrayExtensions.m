#import "Extensions.h"

@implementation NSArray (NSArrayExtensions)

- (NSMutableArray *)shuffled
{
    NSMutableArray* shuffled = self.mutableCopy;
    NSUInteger count = self.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        [shuffled exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    return shuffled;
}

- (NSMutableArray *)reversed
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    NSEnumerator *enumerator = self.reverseObjectEnumerator;
    for (id element in enumerator)
    {
        [array addObject:element];
    }
    return array;
}

@end
