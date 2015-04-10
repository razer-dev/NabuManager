//
//  NabuManager.m
//  NabuTest
//
//  Created by Cătălin Crăciun on 16/03/15.
//  Copyright (c) 2015 Cătălin Crăciun. All rights reserved.
//
//  Version 1.0.0

#import "NabuManager.h"


@implementation NSDate (LocalTime)

+ (NSDate *)localDate {
    NSDate *rawGTMDate = [NSDate date];
    
    NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [timezone secondsFromGMTForDate:rawGTMDate];
    
    return [NSDate dateWithTimeInterval:seconds sinceDate:rawGTMDate];
}

+ (NSDate *)dateWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute {
    
    NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@ at %@:%@", year, month, day, hour, minute];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [timezone secondsFromGMTForDate:date];
    
    return [NSDate dateWithTimeInterval:seconds sinceDate:date];
}

@end


@interface NabuManager ()

@end

@implementation NabuManager

static NabuManager *_nabuManager = Nil;

#pragma mark - Singleton
+ (NabuManager *)sharedNabuManager {
    
    static dispatch_once_t onceOperation;
    
    dispatch_once(&onceOperation, ^{
        _nabuManager = [[NabuManager alloc] init];
    });
    
    return _nabuManager;
}

#pragma mark - Nabu Methods
#pragma mark Utilities
- (NSUInteger)getCurrentSecond {
    
    return [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:[NSDate date]].second;
}

- (NSUInteger)getCurrentMinute {
    
    return [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:[NSDate date]].minute;
}

- (NSUInteger)getCurrentHour {
    
    return [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]].hour;
}

#pragma mark Authentication
- (BOOL)authenticateWithAppId:(NSString *)appId andURISchemeCallback:(NSString *)uriScheme {
    
    NSURL *authorizationURL = [[NabuDataManager sharedDataManager] authorizationURLForAppID:appId andScope:@"fitness" withAppURISchemeCallback:uriScheme];
    [[UIApplication sharedApplication] openURL:authorizationURL];
    
    __block bool authenticationSucceded = false;
    dispatch_semaphore_t finishedOperation = dispatch_semaphore_create(0);
    
    [[NabuDataManager sharedDataManager] checkAppAuthorizedWithBlock:^(NSDictionary *callback) {
        authenticationSucceded = [callback objectForKey:@"Operation-Status"];
        dispatch_semaphore_signal(finishedOperation);
    }];
    
    dispatch_semaphore_wait(finishedOperation, DISPATCH_TIME_FOREVER);
    finishedOperation = Nil;
    
    return authenticationSucceded;
}

- (BOOL)checkIfAuthenticated {
    
    __block BOOL authenticated = false;
    dispatch_semaphore_t finishedOperation = dispatch_semaphore_create(0);
    
    [[NabuDataManager sharedDataManager] checkAppAuthorizedWithBlock:^(NSDictionary *callback) {
        NSString *authenticationResponse = [NSString stringWithFormat:@"%@",[callback objectForKey:@"Operation-Status"]];

        if ([authenticationResponse integerValue] == kOperationSuccess) {
            authenticated = true;
        } else if ([authenticationResponse integerValue] == kOperationPermissionDenied) {
            NSLog(@"* NabuManager error: The operation has not been permitted!");
        }
        
        dispatch_semaphore_signal(finishedOperation);
    }];
    
    dispatch_semaphore_wait(finishedOperation, DISPATCH_TIME_FOREVER);
    finishedOperation = Nil;
    
    return authenticated;
}

#pragma mark Notifications
- (void)sendNotificationWithMessage:(NSString *)message andIconResId:(NSString *)iconResId {
    
    NabuNotification *notification = [[NabuNotification alloc] init];
    notification.message = message;
    notification.iconResId = iconResId;
    
    [[NabuDataManager sharedDataManager] sendNotificationToBand:notification withBlock:^(NSDictionary *callback) {
        bool notificationSucceeded = [callback objectForKey:@"Operation-Status"];
        if (!notificationSucceeded) {
            NSLog(@"* NabuManager error: Something went wrong and the notifications has not been sent!");
        }
    }];
}

#pragma mark Fitness
- (NabuFitness *)getFitnessBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    __block NabuFitness *fitness = Nil;
    dispatch_semaphore_t finishedOperation = dispatch_semaphore_create(0);
    
    [[NabuDataManager sharedDataManager] getFitnessDataWithStartTime:[NSString stringWithFormat:@"%d", (int)[startDate timeIntervalSince1970]]
                                                             endTime:[NSString stringWithFormat:@"%d", (int)[endDate timeIntervalSince1970]]
                                                           withBlock:^(NSDictionary *callback) {
                                                               fitness = (NabuFitness*)[callback objectForKey:@"Fitness Data Records Retrieved"];
                                                               dispatch_semaphore_signal(finishedOperation);
                                                           }];
    
    dispatch_semaphore_wait(finishedOperation, DISPATCH_TIME_FOREVER);
    finishedOperation = Nil;
    
    return fitness;
}

- (int)getCaloriesBurnedBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDate:startDate andEndDate:endDate];
    
    int caloriesBurned = 0;
    
    for (int index = 0; index < fitness.fitnessData.count; index++)
        caloriesBurned += ((NabuFitnessData *)fitness.fitnessData[index]).calories;
    
    return caloriesBurned;
}

- (int)getStepsTakenBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDate:startDate andEndDate:endDate];
    
    int stepsTaken = 0;
    
    for (int index = 0; index < fitness.fitnessData.count; index++)
        stepsTaken += ((NabuFitnessData *)fitness.fitnessData[index]).steps;
    
    return stepsTaken;
}

- (int)getFloorsClimbedBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDate:startDate andEndDate:endDate];
    
    int floorsClimbed = 0;
    
    for (int index = 0; index < fitness.fitnessData.count; index++)
        floorsClimbed += ((NabuFitnessData *)fitness.fitnessData[index]).floorClimbed;
    
    return floorsClimbed;
}

- (int)getDistanceWalkedBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDate:startDate andEndDate:endDate];
    
    int distanceWalked = 0;
    
    for (int index = 0; index < fitness.fitnessData.count; index++)
        distanceWalked += ((NabuFitnessData *)fitness.fitnessData[index]).distanceWalked;
    
    return distanceWalked;
}

const int secondsPerDay = 86400;
- (NabuFitness *)getFitnessBetweenStartDay:(int)startDay andEndDay:(int)endDay {
    
    NSAssert(startDay >= endDay, @"The days entered might be in the incorrect order. Please see the documentation related to this method.");
    NSAssert(startDay >= 0 && endDay >= 0, @"The days sent as parameters should be positive. Please see the documentation related to this method.");
    
    __block NabuFitness *fitness = Nil;
    dispatch_semaphore_t finishedOperation = dispatch_semaphore_create(0);
    
    // Converting days in UNIX timestamps
    NSDate *startDate = [NSDate localDate];
    NSDate *endDate = [NSDate localDate];
    int secondsThisDay = -(int)([self getCurrentHour]*3600 + [self getCurrentMinute]*60 + [self getCurrentSecond]);
    if (endDay > 0) {
        endDate = [endDate dateByAddingTimeInterval:secondsThisDay];
        endDate = [endDate dateByAddingTimeInterval:-(endDay-1)*secondsPerDay];
    }
    startDate = [startDate dateByAddingTimeInterval:secondsThisDay];
    startDate = [startDate dateByAddingTimeInterval:-startDay*secondsPerDay];
    
    [[NabuDataManager sharedDataManager] getFitnessDataWithStartTime:[NSString stringWithFormat:@"%d", (int)[startDate timeIntervalSince1970]]
                                                             endTime:[NSString stringWithFormat:@"%d", (int)[endDate timeIntervalSince1970]]
                                                           withBlock:^(NSDictionary *callback) {
                                                               fitness = (NabuFitness*)[callback objectForKey:@"Fitness Data Records Retrieved"];
                                                               dispatch_semaphore_signal(finishedOperation);
                                                           }];

    dispatch_semaphore_wait(finishedOperation, DISPATCH_TIME_FOREVER);
    finishedOperation = Nil;

    return fitness;
}

- (NabuFitness *)getFitnessOnDay:(int)day {
    
    return [self getFitnessBetweenStartDay:day andEndDay:day];
}

- (int)getCaloriesBurnedBetweenStartDay:(int)startDay andEndDay:(int)endDay {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDay:startDay andEndDay:endDay];
    
    int caloriesBurned = 0;
    
    for (int index = 0; index < fitness.fitnessData.count; index++)
        caloriesBurned += ((NabuFitnessData *)fitness.fitnessData[index]).calories;
    
    return caloriesBurned;
}

- (int)getCaloriesBurnedOnDay:(int)day {
    
    return [self getCaloriesBurnedBetweenStartDay:day andEndDay:day];
}

- (int)getStepsTakenBetweenStartDay:(int)startDay andEndDay:(int)endDay {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDay:startDay andEndDay:endDay];
    
    int stepsTaken = 0;
    
    for (int index = 0; index < fitness.fitnessData.count; index++)
        stepsTaken += ((NabuFitnessData *)fitness.fitnessData[index]).steps;
    
    return stepsTaken;
}

- (int)getStepsTakenOnDay:(int)day {
    
    return [self getStepsTakenBetweenStartDay:day andEndDay:day];
}

- (int)getFloorsClimbedBetweenStartDay:(int)startDay andEndDay:(int)endDay {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDay:startDay andEndDay:endDay];
    
    int floorsClimbed = 0;
    
    for (int index = 0; index < fitness.fitnessData.count; index++)
        floorsClimbed += ((NabuFitnessData *)fitness.fitnessData[index]).floorClimbed;
        
    return floorsClimbed;
}

- (int)getFloorsClimbedOnDay:(int)day {
    
    return [self getFloorsClimbedBetweenStartDay:day andEndDay:day];
}

- (int)getDistanceWalkedBetweenStartDay:(int)startDay andEndDay:(int)endDay {
    
    NabuFitness *fitness = [self getFitnessBetweenStartDay:startDay andEndDay:endDay];
    
    int distanceWalked = 0;

    for (int index = 0; index < fitness.fitnessData.count; index++)
        distanceWalked += ((NabuFitnessData *)fitness.fitnessData[index]).distanceWalked;
    
    return distanceWalked;
}

- (int)getDistanceWalkedOnDay:(int)day {
    
    return [self getDistanceWalkedBetweenStartDay:day andEndDay:day];
}

#pragma mark Sleep
- (NabuSleepTracker *)getSleepTrackerBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    __block NabuSleepTracker *sleepTracker = Nil;
    dispatch_semaphore_t finishedOperation = dispatch_semaphore_create(0);
    
    [[NabuDataManager sharedDataManager] getSleepHistoryDataWithStartTime:[NSString stringWithFormat:@"%d", (int)[startDate timeIntervalSince1970]]
                                                                  endTime:[NSString stringWithFormat:@"%d", (int)[endDate timeIntervalSince1970]]
                                                                withBlock:^(NSDictionary *callback) {
                                                                    sleepTracker = ((NabuSleepTracker *)[callback objectForKey:@"Sleep History Data Records Retrieved"]);
                                                                    dispatch_semaphore_signal(finishedOperation);
                                                                }];
    
    dispatch_semaphore_wait(finishedOperation, DISPATCH_TIME_FOREVER);
    finishedOperation = Nil;

    return sleepTracker;
}

- (int)getMinutesOfLightSleepBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NabuSleepTracker *sleepTracker = [self getSleepTrackerBetweenStartDate:startDate andEndDate:endDate];
    
    int lightSleepMinutes = 0;
    for (int index = 0; index < sleepTracker.sleepHistoryDataArray.count; index++)
        lightSleepMinutes += ((NabuSleepHistoryData *)sleepTracker.sleepHistoryDataArray[index]).lightSleep;
    
    return lightSleepMinutes;
}

- (int)getMinutesOfDeepSleepBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NabuSleepTracker *sleepTracker = [self getSleepTrackerBetweenStartDate:startDate andEndDate:endDate];
    
    int deepSleepMinutes = 0;
    for (int index = 0; index < sleepTracker.sleepHistoryDataArray.count; index++)
        deepSleepMinutes += ((NabuSleepHistoryData *)sleepTracker.sleepHistoryDataArray[index]).deepSleep;
    
    return deepSleepMinutes;
}

- (int)getMinutesOfSleepBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    return [self getMinutesOfLightSleepBetweenStartDate:startDate andEndDate:endDate] +
            [self getMinutesOfDeepSleepBetweenStartDate:startDate andEndDate:endDate];
}

- (int)getSleepEfficiencyBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NabuSleepTracker *sleepTracker = [self getSleepTrackerBetweenStartDate:startDate andEndDate:endDate];
    
    int sleepEfficiency = -1;

    for (int index = 0; index < sleepTracker.sleepHistoryDataArray.count; index++)
        if (sleepEfficiency == -1)
            sleepEfficiency = ((NabuSleepHistoryData *)sleepTracker.sleepHistoryDataArray[index]).sleepEfficiency;
        else
            sleepEfficiency = (((NabuSleepHistoryData *)sleepTracker.sleepHistoryDataArray[index]).sleepEfficiency + sleepEfficiency)/2;
    
    return sleepEfficiency;
}

#pragma mark User's profile
- (NabuUserProfile *)getUserProfile {
    
    __block NabuUserProfile *profile = Nil;
    dispatch_semaphore_t finishedOperation = dispatch_semaphore_create(0);
    
    [[NabuDataManager sharedDataManager] getUserProfileWithBlock:^(NSDictionary *callback) {
        profile = (NabuUserProfile *)[callback objectForKey:@"Contents"];
        dispatch_semaphore_signal(finishedOperation);
    }];
    
    dispatch_semaphore_wait(finishedOperation, DISPATCH_TIME_FOREVER);
    finishedOperation = Nil;

    return profile;
}

- (NSString *)getUserNickname {
    return [self getUserProfile].nickName;
}

- (NSString *)getUserAvatar {
    return [self getUserProfile].avatar;
}

- (NSString *)getUserBirthDay {
    return [self getUserProfile].birthDay;
}

- (NSString *)getUserBirthMonth {
    return [self getUserProfile].birthMonth;
}

- (NSString *)getUserBirthYear {
    return [self getUserProfile].birthYear;
}

- (NSString *)getUserGender {
    return [self getUserProfile].gender;
}

- (NSString *)getUserHeight {
    return [self getUserProfile].height;
}

- (NSString *)getUserWeight {
    return [self getUserProfile].weight;
}

- (NSString *)getUserUnit {
    return [self getUserProfile].unit;
}

#pragma mark Band info
- (NSArray *)getListOfNabus {
    
    __block NSMutableArray *bands = [[NSMutableArray alloc] init];
    dispatch_semaphore_t finishedOperation = dispatch_semaphore_create(0);
    
    [[NabuDataManager sharedDataManager] getBandListWithBlock:^(NSDictionary *callback) {
        bands = (NSMutableArray *)[callback objectForKey:@"Bands"];
        dispatch_semaphore_signal(finishedOperation);
    }];
    
    dispatch_semaphore_wait(finishedOperation, DISPATCH_TIME_FOREVER);
    finishedOperation = Nil;
 
    return (NSArray *)bands;
}

@end
