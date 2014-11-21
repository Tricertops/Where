//
//  Where.m
//  Where
//
//  Created by Martin Kiss on 21.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

#import "Where.h"


@interface Where ()

- (instancetype)initWithSource:(WhereSource)source countryCode:(NSString *)code;

@end


@implementation Where

- (instancetype)initWithSource:(WhereSource)source countryCode:(NSString *)code {
    self = [super init];
    if (self) {
        self->_source = source;
        self->_countryCode = code;
        NSLocale *posix = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        self->_countryName = [posix displayNameForKey:NSLocaleCountryCode value:code];
        self->_timestamp = [NSDate new];
    }
    return self;
}

@end


@implementation Where (Detection)

+ (void)detectInstantly {
    NSLog(@"Where are you?");
    [self detectUsingLocale];
}

+ (void)detectUsingLocale {
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    Where *instance = [[Where alloc] initWithSource:WhereSourceLocale countryCode:country];
    NSLog(@"It seems like you are from %@.", instance.countryName);
    [self update:instance];
}

+ (void)update:(Where *)instance {
    NSParameterAssert(instance);
    if ( ! instance) return;
    if (instance.source == WhereSourceNone) return;
    
    [[self bySource] setObject:instance forKey:@(instance.source)];
    [[NSNotificationCenter defaultCenter] postNotificationName:WhereDidUpdateNotification object:instance];
}

+ (NSMutableDictionary *)bySource {
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    });
    return dictionary;
}

+ (Where *)best {
    return [self forSource:WhereSourceLocale];
}

+ (NSArray *)all {
    return [[self bySource] allValues];
}

+ (Where *)forSource:(WhereSource)source {
    return [[self bySource] objectForKey:@(source)];
}

@end


NSString * const WhereDidUpdateNotification = @"WhereDidUpdateNotification";

