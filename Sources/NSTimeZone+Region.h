//
//  NSTimeZone+Region.h
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import Foundation;
@import CoreLocation.CLLocation;


@interface NSTimeZone (Country)

//! Region code associated with the time zone.
- (NSString *)regionCode;

//! Coordinate for the city associated with the time zone.
- (CLLocationCoordinate2D)coordinate;

//! Returns all time zones associated with given region.
+ (NSArray *)timeZonesForRegion:(NSString *)code;

@end

