//
//  NabuManager.h
//  NabuTest
//
//  Created by Cătălin Crăciun on 16/03/15.
//  Copyright (c) 2015 Cătălin Crăciun. All rights reserved.
//
//  Version 1.1.0


/*
        How to implement in your app

	1. Register your app in the Dev Hub from http://developer.razerzone.com/nabu/ It will have to be approved to get an App Id

    2. Follow the steps listed here: http://developer.razerzone.com/nabu/guides/develop-ios/ to set up your Xcode project

	3. Create an URL scheme callback in the "URL Types" section from your Info.plist (this is the way your app communicates with the Nabu Utility)

    4. Import NabuManager.h in either AppDelegate.h or AppDelegate.m and after that, just copy and paste the following code in the AppDelegate.m file (this way you override the following method to handle the way you app opens URLs)

        - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
            [[NabuDataManager sharedDataManager] validateURLResponse:url withBlock:^(NSDictionary *callback) {}];

            return true;
        }

    5. Import the NabuManager.h in your ViewController class

	6. You now have all the Nabu's features at your fingertips with just one class. NabuManager is a singleton, only one instance lives at a time, so you can access it's public properties and methods this way:

		[[NabuManager sharedNabuManager] method1];
		[[NabuManager sharedNabuManager] method2: 3]; // For a method that takes one argument

		[NabuManager sharedNabuManager].property1;

    7. For every method's description please check it's documentation by pressing the "alt" key and clicking on that method, or just check the header.

        WARNING: SOME METHODS COULD TAKE MORE TIME TO BE EXECUTED DUE TO THE INTERACTION WITH THE NABU UTILITY, THAT'S WHY IT IS RECOMMENDED TO CALL THE METHODS ASYNCHRONOUSLY, LIKE THIS:

        dispatch_queue_t backgroundOperationQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(operationQueue, ^{
            [[NabuManager sharedNabuManager] sendNotificationWithMessage:@"Some notification text" andIconResId:@"The id of your icon resource"];
        });
*/

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <NabuOpenSDK/NabuOpenSDK.h>

/*!
 * @category NSDate (LocalTime)
 * @abstract LocalTime adds two very important methods to NSDate
 * @discussion One method is for getting the local date, as an NSDate, and the other one is for creating an NSDate more easily
 *
 * @author Catalin Craciun
 */
@interface NSDate (LocalTime)

/*!
 * @brief This method creates a NSDate with the local time
 */
+ (NSDate *)localDate;

/*!
 * @brief This method creates a NSDate from a calendaristic date
 *
 * @param year The year
 * @param month The month
 * @param day The day
 * @param hour The hour
 * @param minute The minute
 *
 * @warning The 8AM hour should be written as 08 and this applies to all the other parameters
 * @return The created NSDate
 */
+ (NSDate *)dateWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute;

@end


/*!
 * @class NabuManager
 * @abstract A very easy way to have access to all the features of the NabuOpenSDK
 * @discussion The NabuManager is a singleton whose shared instance makes the access to the NabuOpenSDK very easy and elegant
 *
 * @author Catalin Craciun
 */
@interface NabuManager : NSObject <NabuBandDelegate>

#pragma mark - Singleton
/*!
 * @brief Getting the shared instance of the NabuManager (singleton)
 */
+ (NabuManager *)sharedNabuManager;


#pragma mark - Nabu methods
#pragma mark Utilities
/*!
 * @brief Method for getting the current second in your timezone
 */
- (NSUInteger)getCurrentSecond;
/*!
 * @brief Method for getting the current minute in your timezone
 */
- (NSUInteger)getCurrentMinute;
/*!
 * @brief Method for getting the current hour in your timezone
 */
- (NSUInteger)getCurrentHour;

#pragma mark Authentication
/*!
 * @brief Method for authenticating with the Razer Nabu
 * @discussion Works with both the Nabu and the Nabu X
 * @warning Should be sent just once, at the first run of the app
 *
 * @param appId The app id which has been registered on developer.razerzone.com/nabu
 * @param uriScheme The app's URL type for communicating with other apps
 *
 * @return True if successfully authenticated
 */
- (BOOL)authenticateWithAppId:(NSString *)appId andURISchemeCallback:(NSString *)uriScheme;

/*!
 * @brief Method for checking if the app is authenticated
 * @return True if successfully authenticated
 */
- (BOOL)checkIfAuthenticated;


#pragma mark Notifications
/*!
 * @brief Method for sending notifications to the Nabu
 *
 * @param message The message of the notification
 * @param iconResId The Id of the icon resource
 */
- (void)sendNotificationWithMessage:(NSString *)message andIconResId:(NSString *)iconResId;


#pragma mark Fitness
/*!
 * @brief Retrieving an instance of NabuFitness class between two dates
 *
 * @param startDate The date since you want to get the NabuFitness
 * @param endDate The date until you want to get the NabuFitness
 *
 * @return The NabuFitness instance which stands for the interval specified
 */
- (NabuFitness *)getFitnessBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Retrieving the number of calories burned between two dates
 *
 * @param startDate The date since you want to get the calories burned
 * @param endDate The date until you want to get the calories burned
 *
 * @return The number of calories burned on the interval specified
 */
- (int)getCaloriesBurnedBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Retrieving the number of steps taken between two dates
 *
 * @param startDate The date since you want to get the number of steps taken
 * @param endDate The date until you want to get the number of steps taken
 *
 * @return The number of steps taken on the interval specified
 */
- (int)getStepsTakenBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Retrieving the floors climbed between two dates
 *
 * @param startDate The date since you want to get the floors climbed
 * @param endDate The date until you want to get the floors climbed
 *
 * @return The floors climbed on the interval specified
 */
- (int)getFloorsClimbedBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Retrieving the distance walked between two dates
 *
 * @param startDate The date since you want to get the distance walked
 * @param endDate The date until you want to get the distance walked
 *
 * @return The distance walked on the interval specified
 */
- (int)getDistanceWalkedBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Retrieving an instance of NabuFitness class for an interval of days
 *
 * @param startDay The day since you want to get the NabuFitness
 * @param endDay The day until you want to get the NabuFitness
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The NabuFitness instance which stands for the interval specified
 */
- (NabuFitness *)getFitnessBetweenStartDay:(int)startDay andEndDay:(int)endDay;

/*!
 * @brief Retrieving an instance of NabuFitness class for a single day
 *
 * @param day The day for which you want to get the NabuFitness
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The NabuFitness instance for that day
 */
- (NabuFitness *)getFitnessOnDay:(int)day;

/*!
 * @brief Retrieving the number of calories burned on an interval of days
 *
 * @param startDay The day since you want to get the calories burned
 * @param endDay The day until you want to get the calories burned
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The number of calories burned on the interval specified
 */
- (int)getCaloriesBurnedBetweenStartDay:(int)startDay andEndDay:(int)endDay;

/*!
 * @brief Retrieving the number of calories burned on a single day
 *
 * @param day The day for which you want to get the calories burned
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The number of calories burned on that day
 */
- (int)getCaloriesBurnedOnDay:(int)day;

/*!
 * @brief Retrieving the number of steps taken on an interval of days
 *
 * @param startDay The day since you want to get the number of steps taken
 * @param endDay The day until you want to get the number of steps taken
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The number of steps taken on the interval specified
 */
- (int)getStepsTakenBetweenStartDay:(int)startDay andEndDay:(int)endDay;

/*!
 * @brief Retrieving the number of steps taken on a single day
 *
 * @param day The day for which you want to get the number of steps taken
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The number of steps taken on that day
 */
- (int)getStepsTakenOnDay:(int)day;

/*!
 * @brief Retrieving the floors climbed on an interval of days
 *
 * @param startDay The day since you want to get the floors climbed
 * @param endDay The day until you want to get the floors climbed
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The floors climbed on the interval specified
 */
- (int)getFloorsClimbedBetweenStartDay:(int)startDay andEndDay:(int)endDay;

/*!
 * @brief Retrieving the floors climbed on a single day
 *
 * @param day The day for which you want to get the floors climbed
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The floors climbed on that day
 */
- (int)getFloorsClimbedOnDay:(int)day;

/*!
 * @brief Retrieving the distance walked on an interval of days
 *
 * @param startDay The day since you want to get the distance walked
 * @param endDay The day until you want to get the distance walked
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The distance walked on the interval specified
 */
- (int)getDistanceWalkedBetweenStartDay:(int)startDay andEndDay:(int)endDay;

/*!
 * @brief Retrieving the distance walked on a single day
 *
 * @param day The day for which you want to get the distance walked
 *
 * @warning The days are written just as A.D. years: 0 stands for today, 1 stands for yesterday and so on
 * @return The distance walked on that day
 */
- (int)getDistanceWalkedOnDay:(int)day;


#pragma mark Sleep
/*!
 * @brief Method for getting the NabuSleepTracker between two NSDates
 *
 * @param startDate The date since you want to get the NabuSleepTracker
 * @param endDate The date until you want to get the NabuSleepTracker
 *
 * @return The NabuSleepTracker corresponding to startDate and endDate
 */
- (NabuSleepTracker *)getSleepTrackerBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Method for getting the number of minutes of light sleep between two NSDates
 *
 * @param startDate The date since you want to get the number of minutes of light sleep
 * @param endDate The date until you want to get the number of minutes of light sleep
 *
 * @return The number of minutes of light sleep corresponding to startDate and endDate
 */
- (int)getMinutesOfLightSleepBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Method for getting the number of minutes of deep sleep between two NSDates
 *
 * @param startDate The date since you want to get the number of minutes of deep sleep
 * @param endDate The date until you want to get the number of minutes of deep sleep
 *
 * @return The number of minutes of deep sleep corresponding to startDate and endDate
 */
- (int)getMinutesOfDeepSleepBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Method for getting the number of minutes of sleep between two NSDates
 *
 * @param startDate The date since you want to get the number of minutes of sleep
 * @param endDate The date until you want to get the number of minutes of sleep
 *
 * @return The number of minutes of sleep corresponding to startDate and endDate
 */
- (int)getMinutesOfSleepBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/*!
 * @brief Method for getting the sleep's efficiency (percentage) between two NSDates
 *
 * @param startDate The date since you want to get the sleep's efficiency
 * @param endDate The date until you want to get the sleep's efficiency
 *
 * @return The sleep's efficiency corresponding to startDate and endDate
 */
- (int)getSleepEfficiencyBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

#pragma mark User's profile
/*!
 * @brief Method for getting the whole user's profile
 */
- (NabuUserProfile *)getUserProfile;

/*!
 * @brief Method for getting user's nickname
 */
- (NSString *)getUserNickname;
/*!
 * @brief Method for getting user's avatar
 */
- (NSString *)getUserAvatar;
/*!
 * @brief Method for getting user's birth day
 */
- (NSString *)getUserBirthDay;
/*!
 * @brief Method for getting user's birth month
 */
- (NSString *)getUserBirthMonth;
/*!
 * @brief Method for getting user's birth year
 */
- (NSString *)getUserBirthYear;
/*!
 * @brief Method for getting user's gender
 */
- (NSString *)getUserGender;
/*!
 * @brief Method for getting user's height
 */
- (NSString *)getUserHeight;
/*!
 * @brief Method for getting user's waight
 */
- (NSString *)getUserWeight;
/*!
 * @brief Method for getting user's measurement unit (i.e. metric)
 */
- (NSString *)getUserUnit;


#pragma mark Band info
/*!
 * @brief Method for getting the list of Nabus associated with the Razer account
 * @return An array of objects of type NabuBand
 */
- (NSArray *)getListOfNabus;


@end
