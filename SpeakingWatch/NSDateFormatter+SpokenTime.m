#import "NSDateFormatter+SpokenTime.h"

@implementation NSDateFormatter (SpokenTime)

- (NSString *)spokenStringFromDate:(NSDate*)date
{
    NSString *ret = @"IT IS ";
    BOOL isOclock = ![[self spokenOclock:date] isEqualToString:@""];
    
    if (NO == isOclock) {
        ret = [ret stringByAppendingString:
         [NSString stringWithFormat:@"%@ %@ ", [self spokenMinute:date], [self spokenDialHalf:date]]];
    }
    ret = [ret stringByAppendingString:[self spokenHour:date]];
    if (isOclock) {
        ret = [ret stringByAppendingString:@" OCLOCK"];
    }
    return ret;
}

#pragma mark - Helpers

- (NSString*)spokenHour:(NSDate*)date
{
    NSArray *hourStrings = @[@"TWELVE", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE",
                             @"SIX", @"SEVEN", @"EIGHT", @"NINE", @"TEN", @"ELEVEN"];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    NSInteger hour = [components hour];
    
    if ([components minute] >= 35) {
        hour += 1;
    }
    hour %= 12;
    return hourStrings[hour];
}

- (NSInteger)roundedMinute:(NSInteger)minute
{
    NSInteger roundedMinute = minute / 5;
    
    if (minute > 30) {
        roundedMinute = 12 - roundedMinute;
    }
    return roundedMinute;
}

- (NSString *)spokenMinute:(NSDate*)date
{
    NSArray *minuteStrings = @[@"", @"FIVE", @"TEN", @"QUARTER", @"TWENTY", @"TWENTYFIVE", @"HALF"];
    NSInteger exactMinute = [self.calendar component:NSCalendarUnitMinute fromDate:date];

    return minuteStrings[[self roundedMinute:exactMinute]];
}

- (NSString *)spokenDialHalf:(NSDate*)date
{
    if ([self.calendar component:NSCalendarUnitMinute fromDate:date] < 35) {
        return @"PAST";
    }
    else {
        return @"TO";
    }
}

- (NSString*)spokenOclock:(NSDate*)date
{
    if ([self roundedMinute:[self.calendar component:NSCalendarUnitMinute fromDate:date]] == 0) {
        return @"OCLOCK";
    }
    else {
        return @"";
    }
}

@end
