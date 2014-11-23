//
//  NSLocale+Region.h
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import Foundation;
@import CoreLocation.CLLocation;


@interface NSLocale (Region)


#pragma mark Standard

//! Returns locale “en_US_POSIX” identifier.
+ (instancetype)standardLocale;


#pragma mark Regions

//! The region/country code.
@property (readonly) NSString *regionCode;

//! Takes 3-letter or 2-letter ISO 3166-1 code, returns 2-letter ISO 3166-1 code.
+ (NSString *)canonizeRegionCode:(NSString *)regionCode;

//! Returns localized name of the region using standardized English locale.
+ (NSString *)nameOfRegion:(NSString *)regionCode;


#pragma mark Coordinates

//! Returns middle coordinates for region which this locale represents.
- (CLLocationCoordinate2D)regionCoordinates;

//! Returns middle coordinates for given region.
+ (CLLocationCoordinate2D)coordinateForRegion:(NSString *)regionCode;


@end

