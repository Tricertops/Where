//
//  Where.h
//  Where
//
//  Created by Martin Kiss on 21.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import UIKit;
@import CoreTelephony;
@import SystemConfiguration;
@import Darwin.POSIX.netinet;
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

/*! These are all possible sources of location data used by this framework. Alcual values are important, because they
 *  represent relative quality. The higher, the better. */
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
    
    /*! External IP address was used.
     *  The associated location is the region/country of Internet Service Provider, which may be the home cellular
     *  carrier or, when connected to the Wi-Fi, the local ISP.
     *  When the user uses roaming while travelling, the ISP _doesn’t_ change and reports IP address of home country.
     *  This source is asynchronous and therefore disabled by default. */
    WhereSourceIPAddress = 3,
    
    /*! NSTimeZone was used.
     *  The associated location is the region/country of the actual position of the user. This is the most reliable
     *  source of data available offline.
     *  By default, the system time zone is set using user’s current location. As the user travels, the device updates
     *  the system time zone automatically. This way, we can use Location Services indirectly.
     *  The system time zone may be changed by the user manually, in which case it may be incorrect. */
    WhereSourceTimeZone = 4,
    
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
//! Compares source and the timestamp to find out which is better.
- (NSComparisonResult)compareQuality:(Where *)other;

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
    WhereOptionNone = kNilOptions,
    
    /*! The option used by +detect method. Only uses Locale, Carrier and TimeZone sources. */
    WhereOptionDefault = WhereOptionNone,
    
    /*! Cause the framework to observe changes in the sources and update the detected region.
     *  Posts WhereDidUpdateNotification when such change occur. */
    WhereOptionUpdateContinuously = 1,
    
    /*! Enables use of IPAddress source, which needs to send an URL request to a webservice. Webservice can find a
     *  region/country associated with the client’s IP address. When the request finishes, a WhereDidUpdateNotification
     *  is posted. */
    WhereOptionUseInternet = 2,
    
    //TODO: WhereOptionUseLocationServices = 4 | WhereOptionUseInternet,
    //TODO: WhereOptionAskForPermission    = 8 | WhereOptionUseLocationServices,
    
} WhereOptions;


/*! Class methods that manage and create */
@interface Where (Detection)

//! Uses default options and returns the detected location.
+ (Where *)detect;
//! Starts detection with given options. Method +best returns the detected location.
+ (void)detectWithOptions:(WhereOptions)options;

//! The best detected location, so far. “Best” is found using -compareQuality:
+ (Where *)best;
//! The latest location from every enabled source, sorted by quality.
+ (NSArray *)all;
//! Returns the last location from given source, if any.
+ (Where *)forSource:(WhereSource)source;

@end


/*! A notification posted when any source produced new location. This may happen when one of these options were
 *  specified: UpdateContinuously or UseInternet.
 *  Sender of the notifiction is the newly produced instance. */
extern NSString * const WhereDidUpdateNotification;

