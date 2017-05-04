#import <Foundation/Foundation.h>

#import <HealthKit/HealthKit.h>

@interface FGHealthKit : NSObject

@property (nonatomic) int yesterdaysSteps;

- (void)fetchYesterdaysSteps;

@end
