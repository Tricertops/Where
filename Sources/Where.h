//
//  Where.h
//  Where
//
//  Created by Martin Kiss on 21.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import UIKit;
@import CoreTelephony;
@import CoreLocation;
#import <Where/NSTimeZone+Region.h>


FOUNDATION_EXPORT const double WhereVersionNumber;
FOUNDATION_EXPORT const unsigned char WhereVersionString[];


typedef enum : NSUInteger {
    WhereSourceNone = 0,
    WhereSourceLocale,      // Instant, not reliable, always.
    WhereSourceCarrier,     // Instant, reliable, cellular.
    WhereSourceTimeZone,    // Instant, reliable, always.
    //TODO: WhereSourceIPAddress,   // Delayed, reliable, connection.
    //TODO: WhereSourceLocationServices, // Delayed, precise, permission.
} WhereSource;


@interface Where : NSObject

@property (readonly) WhereSource source;
@property (readonly) NSString *countryCode;
@property (readonly) NSString *countryName;
//TODO: @property (readonly) CLLocationCoordinate2D coordinate;
@property (readonly) NSDate *timestamp;

@end


@interface Where (Detection)

// Instant
+ (void)detectInstantly;

// Asynchronous
//TODO: + (void)startDetection;
//TODO: + (BOOL)isDetecting;
//TODO: + (void)stopDetection;

// Updating
+ (BOOL)isUpdating;
+ (void)setUpdating:(BOOL)isUpdating;

// Instances
+ (Where *)best;
+ (NSArray *)all;
+ (Where *)forSource:(WhereSource)source;

@end


extern NSString * const WhereDidUpdateNotification;

