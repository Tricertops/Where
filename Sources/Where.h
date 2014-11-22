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
#import <Where/NSLocale+Region.h>
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
@property (readonly) NSString *regionCode;
@property (readonly) NSString *regionName;
//TODO: @property (readonly) CLLocationCoordinate2D coordinate;
@property (readonly) NSDate *timestamp;

@end


typedef enum : NSUInteger {
    WhereOptionNone                = 0,
    WhereOptionUpdateContinuously  = 1,
    //TODO: WhereOptionUseInternet         = 2,
    //TODO: WhereOptionUseLocationServices = 4 | WhereOptionUseInternet,
    //TODO: WhereOptionAskForPermission    = 8 | WhereOptionUseLocationServices,
    WhereOptionDefault = WhereOptionNone,
} WhereOptions;


@interface Where (Detection)

+ (Where *)detect;
+ (void)detectWithOptions:(WhereOptions)options;

+ (Where *)best;
+ (NSArray *)all;
+ (Where *)forSource:(WhereSource)source;

@end


extern NSString * const WhereDidUpdateNotification;

