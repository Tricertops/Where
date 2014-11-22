//
//  NSLocale+Region.h
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import Foundation;


@interface NSLocale (Region)

//! Takes 3-letter or 2-letter ISO 3166-1 code, returns 2-letter ISO 3166-1 code.
+ (NSString *)canonizeRegionCode:(NSString *)regionCode;

//! Returns localized name of the region using current locale.
+ (NSString *)nameOfRegion:(NSString *)regionCode;

@end

