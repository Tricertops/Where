//
//  Where.m
//  Where
//
//  Created by Martin Kiss on 21.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

#import "Where.h"


@interface Where ()

- (instancetype)initWithSource:(WhereSource)source region:(NSString *)regionCode;

@end


@implementation Where

- (instancetype)initWithSource:(WhereSource)source region:(NSString *)regionCode {
    NSString *canonizedRegionCode = [NSLocale canonizeRegionCode:regionCode];
    if ( ! canonizedRegionCode.length) return nil;
    
    self = [super init];
    if (self) {
        self->_source = source;
        self->_regionCode = canonizedRegionCode;
        self->_regionName = [NSLocale nameOfRegion:canonizedRegionCode];
        self->_timestamp = [NSDate new];
    }
    return self;
}

@end


@implementation Where (Detection)

+ (Where *)detect {
    [self detectWithOptions:WhereOptionDefault];
    [self logBest];
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

+ (void)detectUsingLocale {
    NSString *regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    Where *instance = [[Where alloc] initWithSource:WhereSourceLocale region:regionCode];
    if (instance) {
        NSLog(@"Hmm, you prefer region of %@.", instance.regionName);
        [self update:instance];
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

+ (void)detectUsingCarrier {
    NSString *regionCode = [self network].subscriberCellularProvider.isoCountryCode;
    Where *instance = [[Where alloc] initWithSource:WhereSourceCarrier region:regionCode];
    if (instance) {
        NSLog(@"Hmm, your cellular carrier is from %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)detectUsingTimeZone {
    NSString *regionCode = [[NSTimeZone systemTimeZone] regionCode];
    Where *instance = [[Where alloc] initWithSource:WhereSourceTimeZone region:regionCode];
    if (instance) {
        NSLog(@"Hmm, you are in a time zone of %@.", instance.regionName);
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
    return ([self forSource:WhereSourceTimeZone]
            ?: [self forSource:WhereSourceCarrier]
            ?: [self forSource:WhereSourceLocale]);
}

+ (void)logBest {
    Where *instance = [self best];
    if (instance) {
        NSLog(@"You must be in %@!", instance.regionName);
    }
    else {
        NSLog(@"Sorry, I don’t know where you are :(");
    }
}

+ (NSArray *)all {
    return [[self bySource] allValues];
}

+ (Where *)forSource:(WhereSource)source {
    return [[self bySource] objectForKey:@(source)];
}

@end


NSString * const WhereDidUpdateNotification = @"WhereDidUpdateNotification";

