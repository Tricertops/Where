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
        case WhereSourceIPAddress: return @"IP Address";
        case WhereSourceLocationServices: return @"Location Services";
    }
    return @"Other";
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

static BOOL WhereHasOption(WhereOptions mask, WhereOptions option) {
    return (mask & option) == option;
}

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
    BOOL continuous = WhereHasOption(options, WhereOptionUpdateContinuously);
    if ( ! continuous) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    {
        // Locale
        [self detectUsingLocale];
        if (continuous) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(detectUsingLocale)
                                                         name:NSCurrentLocaleDidChangeNotification
                                                       object:nil];
        }
    }
    {
        // Carrier
        [self detectUsingCarrier];
        if (continuous) {
            [[self network] setSubscriberCellularProviderDidUpdateNotifier:^(CTCarrier *carrier) {
                [self detectUsingCarrier];
            }];
        }
        else {
            [[self network] setSubscriberCellularProviderDidUpdateNotifier:nil];
        }
    }
    {
        // Time Zone
        [self detectUsingTimeZone];
        if (continuous) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(detectUsingTimeZone)
                                                         name:NSSystemTimeZoneDidChangeNotification
                                                       object:nil];
        }
    }
    {
        // IP Address
        BOOL useInternet = WhereHasOption(options, WhereOptionUseInternet);
        if (useInternet) {
            [self startDetectionUsingIPAddress];
        }
        dispatch_queue_t queue = (useInternet && continuous ? dispatch_get_main_queue() : nil);
        SCNetworkReachabilitySetDispatchQueue([self reachability], queue);
    }
    {
        // Location Services
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

+ (SCNetworkReachabilityRef)reachability {
    static SCNetworkReachabilityRef reachability = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        reachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
        SCNetworkReachabilitySetCallback(reachability, &WhereReachabilityCallback, NULL);
    });
    return reachability;
}

+ (CLLocationManager *)locationManager {
    static CLLocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [CLLocationManager new];
        locationManager.distanceFilter = 100;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.delegate = (Class<CLLocationManagerDelegate>)self;
    });
    return locationManager;
}


#pragma mark Sources

+ (void)detectUsingLocale {
    NSString *regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    Where *instance = [Where instanceWithSource:WhereSourceLocale region:regionCode];
    if (instance) {
        NSLog(@"You prefer region of %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)detectUsingCarrier {
    NSString *regionCode = [self network].subscriberCellularProvider.isoCountryCode;
    Where *instance = [Where instanceWithSource:WhereSourceCarrier region:regionCode];
    if (instance) {
        NSLog(@"Your cellular carrier is from %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)detectUsingTimeZone {
    NSString *regionCode = [[NSTimeZone systemTimeZone] regionCode];
    Where *instance = [Where instanceWithSource:WhereSourceTimeZone region:regionCode];
    if (instance) {
        NSLog(@"You are in a time zone of %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)startDetectionUsingIPAddress {
    NSLog(@"Let me check the Internet...");
    NSURL *geobytesURL = [NSURL URLWithString:@"http://www.geobytes.com/IpLocator.htm?GetLocation&template=json.txt"];
    [[[NSURLSession sharedSession] dataTaskWithURL:geobytesURL
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                         BOOL ok = [self finishDetectionUsingIPAddressWithResponse:data];
                                         if ( ! ok) {
                                             NSLog(@"Failed to check the Internet :(");
                                         }
                                     }];
                                 }] resume];
}

+ (BOOL)finishDetectionUsingIPAddressWithResponse:(NSData *)response {
    if ( ! response.length) return NO;
    
    id JSON = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    if ( ! [JSON isKindOfClass:[NSDictionary class]]) return NO;
    
    NSDictionary *dictionary = JSON[@"geobytes"];
    if ( ! [dictionary isKindOfClass:[NSDictionary class]]) return NO;
    
    NSString *regionCode = dictionary[@"iso2"];
    if ( ! [regionCode isKindOfClass:[NSString class]]) return NO;
    
    Where *instance = [Where instanceWithSource:WhereSourceIPAddress region:regionCode];
    if (instance) {
        NSLog(@"You are connected to the Internet in %@.", instance.regionName);
        [self update:instance];
        return YES;
    }
    return NO;
}

static void WhereReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        [Where startDetectionUsingIPAddress];
    }
}

+ (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.lastObject;
    
    BOOL isAccurate = (location.horizontalAccuracy <= manager.desiredAccuracy);
    NSTimeInterval recent = 60; // 1 minute
    BOOL isRecent = ([location.timestamp timeIntervalSinceNow] > -recent);
    if (isAccurate && isRecent) {
        //TODO: Continue when the option was specified.
        [manager stopUpdatingLocation];
    }
    
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.calendar = nil;
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    NSTimeInterval interval = -location.timestamp.timeIntervalSinceNow;
    NSMutableString *message = [NSMutableString new];
    [message appendString:@"Got your "];
    [message appendString:(isAccurate? @"accurate" : @"inaccurate")];
    if (isRecent) {
        [message appendString:@" recent location..."];
    }
    else {
        [message appendFormat:@" location from %@ ago...", [formatter stringFromTimeInterval:interval]];
    }
    NSLog(@"%@", message);
    
    [self startGeocoding:location];
}

+ (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed to get your location :(");
}

+ (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusRestricted: {
            NSLog(@"Location Services are restricted :(");
            break;
        }
        case kCLAuthorizationStatusDenied: {
            NSLog(@"Location Services are denied :(");
            break;
        }
        default: break;
    }
}

+ (void)startGeocoding:(CLLocation *)location {
    //TODO: Geocode.
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

