//
//  NSLocale+Region.h
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import Foundation;


@interface NSLocale (Region)

+ (NSString *)canonizeRegionCode:(NSString *)regionCode;
+ (NSString *)nameOfRegion:(NSString *)regionCode;

@end

