//
//  NSLocale+Region.m
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

#import "NSLocale+Region.h"


@implementation NSLocale (Region)

+ (NSString *)canonizeRegionCode:(NSString *)regionCode {
    if ( ! regionCode) return nil;
    NSString *identifier = [NSLocale localeIdentifierFromComponents:@{ NSLocaleCountryCode: regionCode }];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:identifier];
    return [locale objectForKey:NSLocaleCountryCode];
}

+ (NSString *)nameOfRegion:(NSString *)regionCode {
    if ( ! regionCode) return nil;
    return [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:regionCode];
}

@end

