//
//  Where.m
//  Where
//
//  Created by Martin Kiss on 21.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

#import "Where.h"


#pragma mark - Location

static NSString * WhereSourceDescription(WhereSource source) {
    switch (source) {
        case WhereSourceNone: return @"Unwnown";
        case WhereSourceLocale: return @"Locale";
        case WhereSourceCarrier: return @"Carrier";
        case WhereSourceTimeZone: return @"Time Zone";
        default: return @"Other";
    }
}

@interface Where ()

+ (instancetype)instanceWithSource:(WhereSource)source region:(NSString *)regionCode;

@end


@implementation Where

+ (instancetype)instanceWithSource:(WhereSource)source region:(NSString *)regionCode {
    NSString *canonizedRegionCode = [NSLocale canonizeRegionCode:regionCode];
    if ( ! canonizedRegionCode.length) return nil;
    
    Where *instance = [super new];
    if (instance) {
        instance->_source = source;
        instance->_regionCode = canonizedRegionCode;
        instance->_regionName = [NSLocale nameOfRegion:canonizedRegionCode];
        instance->_timestamp = [NSDate new];
    }
    return instance;
}

- (NSComparisonResult)compareQuality:(Where *)other {
    return ([@(self.source) compare:@(other.source)]
            ?: [self.timestamp compare:other.timestamp]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@) from %@ at %@",
            self->_regionName, self->_regionCode, WhereSourceDescription(self->_source), self->_timestamp];
}

@end


#pragma mark -

@implementation Where (Detection)


#pragma mark Detection

+ (Where *)detect {
    [self detectWithOptions:WhereOptionDefault];
    Where *instance = [self best];
    if (instance) {
        NSLog(@"You must be in %@!", instance.regionName);
    }
    else {
        NSLog(@"Sorry, I don’t know where you are :(");
    }
    return [self best];
}

+ (void)detectWithOptions:(WhereOptions)options {
    NSLog(@"Where are you?");
    [self detectUsingLocale];
    [self detectUsingCarrier];
    [self detectUsingTimeZone];
    
    //TODO: Run network request.
    //TODO: Ask for Location Services permission.
    //TODO: Detect using Core Location.
    
    if (options & WhereOptionUpdateContinuously) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(detectUsingLocale)
                                                     name:NSCurrentLocaleDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(detectUsingTimeZone)
                                                     name:NSSystemTimeZoneDidChangeNotification
                                                   object:nil];
        [[self network] setSubscriberCellularProviderDidUpdateNotifier:^(CTCarrier *carrier) {
            [self detectUsingCarrier];
        }];
        //TODO: Detect network changes.
        //TODO: Keep CMLocationManager running.
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[self network] setSubscriberCellularProviderDidUpdateNotifier:nil];
        //TODO: Stop CMLocationManager.
    }
}

+ (CTTelephonyNetworkInfo *)network {
    static CTTelephonyNetworkInfo *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [CTTelephonyNetworkInfo new];
    });
    return network;
}


#pragma mark Sources

+ (void)detectUsingLocale {
    NSString *regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    Where *instance = [Where instanceWithSource:WhereSourceLocale region:regionCode];
    if (instance) {
        NSLog(@"Hmm, you prefer region of %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)detectUsingCarrier {
    NSString *regionCode = [self network].subscriberCellularProvider.isoCountryCode;
    Where *instance = [Where instanceWithSource:WhereSourceCarrier region:regionCode];
    if (instance) {
        NSLog(@"Hmm, your cellular carrier is from %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)detectUsingTimeZone {
    NSString *regionCode = [[NSTimeZone systemTimeZone] regionCode];
    Where *instance = [Where instanceWithSource:WhereSourceTimeZone region:regionCode];
    if (instance) {
        NSLog(@"Hmm, you are in a time zone of %@.", instance.regionName);
        [self update:instance];
    }
}


#pragma mark Storage

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
        dictionary = [NSMutableDictionary dictionaryWithCapacity:6];
    });
    return dictionary;
}

+ (Where *)best {
    return [[self all] lastObject];
}

+ (NSArray *)all {
    return [[[self bySource] allValues] sortedArrayUsingSelector:@selector(compareQuality:)];
}

+ (Where *)forSource:(WhereSource)source {
    return [[self bySource] objectForKey:@(source)];
}

@end


#pragma mark -

NSString * const WhereDidUpdateNotification = @"WhereDidUpdateNotification";

