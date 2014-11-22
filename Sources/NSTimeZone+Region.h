//
//  NSTimeZone+Region.h
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import Foundation;


@interface NSTimeZone (Country)

- (NSString *)regionCode;
//TODO: + (NSArray *)timeZonesForRegion:(NSString *)countryCode;

@end

