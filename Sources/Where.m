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
        case WhereSourceCellularIPAddress: return @"Cellular IP Address";
        case WhereSourceTimeZone: return @"Time Zone";
        case WhereSourceWiFiIPAddress: return @"Wi-Fi IP Address";
#if WHERE_COMPILE_LOCATION_SERVICES
        case WhereSourceLocationServices: return @"Location Services";
#endif
    }
    return @"Other";
}

@interface Where ()

+ (instancetype)instanceWithSource:(WhereSource)source
                            region:(NSString *)regionCode
                        coordinate:(CLLocationCoordinate2D)coordinate;

@end


@implementation Where

+ (instancetype)instanceWithSource:(WhereSource)source region:(NSString *)region coordinate:(CLLocationCoordinate2D)coord {
    NSString *canonizedRegionCode = [NSLocale canonizeRegionCode:region];
    if ( ! canonizedRegionCode.length) return nil;
    
    Where *instance = [super new];
    if (instance) {
        instance->_source = source;
        instance->_timestamp = [NSDate new];
        instance->_regionCode = canonizedRegionCode;
        instance->_regionName = [NSLocale nameOfRegion:canonizedRegionCode];
        instance->_coordinate = coord;
    }
    return instance;
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

+ (void)initialize {
    NSLog(@"Where are you?");
    [self detectWithOptions:WhereOptionDefault];
}

+ (Where *)detectDebugging {
    static Where *debugging = nil;
#if DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *option = [[NSUserDefaults standardUserDefaults] stringForKey:@"WhereDebug"];
        if ( ! option) return;
        
        NSString *regionCode = [NSLocale canonizeRegionCode:option];
        if (regionCode) {
            debugging = [Where instanceWithSource:WhereSourceNone
                                           region:regionCode
                                       coordinate:[NSLocale coordinateForRegion:regionCode]];
        }
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:option];
        if (timeZone) {
            debugging = [Where instanceWithSource:WhereSourceNone
                                           region:timeZone.regionCode
                                       coordinate:timeZone.coordinate];
        }
        
        if (debugging) {
            NSLog(@"We will pretend you are in %@.", debugging.regionName);
        }
    });
#endif
    return debugging;
}

+ (void)detectWithOptions:(WhereOptions)currentOptions {
    Where *debugging = [self detectDebugging];
    if (debugging) {
        [self update:debugging];
        return;
    }
    
    static WhereOptions previousOptions = WhereOptionNone;
    
    BOOL isUpToDate = WhereHasOption(previousOptions, WhereOptionUpdateContinuously);
    BOOL shouldObserve = WhereHasOption(currentOptions, WhereOptionUpdateContinuously);

    {
        // Locale
        if ( ! isUpToDate) {
            [self detectUsingLocale];
            if (shouldObserve) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(detectUsingLocale)
                                                             name:NSCurrentLocaleDidChangeNotification
                                                           object:nil];
            }
        }
        else if ( ! shouldObserve) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
        }
    }
    {
        #if !TARGET_OS_MACCATALYST
        // Carrier
        if ( ! isUpToDate) {
            [self detectUsingCarrier];
            if (shouldObserve) {
                [[self network] setServiceSubscriberCellularProvidersDidUpdateNotifier:^(NSString *carrier) {
                    [self detectUsingCarrier];
                }];
            }
        }
        else if ( ! shouldObserve) {
            [[self network] setServiceSubscriberCellularProvidersDidUpdateNotifier:nil];
        }
        #endif
    }
    {
        // Time Zone
        if ( ! isUpToDate) {
            [self detectUsingTimeZone];
            if (shouldObserve) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(detectUsingTimeZone)
                                                             name:NSSystemTimeZoneDidChangeNotification
                                                           object:nil];
            }
        }
        else if ( ! shouldObserve) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSSystemTimeZoneDidChangeNotification object:nil];
        }
    }
    {
        // IP Address
        BOOL useInternet = WhereHasOption(currentOptions, WhereOptionUseInternet);
        if (useInternet) {
            BOOL wasUsingInternet = WhereHasOption(previousOptions, WhereOptionUseInternet);
            if ( ! wasUsingInternet || ! isUpToDate) {
                [self startDetectionUsingIPAddress];
            }
        }
        else {
            [self clear:WhereSourceCellularIPAddress];
            [self clear:WhereSourceWiFiIPAddress];
        }
        dispatch_queue_t queue = (useInternet && shouldObserve ? dispatch_get_main_queue() : nil);
        SCNetworkReachabilitySetDispatchQueue([self reachability], queue);
    }
#if WHERE_COMPILE_LOCATION_SERVICES
    {
        // Location Services
        if (WhereHasOption(currentOptions, WhereOptionAskForPermission)) {
            NSString *usage = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"];
            if ( ! usage) {
                NSLog(@"You should include NSLocationWhenInUseUsageDescription in your Info.plist to make AskForPermission option work.");
            }
            if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [[self locationManager] requestWhenInUseAuthorization];
            }
        }
        BOOL useLocation = WhereHasOption(currentOptions, WhereOptionUseLocationServices);
        CLLocationDistance filter = (useLocation && shouldObserve ? 100 : CLLocationDistanceMax);
        [[self locationManager] setDistanceFilter:filter];
        if (useLocation) {
            BOOL wasUsingLocation = WhereHasOption(previousOptions, WhereOptionUseLocationServices);
            if ( ! wasUsingLocation || isUpToDate) {
                NSLog(@"Let me use Location Services...");
                [[self locationManager] startUpdatingLocation];
            }
        }
        else {
            [[self locationManager] stopUpdatingLocation];
            [self clear:WhereSourceLocationServices];
        }
    }
#endif
    
    previousOptions = currentOptions;
}


#pragma mark State

#if !TARGET_OS_MACCATALYST

+ (CTTelephonyNetworkInfo *)network {
    static CTTelephonyNetworkInfo *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [CTTelephonyNetworkInfo new];
    });
    return network;
}

#endif

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

#if WHERE_COMPILE_LOCATION_SERVICES
+ (CLLocationManager *)locationManager {
    static CLLocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [CLLocationManager new];
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.delegate = (Class<CLLocationManagerDelegate>)self;
    });
    return locationManager;
}

+ (CLGeocoder *)geocoder {
    static CLGeocoder *geocoder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        geocoder = [CLGeocoder new];
    });
    return geocoder;
}
#endif


#pragma mark Sources

+ (void)detectUsingLocale {
    NSLocale *locale = [NSLocale currentLocale];
    Where *instance = [Where instanceWithSource:WhereSourceLocale
                                         region:[locale regionCode]
                                     coordinate:[locale regionCoordinate]];
    if (instance) {
        NSLog(@"You prefer region of %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)detectUsingCarrier {
    #if !TARGET_OS_MACCATALYST
    //TODO: Multiple SIM cards allow for multiple location guesses.
    CTCarrier *carrier = [self network].serviceSubscriberCellularProviders.allValues.firstObject;
    NSString *regionCode = carrier.isoCountryCode;
    Where *instance = [Where instanceWithSource:WhereSourceCarrier
                                         region:regionCode
                                     coordinate:[NSLocale coordinateForRegion:regionCode]];
    if (instance) {
        NSLog(@"Your cellular carrier is from %@.", instance.regionName);
        [self update:instance];
    }
    #endif
}

+ (void)detectUsingTimeZone {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    Where *instance = [Where instanceWithSource:WhereSourceTimeZone
                                         region:zone.regionCode
                                     coordinate:zone.coordinate];
    if (instance) {
        NSLog(@"You are in a time zone of %@.", instance.regionName);
        [self update:instance];
    }
}

+ (void)startDetectionUsingIPAddress {
    NSLog(@"Let me check the Internet...");
    
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags([self reachability], &flags);
    BOOL viaWiFi = (flags & kSCNetworkReachabilityFlagsIsWWAN) == 0;
    
    NSURL *geobytesURL = [NSURL URLWithString:@"https://freegeoip.net/json"];
    [[[NSURLSession sharedSession] dataTaskWithURL:geobytesURL
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                         BOOL ok = [self finishDetectionUsingIPAddressWithResponse:data WiFi:viaWiFi];
                                         if ( ! ok) {
                                             NSLog(@"Failed to check the Internet :(");
                                         }
                                     }];
                                 }] resume];
}

+ (BOOL)finishDetectionUsingIPAddressWithResponse:(NSData *)response WiFi:(BOOL)viaWiFi {
    if ( ! response.length) return NO;
    
    NSDictionary<NSString *, id> *JSON = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    if ( ! [JSON isKindOfClass:[NSDictionary class]]) return NO;
    
    NSString *regionCode = JSON[@"country_code"];
    if ( ! [regionCode isKindOfClass:[NSString class]]) return NO;
    
    CLLocationCoordinate2D coord = kCLLocationCoordinate2DInvalid;
    NSNumber *lat = JSON[@"latitude"];
    NSNumber *lng = JSON[@"longitude"];
    if ([lat isKindOfClass:[NSNumber class]] && [lng isKindOfClass:[NSNumber class]]) {
        coord = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
    }
    else {
        // Fallback
        coord = [NSLocale coordinateForRegion:regionCode];
    }
    
    [self clear:(viaWiFi? WhereSourceCellularIPAddress : WhereSourceWiFiIPAddress)];
    
    WhereSource source = (viaWiFi? WhereSourceWiFiIPAddress : WhereSourceCellularIPAddress);
    Where *instance = [Where instanceWithSource:source
                                         region:regionCode
                                     coordinate:coord];
    if (instance) {
        NSLog(@"You are connected to the Internet via %@ in %@.", (viaWiFi? @"Wi-Fi" : @"cellular"), instance.regionName);
        [self update:instance];
        return YES;
    }
    return NO;
}

static void WhereReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    BOOL isReachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    
    if (isReachable) {
        [Where startDetectionUsingIPAddress];
    }
}

#if WHERE_COMPILE_LOCATION_SERVICES
+ (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    
    BOOL isAccurate = (location.horizontalAccuracy <= manager.desiredAccuracy);
    NSTimeInterval recent = 60; // 1 minute
    BOOL isRecent = ([location.timestamp timeIntervalSinceNow] > -recent);
    BOOL shouldContinue = (manager.distanceFilter < CLLocationDistanceMax);
    if ( ! shouldContinue && isAccurate && isRecent) {
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
    
    [self cancelPreviousPerformRequestsWithTarget:self]; //NOTE: Cancels everything.
    [self performSelector:@selector(startGeocoding:) withObject:location afterDelay:0.25];
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
    NSLog(@"Geocoding your current location...");
    [[self geocoder] cancelGeocode];
    [[self geocoder] reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorGeocodeCanceled) return;
        
        CLPlacemark *placemark = placemarks.firstObject;
        Where *instance = [Where instanceWithSource:WhereSourceLocationServices
                                             region:placemark.ISOcountryCode
                                         coordinate:location.coordinate];
        if (instance) {
            NSLog(@"You are in %@.", instance.regionName);
            [self update:instance];
        }
        else {
            NSLog(@"Failed to geocode your location :(");
        }
    }];
}
#endif


#pragma mark Storage

+ (void)update:(Where *)instance {
    NSParameterAssert(instance);
    if ( ! instance) return;
    if (instance.source == WhereSourceNone) return;
    
    [[self bySource] setObject:instance forKey:@(instance.source)];
    [[NSNotificationCenter defaultCenter] postNotificationName:WhereDidUpdateNotification object:instance];
}

+ (void)clear:(WhereSource)source {
    [[self bySource] removeObjectForKey:@(source)];
    [[NSNotificationCenter defaultCenter] postNotificationName:WhereDidUpdateNotification object:nil];
}

+ (NSMutableDictionary<NSNumber *, Where *> *)bySource {
    static NSMutableDictionary<NSNumber *, Where *> *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionaryWithCapacity:6];
    });
    return dictionary;
}

+ (Where *)isHome {
    return [self detectDebugging]
        ?: [self forSource:WhereSourceCellularIPAddress]
        ?: [self forSource:WhereSourceCarrier]
        ?: [self forSource:WhereSourceLocale];
}

+ (Where *)amI {
    return [self detectDebugging]
#if WHERE_COMPILE_LOCATION_SERVICES
        ?: [self forSource:WhereSourceLocationServices]
#endif
        ?: [self forSource:WhereSourceTimeZone]
        ?: [self forSource:WhereSourceWiFiIPAddress];
}

+ (Where *)forSource:(WhereSource)source {
    return [[self bySource] objectForKey:@(source)];
}

@end


#pragma mark -

NSString * const WhereDidUpdateNotification = @"WhereDidUpdateNotification";

