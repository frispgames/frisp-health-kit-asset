#import "FGHealthKit.h"

@implementation FGHealthKit

- (id)init {
    self = [super init];
    return self;
}

+ (instancetype)sharedFGHealthKit {
    static FGHealthKit *sharedFGHealthKit;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFGHealthKit = [[FGHealthKit alloc] init];
    });
    return sharedFGHealthKit;
}

- (void) fetchYesterdaysSteps {
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable]) {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        NSSet *writeDataTypes = [NSSet new];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. Error: %@.", error);
                return;
            } else {
                NSLog(@"You do have access to HealthKit data.");
                [self setYesterdaysStepsUsing: healthStore];
            }
        }];
    } else {
        NSLog(@"No health store available");
    }
}

- (NSPredicate *)predicateForSamplesYesterday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDate *startDate = [calendar startOfDayForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:now options:0]];
    NSDate *endDate = [calendar startOfDayForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0]];
    
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

- (NSSet *) dataTypesToRead {
    return [NSSet setWithObjects:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount], nil];
}

- (void) setYesterdaysStepsUsing:(HKHealthStore *)store {
    NSPredicate *predicate = [self predicateForSamplesYesterday];
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];
        int steps = [sum doubleValueForUnit:HKUnit.countUnit];
        [self setYesterdaysSteps: steps];
        NSLog(@"%d", self.yesterdaysSteps);
    }];
    
    [store executeQuery:query];
}

static FGHealthKit *sharedGameKit = nil;

extern "C" {
    void _Initialize() {
        if (sharedGameKit == nil) {
            sharedGameKit = [FGHealthKit sharedFGHealthKit];
        }
        
        [sharedGameKit fetchYesterdaysSteps];
    }
    
    int _GetYesterdaysSteps() {
        NSLog(@"%d", [sharedGameKit yesterdaysSteps]);
        return [sharedGameKit yesterdaysSteps];
    };
}

@end
