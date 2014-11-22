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


/*! This small framework provides a way to locate the user of the current device.
 *  Location is detected using multiple sources of regional data, but only the country (or region) is detected, not the
 *  exact position of the user.
 *
 *  This framework doesn’t use CoreLocation and doesn’t need Location Services permissions.
 */


FOUNDATION_EXPORT const double WhereVersionNumber;
FOUNDATION_EXPORT const unsigned char WhereVersionString[];


#pragma mark - Location

//! These are all possible sources of location data used by this framework.
typedef enum : NSUInteger {
    /*! The source is unknown. */
    WhereSourceNone = 0,
    
    /*! NSLocale was used.
     *  The associated location is the preferred region of the user and may be interpreted as a region/country of origin
     *  or residence. */
    WhereSourceLocale = 1,
    
    /*! CTCarrier was used.
     *  The associated location is the region/country of the issuer of inserted SIM card (if present) and may be
     *  interpreted as the region/country of residence.
     *  The value of this source _doesn’t_ change when the user uses roaming while travelling. */
    WhereSourceCarrier = 2,
    
    /*! NSTimeZone was used.
     *  The associated location is the region/country of the actual position of the user. This is the most reliable
     *  source of data available offline.
     *  By default, the system time zone is set using user’s current location. As the user travels, the device updates
     *  the system time zone automatically. This way, we can use Location Services indirectly.
     *  The system time zone may be changed by the user manually, in which case it may be incorrect. */
    WhereSourceTimeZone = 3,
    
    //TODO: WhereSourceIPAddress,
    //TODO: WhereSourceLocationServices,
} WhereSource;


/*! Instances of this class encapsulates a piece information about user’s location. They are produced by the framework
 *  by interpreting the data from various sources.
 *  Quality fo the instance is represented by its source and timestamp. The higher the source value, the beter the values are. */
@interface Where : NSObject

//! Source, that produced this data.
@property (readonly) WhereSource source;
//! Time, when the data was produced.
@property (readonly) NSDate *timestamp;
//TODO: - (NSComparisonResult)compareQuality:(Where *)other;

//! 2-letter ISO 3166-1 code of the associated region.
@property (readonly) NSString *regionCode;
//! Name of the region formatted using current locale.
@property (readonly) NSString *regionName;

//TODO: @property (readonly) CLLocationCoordinate2D coordinate;

//! Don’t create instances of this class.
+ (instancetype)alloc __unavailable;
//! Don’t create instances of this class.
- (instancetype)init __unavailable;
//! Don’t create instances of this class.
+ (instancetype)new __unavailable;

@end

#pragma mark - Detection

/*! Options that may be passed to +detectWithOptions: method. */
typedef enum : NSUInteger {
    /*! No special behavior. */
    WhereOptionNone                = 0,
    
    /*! The option used by +detect method. Only uses Locale, Carrier and Time Zone sources. */
    WhereOptionDefault = WhereOptionNone,
    
    /*! Cause the framework to observe changes in the sources and update the detected region.
     *  Posts WhereDidUpdateNotification when such change occur. */
    WhereOptionUpdateContinuously  = 1,
    
    //TODO: WhereOptionUseInternet         = 2,
    //TODO: WhereOptionUseLocationServices = 4 | WhereOptionUseInternet,
    //TODO: WhereOptionAskForPermission    = 8 | WhereOptionUseLocationServices,
    
} WhereOptions;


/*! Class methods that manage and create */
@interface Where (Detection)

//! Uses default options and returns the detected location.
+ (Where *)detect;
//! Starts detection with given options. Method +best returns the detected location.
+ (void)detectWithOptions:(WhereOptions)options;

//! The best detected location, so far.
+ (Where *)best;
//! The latest location from every enabled source.
+ (NSArray *)all;
//! Returns the last location from given source, if any.
+ (Where *)forSource:(WhereSource)source;

@end


/*! A notification posted when WhereOptionUpdateContinuously was specified and any source produced new location data.
 *  Sender of the notifiction is the newly produced instance. */
extern NSString * const WhereDidUpdateNotification;

