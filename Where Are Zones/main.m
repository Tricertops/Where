//
//  main.m
//  Where Are Zones
//
//  Created by Martin Kiss on 25.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import Foundation;
#import <asl.h>



@interface WhereAreZones : NSObject

- (void)start;

@property (readonly) NSMutableArray *zones;

@end


typedef double Degrees;

typedef struct Coordinate {
    Degrees latitude;
    Degrees longitude;
} Coordinate;

static Coordinate const CoordinateZero = { .latitude = 0, .longitude = .0 };


@interface Zone : NSObject

@property NSString *identifier;
@property NSString *region;
@property Coordinate cooridnate;
@property NSString *comment;

@end



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[WhereAreZones new] start];
    }
    return 0;
}



@implementation WhereAreZones


- (instancetype)init {
    self = [super init];
    if (self) {
        self->_zones = [NSMutableArray new];
    }
    return self;
}


- (void)start {
    const NSURL *projectURL = [NSURL fileURLWithPath:PROJECT_DIR];
    NSURL *targetURL = [projectURL URLByAppendingPathComponent:@"Where Are Zones" isDirectory:YES];
    NSURL *tzURL = [targetURL URLByAppendingPathComponent:@"tz" isDirectory:YES];
    NSURL *zoneTabURL = [tzURL URLByAppendingPathComponent:@"zone.tab" isDirectory:NO];
    {
        NSError *error = nil;
        NSString *zoneTabString = [NSString stringWithContentsOfURL:zoneTabURL encoding:NSUTF8StringEncoding error:&error];
        if ( ! zoneTabString) [self fail:error];
        [self loadZoneTab:zoneTabString];
    }{
        NSError *error = nil;
        NSURL *backwardURL = [tzURL URLByAppendingPathComponent:@"backward" isDirectory:NO];
        NSString *backwardString = [NSString stringWithContentsOfURL:backwardURL encoding:NSUTF8StringEncoding error:&error];
        if ( ! backwardString) [self fail:error];
        [self loadBackward:backwardString];
    }{
        [self addManualEntries];
    }
    NSSortDescriptor *byIdentifier = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    [self.zones sortUsingDescriptors:@[ byIdentifier ]];
    
    [self logCode];
}


- (void)loadZoneTab:(NSString *)zoneTab {
    NSArray *lines = [self linesFromString:zoneTab];
    for (NSString *line in lines) {
        NSArray *columns = [line componentsSeparatedByString:@"\t"];
        Zone *zone = [Zone new];
        zone.identifier = columns[2];
        zone.region = columns[0];
        zone.cooridnate = [self coordinateFromString:columns[1]];
        zone.comment = (columns.count > 3? columns[3] : nil);
        
        [self.zones addObject:zone];
    }
}


- (void)loadBackward:(NSString *)backward {
    NSArray *lines = [self linesFromString:backward];
    for (NSString *line in lines) {
        NSArray *columns = [line componentsSeparatedByString:@"\t"];
        columns = [columns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if ( ! [columns[0] isEqualToString:@"Link"]) [self fail:nil];
        
        Zone *zone = [self createZone:columns[2] linkTo:columns[1]];
        if ( ! zone) continue;
        
        [self.zones addObject:zone];
    }
}


- (void)addManualEntries {
    // On the 2013e release of the tz database, America/Montreal was one of the zones removed from zone.tab, but it is still available in the northamerica file. It was because the group maintaining the database "incorrectly thought that Montreal differed from Toronto in the early 1970s".
    // NSTimeZone list this zone in +knowTimeZoneNames array.
    Zone *montreal = [self createZone:@"America/Montreal" linkTo:@"America/Toronto"];
    [self.zones addObject:montreal];
}


- (void)serializeToPropertyList {
    NSMutableDictionary *plist = [NSMutableDictionary new];
    for (Zone *zone in self.zones) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        dict[@"region"] = zone.region;
        dict[@"coords"] = @[ @(zone.cooridnate.latitude), @(zone.cooridnate.longitude) ];
        if (zone.comment) dict[@"comment"] = zone.comment;
        plist[zone.identifier] = dict;
    }
    NSURL *desktopURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *plistURL = [desktopURL URLByAppendingPathComponent:@"Zones.plist" isDirectory:NO];
    [plist writeToURL:plistURL atomically:YES];
}


- (void)logCode {
    NSMutableArray *lines = [NSMutableArray new];
    for (Zone *zone in self.zones) {
        //    @"Europe/Bratislava": @[ @"SK", @48.15, @17.11666 ],
        NSString *comment = (zone.comment? [NSString stringWithFormat:@" // %@", zone.comment] : @"");
        NSString *line = [NSString stringWithFormat:@"    @\"%@\": @[ @\"%@\", @%.5f, @%.5f ],%@",
                          zone.identifier, zone.region, zone.cooridnate.latitude, zone.cooridnate.longitude, comment];
        [lines addObject:line];
    }
    NSLog(@"Code: \n%@", [lines componentsJoinedByString:@"\n"]);
}





#pragma mark Helpers


- (Zone *)zoneForIdentifier:(NSString *)identifier {
    for (Zone *zone in self.zones) {
        if ([zone.identifier isEqualToString:identifier]) {
            return zone;
        }
    }
    return nil;
}


- (Zone *)createZone:(NSString *)identifier linkTo:(NSString *)linkIdentifier {
    Zone *link = [self zoneForIdentifier:linkIdentifier];
    if ( ! link) return nil;
    
    Zone *zone = [Zone new];
    zone.identifier = identifier;
    zone.region = link.region;
    zone.cooridnate = link.cooridnate;
    zone.comment = [NSString stringWithFormat:@"Link: %@", link.identifier];
    
    return zone;
}


- (Coordinate)coordinateFromString:(NSString *)string {
    // Inspired by Tom Harrington: https://github.com/atomicbird/TZLocation
    NSCharacterSet *signs = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    NSRange split = [string rangeOfCharacterFromSet:signs options:kNilOptions range:NSMakeRange(1, string.length - 1)];
    if (split.location == NSNotFound) [self fail:nil];
    
    NSString *latitudeString = [string substringToIndex:split.location];
    NSString *longitudeString = [string substringFromIndex:split.location];
    Coordinate coordinate = CoordinateZero;
    coordinate.latitude = [self degreesFromString:latitudeString];
    coordinate.longitude = [self degreesFromString:longitudeString];
    return coordinate;
}


- (Degrees)degreesFromString:(NSString *)string {
    NSUInteger minutesStart = NSNotFound;
    NSUInteger secondsStart = NSNotFound;
    switch (string.length) {
        case 5: {
            // +DDMM
            minutesStart = 3;
            break;
        }
        case 6: {
            // +DDDMM
            minutesStart = 4;
            break;
        }
        case 7: {
            // +DDMMSS
            minutesStart = 3;
            secondsStart = 5;
            break;
        }
        case 8: {
            // +DDDMMSS
            minutesStart = 4;
            secondsStart = 6;
            break;
        }
        default: [self fail:nil];
    }
    BOOL hasSeconds = (secondsStart != NSNotFound);
    NSString *degreesString = [string substringToIndex:minutesStart];
    NSUInteger minutesEnd = (hasSeconds? secondsStart : string.length);
    NSRange minutesRange = NSMakeRange(minutesStart, minutesEnd - minutesStart);
    NSString *minutesString = [string substringWithRange:minutesRange];
    NSString *secondsString = (hasSeconds? [string substringFromIndex:secondsStart] : nil);
    
    Degrees degrees = [degreesString doubleValue];
    degrees += [minutesString doubleValue] / 60;
    degrees += [secondsString doubleValue] / 3600;
    return degrees;
}


- (void)fail:(NSError *)error OS_NORETURN {
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        NSString *path = error.userInfo[NSFilePathErrorKey];
        if (path) {
            NSLog(@"Path: %@", path);
        }
        exit((int)error.code);
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Something went wrong here" userInfo:nil];
    }
}


- (NSArray *)linesFromString:(NSString *)string {
    NSMutableArray *builder = [NSMutableArray new];
    [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (line.length > 0 && ! [line hasPrefix:@"#"]) {
            [builder addObject:line];
        }
    }];
    return builder;
}


@end



@implementation Zone

@end


