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
    NSString *canonized = [self.class canonizedCountryCode:code];
    if ( ! canonized.length) return nil;
    
    self = [super init];
    if (self) {
        self->_source = source;
        self->_countryCode = canonized;
        NSLocale *posix = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        self->_countryName = [posix displayNameForKey:NSLocaleCountryCode value:code];
        self->_timestamp = [NSDate new];
    }
    return self;
}

+ (NSString *)canonizedCountryCode:(NSString *)code {
    if ( ! code) return nil;
    NSString *identifier = [NSLocale localeIdentifierFromComponents:@{ NSLocaleCountryCode: code }];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:identifier];
    return [locale objectForKey:NSLocaleCountryCode];
}

@end


@implementation Where (Detection)

+ (void)detectInstantly {
    NSLog(@"Where are you?");
    [self detectUsingLocale];
    [self detectUsingCarrier];
    Where *instance = [self best];
    if (instance) {
        NSLog(@"You are in %@, aren’t you?", instance.countryName);
    }
    else {
        NSLog(@"Fuck you, I don’t know.");
    }
}

+ (void)detectUsingLocale {
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    Where *instance = [[Where alloc] initWithSource:WhereSourceLocale countryCode:country];
    if (instance) {
        NSLog(@"Hmm, you prefer region of %@.", instance.countryName);
        [self update:instance];
    }
}

+ (void)detectUsingCarrier {
    CTTelephonyNetworkInfo *network = [CTTelephonyNetworkInfo new];
    NSString *country = network.subscriberCellularProvider.isoCountryCode;
    Where *instance = [[Where alloc] initWithSource:WhereSourceCarrier countryCode:country];
    if (instance) {
        NSLog(@"Hmm, your cellular carrier is from %@.", instance.countryName);
        [self update:instance];
    }
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
    return [self forSource:WhereSourceCarrier] ?: [self forSource:WhereSourceLocale];
}

+ (NSArray *)all {
    return [[self bySource] allValues];
}

+ (Where *)forSource:(WhereSource)source {
    return [[self bySource] objectForKey:@(source)];
}

@end


NSString * const WhereDidUpdateNotification = @"WhereDidUpdateNotification";

