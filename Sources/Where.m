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
        case WhereSourceLocationServices: return @"Location Services";
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

+ (void)detectWithOptions:(WhereOptions)currentOptions {
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
        // Carrier
        if ( ! isUpToDate) {
            [self detectUsingCarrier];
            if (shouldObserve) {
                [[self network] setSubscriberCellularProviderDidUpdateNotifier:^(CTCarrier *carrier) {
                    [self detectUsingCarrier];
                }];
            }
        }
        else if ( ! shouldObserve) {
            [[self network] setSubscriberCellularProviderDidUpdateNotifier:nil];
        }
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
    {
        // Location Services
        if (WhereHasOption(currentOptions, WhereOptionAskForPermission)) {
            NSString *usage = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"];
            if ( ! usage) {
                NSLog(@"You should include NSLocationWhenInUseUsageDescription in your Info.plist to make AskForPermission option work.");
            }
            [[self locationManager] requestWhenInUseAuthorization];
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
    
    previousOptions = currentOptions;
}


#pragma mark State

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
    NSString *regionCode = [self network].subscriberCellularProvider.isoCountryCode;
    Where *instance = [Where instanceWithSource:WhereSourceCarrier
                                         region:regionCode
                                     coordinate:[NSLocale coordinateForRegion:regionCode]];
    if (instance) {
        NSLog(@"Your cellular carrier is from %@.", instance.regionName);
        [self update:instance];
    }
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
    
    NSURL *geobytesURL = [NSURL URLWithString:@"http://www.geobytes.com/IpLocator.htm?GetLocation&template=json.txt"];
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
    
    id JSON = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    if ( ! [JSON isKindOfClass:[NSDictionary class]]) return NO;
    
    NSDictionary *dictionary = JSON[@"geobytes"];
    if ( ! [dictionary isKindOfClass:[NSDictionary class]]) return NO;
    
    NSString *regionCode = dictionary[@"iso2"];
    if ( ! [regionCode isKindOfClass:[NSString class]]) return NO;
    
    CLLocationCoordinate2D coord = kCLLocationCoordinate2DInvalid;
    NSNumber *lat = dictionary[@"latitude"];
    NSNumber *lng = dictionary[@"longitude"];
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

+ (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
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
    [[self geocoder] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
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

+ (NSMutableDictionary *)bySource {
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionaryWithCapacity:6];
    });
    return dictionary;
}

+ (Where *)isHome {
    return [self forSource:WhereSourceCellularIPAddress]
        ?: [self forSource:WhereSourceCarrier]
        ?: [self forSource:WhereSourceLocale];
}

+ (Where *)amI {
    return [self forSource:WhereSourceLocationServices]
        ?: [self forSource:WhereSourceTimeZone]
        ?: [self forSource:WhereSourceWiFiIPAddress];
}

+ (Where *)forSource:(WhereSource)source {
    return [[self bySource] objectForKey:@(source)];
}

@end


#pragma mark -

NSString * const WhereDidUpdateNotification = @"WhereDidUpdateNotification";

