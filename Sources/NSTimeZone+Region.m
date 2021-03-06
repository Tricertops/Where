//
//  NSTimeZone+Region.m
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

#import "NSTimeZone+Region.h"
#import "NSLocale+Region.h"


@implementation NSTimeZone (Country)


- (NSString *)regionCode {
    NSArray<id> *components = [[self.class timeZoneRegionComponents] objectForKey:self.name];
    return components.firstObject;
}


- (CLLocationCoordinate2D)coordinate {
    NSArray<id> *components = [[self.class timeZoneRegionComponents] objectForKey:self.name];
    return CLLocationCoordinate2DMake([components[1] doubleValue], [components[2] doubleValue]);
}


+ (NSArray<NSTimeZone *> *)timeZonesForRegion:(NSString *)code {
    code = [NSLocale canonizeRegionCode:code];
    if ( ! code) return nil;
    
    return [[self.class timeZonesByRegionCode] objectForKey:code];
}


//! Dictionary whose keys are region ISO codes and values are arrays of time zone identifiers, excluding links.
+ (NSDictionary<NSString *, NSArray<NSTimeZone *> *> *)timeZonesByRegionCode {
    static NSMutableDictionary<NSString *, NSMutableArray<NSTimeZone *> *> *zonesByRegion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zonesByRegion = [NSMutableDictionary dictionaryWithCapacity: 250];
        [[self.class timeZoneRegionComponents] enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, NSArray<id> *components, BOOL *stop) {
            if (components.count >= 4) return; // continue
            
            NSString *region = components.firstObject;
            NSMutableArray<NSTimeZone *> *zones = [zonesByRegion objectForKey:region];
            if ( ! zones) {
                zones = [NSMutableArray new];
                [zonesByRegion setObject:zones forKey:region];
            }
            NSTimeZone *zone = [NSTimeZone timeZoneWithName:identifier];
            if (zone) [zones addObject:zone];
        }];
    });
    return zonesByRegion;
}


#pragma mark -

//! Dictionary whose keys are time zone identifiers and values are heterogenous arrays. The array contains: region ISO code, latitude, longitude and optional time zone identifier to which it is linked.
+ (NSDictionary<NSString *, NSArray<id> *> *)timeZoneRegionComponents {
    static NSDictionary<NSString *, NSArray<id> *> *codes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        codes = @{
                  @"Africa/Abidjan": @[ @"CI", @5.31667, @-3.96667 ],
                  @"Africa/Accra": @[ @"GH", @5.55000, @0.21667 ],
                  @"Africa/Addis_Ababa": @[ @"ET", @9.03333, @38.70000 ],
                  @"Africa/Algiers": @[ @"DZ", @36.78333, @3.05000 ],
                  @"Africa/Asmara": @[ @"ER", @15.33333, @38.88333 ],
                  @"Africa/Asmera": @[ @"KE", @-0.71667, @36.81667, @"Africa/Nairobi" ],
                  @"Africa/Bamako": @[ @"ML", @12.65000, @-8.00000 ],
                  @"Africa/Bangui": @[ @"CF", @4.36667, @18.58333 ],
                  @"Africa/Banjul": @[ @"GM", @13.46667, @-15.35000 ],
                  @"Africa/Bissau": @[ @"GW", @11.85000, @-14.41667 ],
                  @"Africa/Blantyre": @[ @"MW", @-14.21667, @35.00000 ],
                  @"Africa/Brazzaville": @[ @"CG", @-3.73333, @15.28333 ],
                  @"Africa/Bujumbura": @[ @"BI", @-2.61667, @29.36667 ],
                  @"Africa/Cairo": @[ @"EG", @30.05000, @31.25000 ],
                  @"Africa/Casablanca": @[ @"MA", @33.65000, @-6.41667 ],
                  @"Africa/Ceuta": @[ @"ES", @35.88333, @-4.68333 ], // Ceuta, Melilla
                  @"Africa/Conakry": @[ @"GN", @9.51667, @-12.28333 ],
                  @"Africa/Dakar": @[ @"SN", @14.66667, @-16.56667 ],
                  @"Africa/Dar_es_Salaam": @[ @"TZ", @-5.20000, @39.28333 ],
                  @"Africa/Djibouti": @[ @"DJ", @11.60000, @43.15000 ],
                  @"Africa/Douala": @[ @"CM", @4.05000, @9.70000 ],
                  @"Africa/El_Aaiun": @[ @"EH", @27.15000, @-12.80000 ],
                  @"Africa/Freetown": @[ @"SL", @8.50000, @-12.75000 ],
                  @"Africa/Gaborone": @[ @"BW", @-23.35000, @25.91667 ],
                  @"Africa/Harare": @[ @"ZW", @-16.16667, @31.05000 ],
                  @"Africa/Johannesburg": @[ @"ZA", @-25.75000, @28.00000 ],
                  @"Africa/Juba": @[ @"SS", @4.85000, @31.61667 ],
                  @"Africa/Kampala": @[ @"UG", @0.31667, @32.41667 ],
                  @"Africa/Khartoum": @[ @"SD", @15.60000, @32.53333 ],
                  @"Africa/Kigali": @[ @"RW", @-0.05000, @30.06667 ],
                  @"Africa/Kinshasa": @[ @"CD", @-3.70000, @15.30000 ], // Dem. Rep. of Congo (west)
                  @"Africa/Lagos": @[ @"NG", @6.45000, @3.40000 ],
                  @"Africa/Libreville": @[ @"GA", @0.38333, @9.45000 ],
                  @"Africa/Lome": @[ @"TG", @6.13333, @1.21667 ],
                  @"Africa/Luanda": @[ @"AO", @-7.20000, @13.23333 ],
                  @"Africa/Lubumbashi": @[ @"CD", @-10.33333, @27.46667 ], // Dem. Rep. of Congo (east)
                  @"Africa/Lusaka": @[ @"ZM", @-14.58333, @28.28333 ],
                  @"Africa/Malabo": @[ @"GQ", @3.75000, @8.78333 ],
                  @"Africa/Maputo": @[ @"MZ", @-24.03333, @32.58333 ],
                  @"Africa/Maseru": @[ @"LS", @-28.53333, @27.50000 ],
                  @"Africa/Mbabane": @[ @"SZ", @-25.70000, @31.10000 ],
                  @"Africa/Mogadishu": @[ @"SO", @2.06667, @45.36667 ],
                  @"Africa/Monrovia": @[ @"LR", @6.30000, @-9.21667 ],
                  @"Africa/Nairobi": @[ @"KE", @-0.71667, @36.81667 ],
                  @"Africa/Ndjamena": @[ @"TD", @12.11667, @15.05000 ],
                  @"Africa/Niamey": @[ @"NE", @13.51667, @2.11667 ],
                  @"Africa/Nouakchott": @[ @"MR", @18.10000, @-14.05000 ],
                  @"Africa/Ouagadougou": @[ @"BF", @12.36667, @-0.48333 ],
                  @"Africa/Porto-Novo": @[ @"BJ", @6.48333, @2.61667 ],
                  @"Africa/Sao_Tome": @[ @"ST", @0.33333, @6.73333 ],
                  @"Africa/Timbuktu": @[ @"CI", @5.31667, @-3.96667, @"Africa/Abidjan" ],
                  @"Africa/Tripoli": @[ @"LY", @32.90000, @13.18333 ],
                  @"Africa/Tunis": @[ @"TN", @36.80000, @10.18333 ],
                  @"Africa/Windhoek": @[ @"NA", @-21.43333, @17.10000 ],
                  @"America/Adak": @[ @"US", @51.88000, @-175.34194 ], // Aleutian Islands
                  @"America/Anchorage": @[ @"US", @61.21806, @-148.09972 ], // Alaska (most areas)
                  @"America/Anguilla": @[ @"AI", @18.20000, @-62.93333 ],
                  @"America/Antigua": @[ @"AG", @17.05000, @-60.20000 ],
                  @"America/Araguaina": @[ @"BR", @-6.80000, @-47.80000 ], // Tocantins
                  @"America/Argentina/Buenos_Aires": @[ @"AR", @-33.40000, @-57.55000 ], // Buenos Aires (BA, CF)
                  @"America/Argentina/Catamarca": @[ @"AR", @-27.53333, @-64.21667 ], // Catamarca (CT); Chubut (CH)
                  @"America/Argentina/ComodRivadavia": @[ @"AR", @-27.53333, @-64.21667, @"America/Argentina/Catamarca" ],
                  @"America/Argentina/Cordoba": @[ @"AR", @-30.60000, @-63.81667 ], // Argentina (most areas: CB, CC, CN, ER, FM, MN, SE, SF)
                  @"America/Argentina/Jujuy": @[ @"AR", @-23.81667, @-64.70000 ], // Jujuy (JY)
                  @"America/Argentina/La_Rioja": @[ @"AR", @-28.56667, @-65.15000 ], // La Rioja (LR)
                  @"America/Argentina/Mendoza": @[ @"AR", @-31.11667, @-67.18333 ], // Mendoza (MZ)
                  @"America/Argentina/Rio_Gallegos": @[ @"AR", @-50.36667, @-68.78333 ], // Santa Cruz (SC)
                  @"America/Argentina/Salta": @[ @"AR", @-23.21667, @-64.58333 ], // Salta (SA, LP, NQ, RN)
                  @"America/Argentina/San_Juan": @[ @"AR", @-30.46667, @-67.48333 ], // San Juan (SJ)
                  @"America/Argentina/San_Luis": @[ @"AR", @-32.68333, @-65.65000 ], // San Luis (SL)
                  @"America/Argentina/Tucuman": @[ @"AR", @-25.18333, @-64.78333 ], // Tucuman (TM)
                  @"America/Argentina/Ushuaia": @[ @"AR", @-53.20000, @-67.70000 ], // Tierra del Fuego (TF)
                  @"America/Aruba": @[ @"AW", @12.50000, @-68.03333 ],
                  @"America/Asuncion": @[ @"PY", @-24.73333, @-56.33333 ],
                  @"America/Atikokan": @[ @"CA", @48.75861, @-90.37833 ], // EST - ON (Atikokan); NU (Coral H)
                  @"America/Atka": @[ @"US", @51.88000, @-175.34194, @"America/Adak" ],
                  @"America/Bahia": @[ @"BR", @-11.01667, @-37.48333 ], // Bahia
                  @"America/Bahia_Banderas": @[ @"MX", @20.80000, @-104.75000 ], // Central Time - Bahia de Banderas
                  @"America/Barbados": @[ @"BB", @13.10000, @-58.38333 ],
                  @"America/Belem": @[ @"BR", @-0.55000, @-47.51667 ], // Para (east); Amapa
                  @"America/Belize": @[ @"BZ", @17.50000, @-87.80000 ],
                  @"America/Blanc-Sablon": @[ @"CA", @51.41667, @-56.88333 ], // AST - QC (Lower North Shore)
                  @"America/Boa_Vista": @[ @"BR", @2.81667, @-59.33333 ], // Roraima
                  @"America/Bogota": @[ @"CO", @4.60000, @-73.91667 ],
                  @"America/Boise": @[ @"US", @43.61361, @-115.79750 ], // Mountain - ID (south); OR (east)
                  @"America/Buenos_Aires": @[ @"AR", @-33.40000, @-57.55000, @"America/Argentina/Buenos_Aires" ],
                  @"America/Cambridge_Bay": @[ @"CA", @69.11389, @-104.94722 ], // Mountain - NU (west)
                  @"America/Campo_Grande": @[ @"BR", @-19.55000, @-53.38333 ], // Mato Grosso do Sul
                  @"America/Cancun": @[ @"MX", @21.08333, @-85.23333 ], // Eastern Standard Time - Quintana Roo
                  @"America/Caracas": @[ @"VE", @10.50000, @-65.06667 ],
                  @"America/Catamarca": @[ @"AR", @-27.53333, @-64.21667, @"America/Argentina/Catamarca" ],
                  @"America/Cayenne": @[ @"GF", @4.93333, @-51.66667 ],
                  @"America/Cayman": @[ @"KY", @19.30000, @-80.61667 ],
                  @"America/Chicago": @[ @"US", @41.85000, @-86.35000 ], // Central (most areas)
                  @"America/Chihuahua": @[ @"MX", @28.63333, @-105.91667 ], // Mountain Time - Chihuahua (most areas)
                  @"America/Coral_Harbour": @[ @"CA", @48.75861, @-90.37833, @"America/Atikokan" ],
                  @"America/Cordoba": @[ @"AR", @-30.60000, @-63.81667, @"America/Argentina/Cordoba" ],
                  @"America/Costa_Rica": @[ @"CR", @9.93333, @-83.91667 ],
                  @"America/Creston": @[ @"CA", @49.10000, @-115.48333 ], // MST - BC (Creston)
                  @"America/Cuiaba": @[ @"BR", @-14.41667, @-55.91667 ], // Mato Grosso
                  @"America/Curacao": @[ @"CW", @12.18333, @-69.00000 ],
                  @"America/Danmarkshavn": @[ @"GL", @76.76667, @-17.33333 ], // National Park (east coast)
                  @"America/Dawson": @[ @"CA", @64.06667, @-138.58333 ], // Pacific - Yukon (north)
                  @"America/Dawson_Creek": @[ @"CA", @59.76667, @-119.76667 ], // MST - BC (Dawson Cr, Ft St John)
                  @"America/Denver": @[ @"US", @39.73917, @-103.01583 ], // Mountain (most areas)
                  @"America/Detroit": @[ @"US", @42.33139, @-82.95417 ], // Eastern - MI (most areas)
                  @"America/Dominica": @[ @"DM", @15.30000, @-60.60000 ],
                  @"America/Edmonton": @[ @"CA", @53.55000, @-112.53333 ], // Mountain - AB; BC (E); SK (W)
                  @"America/Eirunepe": @[ @"BR", @-5.33333, @-68.13333 ], // Amazonas (west)
                  @"America/El_Salvador": @[ @"SV", @13.70000, @-88.80000 ],
                  @"America/Ensenada": @[ @"MX", @32.53333, @-116.98333, @"America/Tijuana" ],
                  @"America/Fort_Nelson": @[ @"CA", @58.80000, @-121.30000 ], // MST - BC (Ft Nelson)
                  @"America/Fort_Wayne": @[ @"US", @39.76833, @-85.84194, @"America/Indiana/Indianapolis" ],
                  @"America/Fortaleza": @[ @"BR", @-2.28333, @-37.50000 ], // Brazil (northeast: MA, PI, CE, RN, PB)
                  @"America/Glace_Bay": @[ @"CA", @46.20000, @-58.05000 ], // Atlantic - NS (Cape Breton)
                  @"America/Godthab": @[ @"GL", @64.18333, @-50.26667 ], // Greenland (most areas)
                  @"America/Goose_Bay": @[ @"CA", @53.33333, @-59.58333 ], // Atlantic - Labrador (most areas)
                  @"America/Grand_Turk": @[ @"TC", @21.46667, @-70.86667 ],
                  @"America/Grenada": @[ @"GD", @12.05000, @-60.25000 ],
                  @"America/Guadeloupe": @[ @"GP", @16.23333, @-60.46667 ],
                  @"America/Guatemala": @[ @"GT", @14.63333, @-89.48333 ],
                  @"America/Guayaquil": @[ @"EC", @-1.83333, @-78.16667 ], // Ecuador (mainland)
                  @"America/Guyana": @[ @"GY", @6.80000, @-57.83333 ],
                  @"America/Halifax": @[ @"CA", @44.65000, @-62.40000 ], // Atlantic - NS (most areas); PE
                  @"America/Havana": @[ @"CU", @23.13333, @-81.63333 ],
                  @"America/Hermosillo": @[ @"MX", @29.06667, @-109.03333 ], // Mountain Standard Time - Sonora
                  @"America/Indiana/Indianapolis": @[ @"US", @39.76833, @-85.84194 ], // Eastern - IN (most areas)
                  @"America/Indiana/Knox": @[ @"US", @41.29583, @-85.37500 ], // Central - IN (Starke)
                  @"America/Indiana/Marengo": @[ @"US", @38.37556, @-85.65528 ], // Eastern - IN (Crawford)
                  @"America/Indiana/Petersburg": @[ @"US", @38.49194, @-86.72139 ], // Eastern - IN (Pike)
                  @"America/Indiana/Tell_City": @[ @"US", @37.95306, @-85.23861 ], // Central - IN (Perry)
                  @"America/Indiana/Vevay": @[ @"US", @38.74778, @-84.93278 ], // Eastern - IN (Switzerland)
                  @"America/Indiana/Vincennes": @[ @"US", @38.67722, @-86.47139 ], // Eastern - IN (Da, Du, K, Mn)
                  @"America/Indiana/Winamac": @[ @"US", @41.05139, @-85.39694 ], // Eastern - IN (Pulaski)
                  @"America/Indianapolis": @[ @"US", @39.76833, @-85.84194, @"America/Indiana/Indianapolis" ],
                  @"America/Inuvik": @[ @"CA", @68.34972, @-132.28333 ], // Mountain - NT (west)
                  @"America/Iqaluit": @[ @"CA", @63.73333, @-67.53333 ], // Eastern - NU (most east areas)
                  @"America/Jamaica": @[ @"JM", @17.96806, @-75.20667 ],
                  @"America/Jujuy": @[ @"AR", @-23.81667, @-64.70000, @"America/Argentina/Jujuy" ],
                  @"America/Juneau": @[ @"US", @58.30194, @-133.58028 ], // Alaska - Juneau area
                  @"America/Kentucky/Louisville": @[ @"US", @38.25417, @-84.24056 ], // Eastern - KY (Louisville area)
                  @"America/Kentucky/Monticello": @[ @"US", @36.82972, @-83.15083 ], // Eastern - KY (Wayne)
                  @"America/Knox_IN": @[ @"US", @41.29583, @-85.37500, @"America/Indiana/Knox" ],
                  @"America/Kralendijk": @[ @"BQ", @12.15083, @-67.72333 ],
                  @"America/La_Paz": @[ @"BO", @-15.50000, @-67.85000 ],
                  @"America/Lima": @[ @"PE", @-11.95000, @-76.95000 ],
                  @"America/Los_Angeles": @[ @"US", @34.05222, @-117.75722 ], // Pacific
                  @"America/Louisville": @[ @"US", @38.25417, @-84.24056, @"America/Kentucky/Louisville" ],
                  @"America/Lower_Princes": @[ @"SX", @18.05139, @-62.95278 ],
                  @"America/Maceio": @[ @"BR", @-8.33333, @-34.28333 ], // Alagoas, Sergipe
                  @"America/Managua": @[ @"NI", @12.15000, @-85.71667 ],
                  @"America/Manaus": @[ @"BR", @-2.86667, @-59.98333 ], // Amazonas (east)
                  @"America/Marigot": @[ @"MF", @18.06667, @-62.91667 ],
                  @"America/Martinique": @[ @"MQ", @14.60000, @-60.91667 ],
                  @"America/Matamoros": @[ @"MX", @25.83333, @-96.50000 ], // Central Time US - Coahuila, Nuevo Leon, Tamaulipas (US border)
                  @"America/Mazatlan": @[ @"MX", @23.21667, @-105.58333 ], // Mountain Time - Baja California Sur, Nayarit, Sinaloa
                  @"America/Mendoza": @[ @"AR", @-31.11667, @-67.18333, @"America/Argentina/Mendoza" ],
                  @"America/Menominee": @[ @"US", @45.10778, @-86.38583 ], // Central - MI (Wisconsin border)
                  @"America/Merida": @[ @"MX", @20.96667, @-88.38333 ], // Central Time - Campeche, Yucatan
                  @"America/Metlakatla": @[ @"US", @55.12694, @-130.42361 ], // Alaska - Annette Island
                  @"America/Mexico_City": @[ @"MX", @19.40000, @-98.85000 ], // Central Time
                  @"America/Miquelon": @[ @"PM", @47.05000, @-55.66667 ],
                  @"America/Moncton": @[ @"CA", @46.10000, @-63.21667 ], // Atlantic - New Brunswick
                  @"America/Monterrey": @[ @"MX", @25.66667, @-99.68333 ], // Central Time - Durango; Coahuila, Nuevo Leon, Tamaulipas (most areas)
                  @"America/Montevideo": @[ @"UY", @-33.09083, @-55.78750 ],
                  @"America/Montreal": @[ @"CA", @43.65000, @-78.61667, @"America/Toronto" ],
                  @"America/Montserrat": @[ @"MS", @16.71667, @-61.78333 ],
                  @"America/Nassau": @[ @"BS", @25.08333, @-76.65000 ],
                  @"America/New_York": @[ @"US", @40.71417, @-73.99361 ], // Eastern (most areas)
                  @"America/Nipigon": @[ @"CA", @49.01667, @-87.73333 ], // Eastern - ON, QC (no DST 1967-73)
                  @"America/Nome": @[ @"US", @64.50111, @-164.59361 ], // Alaska (west)
                  @"America/Noronha": @[ @"BR", @-2.15000, @-31.58333 ], // Atlantic islands
                  @"America/North_Dakota/Beulah": @[ @"US", @47.26417, @-100.22222 ], // Central - ND (Mercer)
                  @"America/North_Dakota/Center": @[ @"US", @47.11639, @-100.70083 ], // Central - ND (Oliver)
                  @"America/North_Dakota/New_Salem": @[ @"US", @46.84500, @-100.58917 ], // Central - ND (Morton rural)
                  @"America/Ojinaga": @[ @"MX", @29.56667, @-103.58333 ], // Mountain Time US - Chihuahua (US border)
                  @"America/Panama": @[ @"PA", @8.96667, @-78.46667 ],
                  @"America/Pangnirtung": @[ @"CA", @66.13333, @-64.26667 ], // Eastern - NU (Pangnirtung)
                  @"America/Paramaribo": @[ @"SR", @5.83333, @-54.83333 ],
                  @"America/Phoenix": @[ @"US", @33.44833, @-111.92667 ], // MST - Arizona (except Navajo)
                  @"America/Port-au-Prince": @[ @"HT", @18.53333, @-71.66667 ],
                  @"America/Port_of_Spain": @[ @"TT", @10.65000, @-60.48333 ],
                  @"America/Porto_Acre": @[ @"BR", @-8.03333, @-66.20000, @"America/Rio_Branco" ],
                  @"America/Porto_Velho": @[ @"BR", @-7.23333, @-62.10000 ], // Rondonia
                  @"America/Puerto_Rico": @[ @"PR", @18.46833, @-65.89389 ],
                  @"America/Punta_Arenas": @[ @"CL", @-52.85000, @-69.08333 ], // Region of Magallanes
                  @"America/Rainy_River": @[ @"CA", @48.71667, @-93.43333 ], // Central - ON (Rainy R, Ft Frances)
                  @"America/Rankin_Inlet": @[ @"CA", @62.81667, @-91.91694 ], // Central - NU (central)
                  @"America/Recife": @[ @"BR", @-7.95000, @-33.10000 ], // Pernambuco
                  @"America/Regina": @[ @"CA", @50.40000, @-103.35000 ], // CST - SK (most areas)
                  @"America/Resolute": @[ @"CA", @74.69556, @-93.17083 ], // Central - NU (Resolute)
                  @"America/Rio_Branco": @[ @"BR", @-8.03333, @-66.20000 ], // Acre
                  @"America/Rosario": @[ @"AR", @-30.60000, @-63.81667, @"America/Argentina/Cordoba" ],
                  @"America/Santa_Isabel": @[ @"MX", @32.53333, @-116.98333, @"America/Tijuana" ],
                  @"America/Santarem": @[ @"BR", @-1.56667, @-53.13333 ], // Para (west)
                  @"America/Santiago": @[ @"CL", @-32.55000, @-69.33333 ], // Chile (most areas)
                  @"America/Santo_Domingo": @[ @"DO", @18.46667, @-68.10000 ],
                  @"America/Sao_Paulo": @[ @"BR", @-22.46667, @-45.38333 ], // Brazil (southeast: GO, DF, MG, ES, RJ, SP, PR, SC, RS)
                  @"America/Scoresbysund": @[ @"GL", @70.48333, @-20.03333 ], // Scoresbysund/Ittoqqortoormiit
                  @"America/Shiprock": @[ @"US", @39.73917, @-103.01583, @"America/Denver" ],
                  @"America/Sitka": @[ @"US", @57.17639, @-134.69806 ], // Alaska - Sitka area
                  @"America/St_Barthelemy": @[ @"BL", @17.88333, @-61.15000 ],
                  @"America/St_Johns": @[ @"CA", @47.56667, @-51.28333 ], // Newfoundland; Labrador (southeast)
                  @"America/St_Kitts": @[ @"KN", @17.30000, @-61.28333 ],
                  @"America/St_Lucia": @[ @"LC", @14.01667, @-61.00000 ],
                  @"America/St_Thomas": @[ @"VI", @18.35000, @-63.06667 ],
                  @"America/St_Vincent": @[ @"VC", @13.15000, @-60.76667 ],
                  @"America/Swift_Current": @[ @"CA", @50.28333, @-106.16667 ], // CST - SK (midwest)
                  @"America/Tegucigalpa": @[ @"HN", @14.10000, @-86.78333 ],
                  @"America/Thule": @[ @"GL", @76.56667, @-67.21667 ], // Thule/Pituffik
                  @"America/Thunder_Bay": @[ @"CA", @48.38333, @-88.75000 ], // Eastern - ON (Thunder Bay)
                  @"America/Tijuana": @[ @"MX", @32.53333, @-116.98333 ], // Pacific Time US - Baja California
                  @"America/Toronto": @[ @"CA", @43.65000, @-78.61667 ], // Eastern - ON, QC (most areas)
                  @"America/Tortola": @[ @"VG", @18.45000, @-63.38333 ],
                  @"America/Vancouver": @[ @"CA", @49.26667, @-122.88333 ], // Pacific - BC (most areas)
                  @"America/Virgin": @[ @"TT", @10.65000, @-60.48333, @"America/Port_of_Spain" ],
                  @"America/Whitehorse": @[ @"CA", @60.71667, @-134.95000 ], // Pacific - Yukon (south)
                  @"America/Winnipeg": @[ @"CA", @49.88333, @-96.85000 ], // Central - ON (west); Manitoba
                  @"America/Yakutat": @[ @"US", @59.54694, @-138.27278 ], // Alaska - Yakutat
                  @"America/Yellowknife": @[ @"CA", @62.45000, @-113.65000 ], // Mountain - NT (central)
                  @"Antarctica/Casey": @[ @"AQ", @-65.71667, @110.51667 ], // Casey
                  @"Antarctica/Davis": @[ @"AQ", @-67.41667, @77.96667 ], // Davis
                  @"Antarctica/DumontDUrville": @[ @"AQ", @-65.33333, @140.01667 ], // Dumont-d'Urville
                  @"Antarctica/Macquarie": @[ @"AU", @-53.50000, @158.95000 ], // Macquarie Island
                  @"Antarctica/Mawson": @[ @"AQ", @-66.40000, @62.88333 ], // Mawson
                  @"Antarctica/McMurdo": @[ @"AQ", @-76.16667, @166.60000 ], // New Zealand time - McMurdo, South Pole
                  @"Antarctica/Palmer": @[ @"AQ", @-63.20000, @-63.90000 ], // Palmer
                  @"Antarctica/Rothera": @[ @"AQ", @-66.43333, @-67.86667 ], // Rothera
                  @"Antarctica/South_Pole": @[ @"NZ", @-35.13333, @174.76667, @"Pacific/Auckland" ],
                  @"Antarctica/Syowa": @[ @"AQ", @-68.99389, @39.59000 ], // Syowa
                  @"Antarctica/Troll": @[ @"AQ", @-71.98861, @2.53500 ], // Troll
                  @"Antarctica/Vostok": @[ @"AQ", @-77.60000, @106.90000 ], // Vostok
                  @"Arctic/Longyearbyen": @[ @"SJ", @78.00000, @16.00000 ],
                  @"Asia/Aden": @[ @"YE", @12.75000, @45.20000 ],
                  @"Asia/Almaty": @[ @"KZ", @43.25000, @76.95000 ], // Kazakhstan (most areas)
                  @"Asia/Amman": @[ @"JO", @31.95000, @35.93333 ],
                  @"Asia/Anadyr": @[ @"RU", @64.75000, @177.48333 ], // MSK+09 - Bering Sea
                  @"Asia/Aqtau": @[ @"KZ", @44.51667, @50.26667 ], // Mangghystau/Mankistau
                  @"Asia/Aqtobe": @[ @"KZ", @50.28333, @57.16667 ], // Aqtobe/Aktobe
                  @"Asia/Ashgabat": @[ @"TM", @37.95000, @58.38333 ],
                  @"Asia/Ashkhabad": @[ @"TM", @37.95000, @58.38333, @"Asia/Ashgabat" ],
                  @"Asia/Atyrau": @[ @"KZ", @47.11667, @51.93333 ], // Atyrau/Atirau/Gur'yev
                  @"Asia/Baghdad": @[ @"IQ", @33.35000, @44.41667 ],
                  @"Asia/Bahrain": @[ @"BH", @26.38333, @50.58333 ],
                  @"Asia/Baku": @[ @"AZ", @40.38333, @49.85000 ],
                  @"Asia/Bangkok": @[ @"TH", @13.75000, @100.51667 ],
                  @"Asia/Barnaul": @[ @"RU", @53.36667, @83.75000 ], // MSK+04 - Altai
                  @"Asia/Beirut": @[ @"LB", @33.88333, @35.50000 ],
                  @"Asia/Bishkek": @[ @"KG", @42.90000, @74.60000 ],
                  @"Asia/Brunei": @[ @"BN", @4.93333, @114.91667 ],
                  @"Asia/Calcutta": @[ @"IN", @22.53333, @88.36667, @"Asia/Kolkata" ],
                  @"Asia/Chita": @[ @"RU", @52.05000, @113.46667 ], // MSK+06 - Zabaykalsky
                  @"Asia/Choibalsan": @[ @"MN", @48.06667, @114.50000 ], // Dornod, Sukhbaatar
                  @"Asia/Chongqing": @[ @"CN", @31.23333, @121.46667, @"Asia/Shanghai" ],
                  @"Asia/Chungking": @[ @"CN", @31.23333, @121.46667, @"Asia/Shanghai" ],
                  @"Asia/Colombo": @[ @"LK", @6.93333, @79.85000 ],
                  @"Asia/Dacca": @[ @"BD", @23.71667, @90.41667, @"Asia/Dhaka" ],
                  @"Asia/Damascus": @[ @"SY", @33.50000, @36.30000 ],
                  @"Asia/Dhaka": @[ @"BD", @23.71667, @90.41667 ],
                  @"Asia/Dili": @[ @"TL", @-7.45000, @125.58333 ],
                  @"Asia/Dubai": @[ @"AE", @25.30000, @55.30000 ],
                  @"Asia/Dushanbe": @[ @"TJ", @38.58333, @68.80000 ],
                  @"Asia/Famagusta": @[ @"CY", @35.11667, @33.95000 ], // Northern Cyprus
                  @"Asia/Gaza": @[ @"PS", @31.50000, @34.46667 ], // Gaza Strip
                  @"Asia/Harbin": @[ @"CN", @31.23333, @121.46667, @"Asia/Shanghai" ],
                  @"Asia/Hebron": @[ @"PS", @31.53333, @35.09500 ], // West Bank
                  @"Asia/Ho_Chi_Minh": @[ @"VN", @10.75000, @106.66667 ],
                  @"Asia/Hong_Kong": @[ @"HK", @22.28333, @114.15000 ],
                  @"Asia/Hovd": @[ @"MN", @48.01667, @91.65000 ], // Bayan-Olgiy, Govi-Altai, Hovd, Uvs, Zavkhan
                  @"Asia/Irkutsk": @[ @"RU", @52.26667, @104.33333 ], // MSK+05 - Irkutsk, Buryatia
                  @"Asia/Jakarta": @[ @"ID", @-5.83333, @106.80000 ], // Java, Sumatra
                  @"Asia/Jayapura": @[ @"ID", @-1.46667, @140.70000 ], // New Guinea (West Papua / Irian Jaya); Malukus/Moluccas
                  @"Asia/Jerusalem": @[ @"IL", @31.78056, @35.22389 ],
                  @"Asia/Kabul": @[ @"AF", @34.51667, @69.20000 ],
                  @"Asia/Kamchatka": @[ @"RU", @53.01667, @158.65000 ], // MSK+09 - Kamchatka
                  @"Asia/Karachi": @[ @"PK", @24.86667, @67.05000 ],
                  @"Asia/Kashgar": @[ @"CN", @43.80000, @87.58333, @"Asia/Urumqi" ],
                  @"Asia/Kathmandu": @[ @"NP", @27.71667, @85.31667 ],
                  @"Asia/Katmandu": @[ @"NP", @27.71667, @85.31667, @"Asia/Kathmandu" ],
                  @"Asia/Khandyga": @[ @"RU", @62.65639, @135.55389 ], // MSK+06 - Tomponsky, Ust-Maysky
                  @"Asia/Kolkata": @[ @"IN", @22.53333, @88.36667 ],
                  @"Asia/Krasnoyarsk": @[ @"RU", @56.01667, @92.83333 ], // MSK+04 - Krasnoyarsk area
                  @"Asia/Kuala_Lumpur": @[ @"MY", @3.16667, @101.70000 ], // Malaysia (peninsula)
                  @"Asia/Kuching": @[ @"MY", @1.55000, @110.33333 ], // Sabah, Sarawak
                  @"Asia/Kuwait": @[ @"KW", @29.33333, @47.98333 ],
                  @"Asia/Macao": @[ @"MO", @22.19722, @113.54167, @"Asia/Macau" ],
                  @"Asia/Macau": @[ @"MO", @22.19722, @113.54167 ],
                  @"Asia/Magadan": @[ @"RU", @59.56667, @150.80000 ], // MSK+08 - Magadan
                  @"Asia/Makassar": @[ @"ID", @-4.88333, @119.40000 ], // Borneo (east, south); Sulawesi/Celebes, Bali, Nusa Tengarra; Timor (west)
                  @"Asia/Manila": @[ @"PH", @14.58333, @121.00000 ],
                  @"Asia/Muscat": @[ @"OM", @23.60000, @58.58333 ],
                  @"Asia/Nicosia": @[ @"CY", @35.16667, @33.36667 ], // Cyprus (most areas)
                  @"Asia/Novokuznetsk": @[ @"RU", @53.75000, @87.11667 ], // MSK+04 - Kemerovo
                  @"Asia/Novosibirsk": @[ @"RU", @55.03333, @82.91667 ], // MSK+04 - Novosibirsk
                  @"Asia/Omsk": @[ @"RU", @55.00000, @73.40000 ], // MSK+03 - Omsk
                  @"Asia/Oral": @[ @"KZ", @51.21667, @51.35000 ], // West Kazakhstan
                  @"Asia/Phnom_Penh": @[ @"KH", @11.55000, @104.91667 ],
                  @"Asia/Pontianak": @[ @"ID", @0.03333, @109.33333 ], // Borneo (west, central)
                  @"Asia/Pyongyang": @[ @"KP", @39.01667, @125.75000 ],
                  @"Asia/Qatar": @[ @"QA", @25.28333, @51.53333 ],
                  @"Asia/Qostanay": @[ @"KZ", @53.20000, @63.61667 ], // Qostanay/Kostanay/Kustanay
                  @"Asia/Qyzylorda": @[ @"KZ", @44.80000, @65.46667 ], // Qyzylorda/Kyzylorda/Kzyl-Orda
                  @"Asia/Rangoon": @[ @"MM", @16.78333, @96.16667, @"Asia/Yangon" ],
                  @"Asia/Riyadh": @[ @"SA", @24.63333, @46.71667 ],
                  @"Asia/Saigon": @[ @"VN", @10.75000, @106.66667, @"Asia/Ho_Chi_Minh" ],
                  @"Asia/Sakhalin": @[ @"RU", @46.96667, @142.70000 ], // MSK+08 - Sakhalin Island
                  @"Asia/Samarkand": @[ @"UZ", @39.66667, @66.80000 ], // Uzbekistan (west)
                  @"Asia/Seoul": @[ @"KR", @37.55000, @126.96667 ],
                  @"Asia/Shanghai": @[ @"CN", @31.23333, @121.46667 ], // Beijing Time
                  @"Asia/Singapore": @[ @"SG", @1.28333, @103.85000 ],
                  @"Asia/Srednekolymsk": @[ @"RU", @67.46667, @153.71667 ], // MSK+08 - Sakha (E); North Kuril Is
                  @"Asia/Taipei": @[ @"TW", @25.05000, @121.50000 ],
                  @"Asia/Tashkent": @[ @"UZ", @41.33333, @69.30000 ], // Uzbekistan (east)
                  @"Asia/Tbilisi": @[ @"GE", @41.71667, @44.81667 ],
                  @"Asia/Tehran": @[ @"IR", @35.66667, @51.43333 ],
                  @"Asia/Tel_Aviv": @[ @"IL", @31.78056, @35.22389, @"Asia/Jerusalem" ],
                  @"Asia/Thimbu": @[ @"BT", @27.46667, @89.65000, @"Asia/Thimphu" ],
                  @"Asia/Thimphu": @[ @"BT", @27.46667, @89.65000 ],
                  @"Asia/Tokyo": @[ @"JP", @35.65444, @139.74472 ],
                  @"Asia/Tomsk": @[ @"RU", @56.50000, @84.96667 ], // MSK+04 - Tomsk
                  @"Asia/Ujung_Pandang": @[ @"ID", @-4.88333, @119.40000, @"Asia/Makassar" ],
                  @"Asia/Ulaanbaatar": @[ @"MN", @47.91667, @106.88333 ], // Mongolia (most areas)
                  @"Asia/Ulan_Bator": @[ @"MN", @47.91667, @106.88333, @"Asia/Ulaanbaatar" ],
                  @"Asia/Urumqi": @[ @"CN", @43.80000, @87.58333 ], // Xinjiang Time
                  @"Asia/Ust-Nera": @[ @"RU", @64.56028, @143.22667 ], // MSK+07 - Oymyakonsky
                  @"Asia/Vientiane": @[ @"LA", @17.96667, @102.60000 ],
                  @"Asia/Vladivostok": @[ @"RU", @43.16667, @131.93333 ], // MSK+07 - Amur River
                  @"Asia/Yakutsk": @[ @"RU", @62.00000, @129.66667 ], // MSK+06 - Lena River
                  @"Asia/Yangon": @[ @"MM", @16.78333, @96.16667 ],
                  @"Asia/Yekaterinburg": @[ @"RU", @56.85000, @60.60000 ], // MSK+02 - Urals
                  @"Asia/Yerevan": @[ @"AM", @40.18333, @44.50000 ],
                  @"Atlantic/Azores": @[ @"PT", @37.73333, @-24.33333 ], // Azores
                  @"Atlantic/Bermuda": @[ @"BM", @32.28333, @-63.23333 ],
                  @"Atlantic/Canary": @[ @"ES", @28.10000, @-14.60000 ], // Canary Islands
                  @"Atlantic/Cape_Verde": @[ @"CV", @14.91667, @-22.48333 ],
                  @"Atlantic/Faeroe": @[ @"FO", @62.01667, @-5.23333, @"Atlantic/Faroe" ],
                  @"Atlantic/Faroe": @[ @"FO", @62.01667, @-5.23333 ],
                  @"Atlantic/Jan_Mayen": @[ @"NO", @59.91667, @10.75000, @"Europe/Oslo" ],
                  @"Atlantic/Madeira": @[ @"PT", @32.63333, @-15.10000 ], // Madeira Islands
                  @"Atlantic/Reykjavik": @[ @"IS", @64.15000, @-20.15000 ],
                  @"Atlantic/South_Georgia": @[ @"GS", @-53.73333, @-35.46667 ],
                  @"Atlantic/St_Helena": @[ @"SH", @-14.08333, @-4.30000 ],
                  @"Atlantic/Stanley": @[ @"FK", @-50.30000, @-56.15000 ],
                  @"Australia/ACT": @[ @"AU", @-32.13333, @151.21667, @"Australia/Sydney" ],
                  @"Australia/Adelaide": @[ @"AU", @-33.08333, @138.58333 ], // South Australia
                  @"Australia/Brisbane": @[ @"AU", @-26.53333, @153.03333 ], // Queensland (most areas)
                  @"Australia/Broken_Hill": @[ @"AU", @-30.05000, @141.45000 ], // New South Wales (Yancowinna)
                  @"Australia/Canberra": @[ @"AU", @-32.13333, @151.21667, @"Australia/Sydney" ],
                  @"Australia/Currie": @[ @"AU", @-38.06667, @143.86667 ], // Tasmania (King Island)
                  @"Australia/Darwin": @[ @"AU", @-11.53333, @130.83333 ], // Northern Territory
                  @"Australia/Eucla": @[ @"AU", @-30.28333, @128.86667 ], // Western Australia (Eucla)
                  @"Australia/Hobart": @[ @"AU", @-41.11667, @147.31667 ], // Tasmania (most areas)
                  @"Australia/LHI": @[ @"AU", @-30.45000, @159.08333, @"Australia/Lord_Howe" ],
                  @"Australia/Lindeman": @[ @"AU", @-19.73333, @149.00000 ], // Queensland (Whitsunday Islands)
                  @"Australia/Lord_Howe": @[ @"AU", @-30.45000, @159.08333 ], // Lord Howe Island
                  @"Australia/Melbourne": @[ @"AU", @-36.18333, @144.96667 ], // Victoria
                  @"Australia/NSW": @[ @"AU", @-32.13333, @151.21667, @"Australia/Sydney" ],
                  @"Australia/North": @[ @"AU", @-11.53333, @130.83333, @"Australia/Darwin" ],
                  @"Australia/Perth": @[ @"AU", @-30.05000, @115.85000 ], // Western Australia (most areas)
                  @"Australia/Queensland": @[ @"AU", @-26.53333, @153.03333, @"Australia/Brisbane" ],
                  @"Australia/South": @[ @"AU", @-33.08333, @138.58333, @"Australia/Adelaide" ],
                  @"Australia/Sydney": @[ @"AU", @-32.13333, @151.21667 ], // New South Wales (most areas)
                  @"Australia/Tasmania": @[ @"AU", @-41.11667, @147.31667, @"Australia/Hobart" ],
                  @"Australia/Victoria": @[ @"AU", @-36.18333, @144.96667, @"Australia/Melbourne" ],
                  @"Australia/West": @[ @"AU", @-30.05000, @115.85000, @"Australia/Perth" ],
                  @"Australia/Yancowinna": @[ @"AU", @-30.05000, @141.45000, @"Australia/Broken_Hill" ],
                  @"Brazil/Acre": @[ @"BR", @-8.03333, @-66.20000, @"America/Rio_Branco" ],
                  @"Brazil/DeNoronha": @[ @"BR", @-2.15000, @-31.58333, @"America/Noronha" ],
                  @"Brazil/East": @[ @"BR", @-22.46667, @-45.38333, @"America/Sao_Paulo" ],
                  @"Brazil/West": @[ @"BR", @-2.86667, @-59.98333, @"America/Manaus" ],
                  @"Canada/Atlantic": @[ @"CA", @44.65000, @-62.40000, @"America/Halifax" ],
                  @"Canada/Central": @[ @"CA", @49.88333, @-96.85000, @"America/Winnipeg" ],
                  @"Canada/Eastern": @[ @"CA", @43.65000, @-78.61667, @"America/Toronto" ],
                  @"Canada/Mountain": @[ @"CA", @53.55000, @-112.53333, @"America/Edmonton" ],
                  @"Canada/Newfoundland": @[ @"CA", @47.56667, @-51.28333, @"America/St_Johns" ],
                  @"Canada/Pacific": @[ @"CA", @49.26667, @-122.88333, @"America/Vancouver" ],
                  @"Canada/Saskatchewan": @[ @"CA", @50.40000, @-103.35000, @"America/Regina" ],
                  @"Canada/Yukon": @[ @"CA", @60.71667, @-134.95000, @"America/Whitehorse" ],
                  @"Chile/Continental": @[ @"CL", @-32.55000, @-69.33333, @"America/Santiago" ],
                  @"Chile/EasterIsland": @[ @"CL", @-26.85000, @-108.56667, @"Pacific/Easter" ],
                  @"Cuba": @[ @"CU", @23.13333, @-81.63333, @"America/Havana" ],
                  @"Egypt": @[ @"EG", @30.05000, @31.25000, @"Africa/Cairo" ],
                  @"Eire": @[ @"IE", @53.33333, @-5.75000, @"Europe/Dublin" ],
                  @"Europe/Amsterdam": @[ @"NL", @52.36667, @4.90000 ],
                  @"Europe/Andorra": @[ @"AD", @42.50000, @1.51667 ],
                  @"Europe/Astrakhan": @[ @"RU", @46.35000, @48.05000 ], // MSK+01 - Astrakhan
                  @"Europe/Athens": @[ @"GR", @37.96667, @23.71667 ],
                  @"Europe/Belfast": @[ @"GB", @51.50833, @0.12528, @"Europe/London" ],
                  @"Europe/Belgrade": @[ @"RS", @44.83333, @20.50000 ],
                  @"Europe/Berlin": @[ @"DE", @52.50000, @13.36667 ], // Germany (most areas)
                  @"Europe/Bratislava": @[ @"SK", @48.15000, @17.11667 ],
                  @"Europe/Brussels": @[ @"BE", @50.83333, @4.33333 ],
                  @"Europe/Bucharest": @[ @"RO", @44.43333, @26.10000 ],
                  @"Europe/Budapest": @[ @"HU", @47.50000, @19.08333 ],
                  @"Europe/Busingen": @[ @"DE", @47.70000, @8.68333 ], // Busingen
                  @"Europe/Chisinau": @[ @"MD", @47.00000, @28.83333 ],
                  @"Europe/Copenhagen": @[ @"DK", @55.66667, @12.58333 ],
                  @"Europe/Dublin": @[ @"IE", @53.33333, @-5.75000 ],
                  @"Europe/Gibraltar": @[ @"GI", @36.13333, @-4.65000 ],
                  @"Europe/Guernsey": @[ @"GG", @49.45472, @-1.46389 ],
                  @"Europe/Helsinki": @[ @"FI", @60.16667, @24.96667 ],
                  @"Europe/Isle_of_Man": @[ @"IM", @54.15000, @-3.53333 ],
                  @"Europe/Istanbul": @[ @"TR", @41.01667, @28.96667 ],
                  @"Europe/Jersey": @[ @"JE", @49.18361, @-1.89333 ],
                  @"Europe/Kaliningrad": @[ @"RU", @54.71667, @20.50000 ], // MSK-01 - Kaliningrad
                  @"Europe/Kiev": @[ @"UA", @50.43333, @30.51667 ], // Ukraine (most areas)
                  @"Europe/Kirov": @[ @"RU", @58.60000, @49.65000 ], // MSK+00 - Kirov
                  @"Europe/Lisbon": @[ @"PT", @38.71667, @-8.86667 ], // Portugal (mainland)
                  @"Europe/Ljubljana": @[ @"SI", @46.05000, @14.51667 ],
                  @"Europe/London": @[ @"GB", @51.50833, @0.12528 ],
                  @"Europe/Luxembourg": @[ @"LU", @49.60000, @6.15000 ],
                  @"Europe/Madrid": @[ @"ES", @40.40000, @-2.31667 ], // Spain (mainland)
                  @"Europe/Malta": @[ @"MT", @35.90000, @14.51667 ],
                  @"Europe/Mariehamn": @[ @"AX", @60.10000, @19.95000 ],
                  @"Europe/Minsk": @[ @"BY", @53.90000, @27.56667 ],
                  @"Europe/Monaco": @[ @"MC", @43.70000, @7.38333 ],
                  @"Europe/Moscow": @[ @"RU", @55.75583, @37.61778 ], // MSK+00 - Moscow area
                  @"Europe/Oslo": @[ @"NO", @59.91667, @10.75000 ],
                  @"Europe/Paris": @[ @"FR", @48.86667, @2.33333 ],
                  @"Europe/Podgorica": @[ @"ME", @42.43333, @19.26667 ],
                  @"Europe/Prague": @[ @"CZ", @50.08333, @14.43333 ],
                  @"Europe/Riga": @[ @"LV", @56.95000, @24.10000 ],
                  @"Europe/Rome": @[ @"IT", @41.90000, @12.48333 ],
                  @"Europe/Samara": @[ @"RU", @53.20000, @50.15000 ], // MSK+01 - Samara, Udmurtia
                  @"Europe/San_Marino": @[ @"SM", @43.91667, @12.46667 ],
                  @"Europe/Sarajevo": @[ @"BA", @43.86667, @18.41667 ],
                  @"Europe/Saratov": @[ @"RU", @51.56667, @46.03333 ], // MSK+01 - Saratov
                  @"Europe/Simferopol": @[ @"UA", @44.95000, @34.10000 ], // MSK+00 - Crimea
                  @"Europe/Skopje": @[ @"MK", @41.98333, @21.43333 ],
                  @"Europe/Sofia": @[ @"BG", @42.68333, @23.31667 ],
                  @"Europe/Stockholm": @[ @"SE", @59.33333, @18.05000 ],
                  @"Europe/Tallinn": @[ @"EE", @59.41667, @24.75000 ],
                  @"Europe/Tirane": @[ @"AL", @41.33333, @19.83333 ],
                  @"Europe/Tiraspol": @[ @"MD", @47.00000, @28.83333, @"Europe/Chisinau" ],
                  @"Europe/Ulyanovsk": @[ @"RU", @54.33333, @48.40000 ], // MSK+01 - Ulyanovsk
                  @"Europe/Uzhgorod": @[ @"UA", @48.61667, @22.30000 ], // Ruthenia
                  @"Europe/Vaduz": @[ @"LI", @47.15000, @9.51667 ],
                  @"Europe/Vatican": @[ @"VA", @41.90222, @12.45306 ],
                  @"Europe/Vienna": @[ @"AT", @48.21667, @16.33333 ],
                  @"Europe/Vilnius": @[ @"LT", @54.68333, @25.31667 ],
                  @"Europe/Volgograd": @[ @"RU", @48.73333, @44.41667 ], // MSK+01 - Volgograd
                  @"Europe/Warsaw": @[ @"PL", @52.25000, @21.00000 ],
                  @"Europe/Zagreb": @[ @"HR", @45.80000, @15.96667 ],
                  @"Europe/Zaporozhye": @[ @"UA", @47.83333, @35.16667 ], // Zaporozh'ye/Zaporizhia; Lugansk/Luhansk (east)
                  @"Europe/Zurich": @[ @"CH", @47.38333, @8.53333 ],
                  @"GB": @[ @"GB", @51.50833, @0.12528, @"Europe/London" ],
                  @"GB-Eire": @[ @"GB", @51.50833, @0.12528, @"Europe/London" ],
                  @"Hongkong": @[ @"HK", @22.28333, @114.15000, @"Asia/Hong_Kong" ],
                  @"Iceland": @[ @"IS", @64.15000, @-20.15000, @"Atlantic/Reykjavik" ],
                  @"Indian/Antananarivo": @[ @"MG", @-17.08333, @47.51667 ],
                  @"Indian/Chagos": @[ @"IO", @-6.66667, @72.41667 ],
                  @"Indian/Christmas": @[ @"CX", @-9.58333, @105.71667 ],
                  @"Indian/Cocos": @[ @"CC", @-11.83333, @96.91667 ],
                  @"Indian/Comoro": @[ @"KM", @-10.31667, @43.26667 ],
                  @"Indian/Kerguelen": @[ @"TF", @-48.64722, @70.21750 ],
                  @"Indian/Mahe": @[ @"SC", @-3.33333, @55.46667 ],
                  @"Indian/Maldives": @[ @"MV", @4.16667, @73.50000 ],
                  @"Indian/Mauritius": @[ @"MU", @-19.83333, @57.50000 ],
                  @"Indian/Mayotte": @[ @"YT", @-11.21667, @45.23333 ],
                  @"Indian/Reunion": @[ @"RE", @-19.13333, @55.46667 ],
                  @"Iran": @[ @"IR", @35.66667, @51.43333, @"Asia/Tehran" ],
                  @"Israel": @[ @"IL", @31.78056, @35.22389, @"Asia/Jerusalem" ],
                  @"Jamaica": @[ @"JM", @17.96806, @-75.20667, @"America/Jamaica" ],
                  @"Japan": @[ @"JP", @35.65444, @139.74472, @"Asia/Tokyo" ],
                  @"Kwajalein": @[ @"MH", @9.08333, @167.33333, @"Pacific/Kwajalein" ],
                  @"Libya": @[ @"LY", @32.90000, @13.18333, @"Africa/Tripoli" ],
                  @"Mexico/BajaNorte": @[ @"MX", @32.53333, @-116.98333, @"America/Tijuana" ],
                  @"Mexico/BajaSur": @[ @"MX", @23.21667, @-105.58333, @"America/Mazatlan" ],
                  @"Mexico/General": @[ @"MX", @19.40000, @-98.85000, @"America/Mexico_City" ],
                  @"NZ": @[ @"NZ", @-35.13333, @174.76667, @"Pacific/Auckland" ],
                  @"NZ-CHAT": @[ @"NZ", @-42.05000, @-175.45000, @"Pacific/Chatham" ],
                  @"Navajo": @[ @"US", @39.73917, @-103.01583, @"America/Denver" ],
                  @"PRC": @[ @"CN", @31.23333, @121.46667, @"Asia/Shanghai" ],
                  @"Pacific/Apia": @[ @"WS", @-12.16667, @-170.26667 ],
                  @"Pacific/Auckland": @[ @"NZ", @-35.13333, @174.76667 ], // New Zealand (most areas)
                  @"Pacific/Bougainville": @[ @"PG", @-5.78333, @155.56667 ], // Bougainville
                  @"Pacific/Chatham": @[ @"NZ", @-42.05000, @-175.45000 ], // Chatham Islands
                  @"Pacific/Chuuk": @[ @"FM", @7.41667, @151.78333 ], // Chuuk/Truk, Yap
                  @"Pacific/Easter": @[ @"CL", @-26.85000, @-108.56667 ], // Easter Island
                  @"Pacific/Efate": @[ @"VU", @-16.33333, @168.41667 ],
                  @"Pacific/Enderbury": @[ @"KI", @-2.86667, @-170.91667 ], // Phoenix Islands
                  @"Pacific/Fakaofo": @[ @"TK", @-8.63333, @-170.76667 ],
                  @"Pacific/Fiji": @[ @"FJ", @-17.86667, @178.41667 ],
                  @"Pacific/Funafuti": @[ @"TV", @-7.48333, @179.21667 ],
                  @"Pacific/Galapagos": @[ @"EC", @0.90000, @-88.40000 ], // Galapagos Islands
                  @"Pacific/Gambier": @[ @"PF", @-22.86667, @-133.05000 ], // Gambier Islands
                  @"Pacific/Guadalcanal": @[ @"SB", @-8.46667, @160.20000 ],
                  @"Pacific/Guam": @[ @"GU", @13.46667, @144.75000 ],
                  @"Pacific/Honolulu": @[ @"US", @21.30694, @-156.14167 ], // Hawaii
                  @"Pacific/Johnston": @[ @"US", @21.30694, @-156.14167, @"Pacific/Honolulu" ],
                  @"Pacific/Kiritimati": @[ @"KI", @1.86667, @-156.66667 ], // Line Islands
                  @"Pacific/Kosrae": @[ @"FM", @5.31667, @162.98333 ], // Kosrae
                  @"Pacific/Kwajalein": @[ @"MH", @9.08333, @167.33333 ], // Kwajalein
                  @"Pacific/Majuro": @[ @"MH", @7.15000, @171.20000 ], // Marshall Islands (most areas)
                  @"Pacific/Marquesas": @[ @"PF", @-9.00000, @-138.50000 ], // Marquesas Islands
                  @"Pacific/Midway": @[ @"UM", @28.21667, @-176.63333 ], // Midway Islands
                  @"Pacific/Nauru": @[ @"NR", @0.51667, @166.91667 ],
                  @"Pacific/Niue": @[ @"NU", @-18.98333, @-168.08333 ],
                  @"Pacific/Norfolk": @[ @"NF", @-28.95000, @167.96667 ],
                  @"Pacific/Noumea": @[ @"NC", @-21.73333, @166.45000 ],
                  @"Pacific/Pago_Pago": @[ @"AS", @-13.73333, @-169.30000 ],
                  @"Pacific/Palau": @[ @"PW", @7.33333, @134.48333 ],
                  @"Pacific/Pitcairn": @[ @"PN", @-24.93333, @-129.91667 ],
                  @"Pacific/Pohnpei": @[ @"FM", @6.96667, @158.21667 ], // Pohnpei/Ponape
                  @"Pacific/Ponape": @[ @"FM", @6.96667, @158.21667, @"Pacific/Pohnpei" ],
                  @"Pacific/Port_Moresby": @[ @"PG", @-8.50000, @147.16667 ], // Papua New Guinea (most areas)
                  @"Pacific/Rarotonga": @[ @"CK", @-20.76667, @-158.23333 ],
                  @"Pacific/Saipan": @[ @"MP", @15.20000, @145.75000 ],
                  @"Pacific/Samoa": @[ @"AS", @-13.73333, @-169.30000, @"Pacific/Pago_Pago" ],
                  @"Pacific/Tahiti": @[ @"PF", @-16.46667, @-148.43333 ], // Society Islands
                  @"Pacific/Tarawa": @[ @"KI", @1.41667, @173.00000 ], // Gilbert Islands
                  @"Pacific/Tongatapu": @[ @"TO", @-20.83333, @-174.83333 ],
                  @"Pacific/Truk": @[ @"FM", @7.41667, @151.78333, @"Pacific/Chuuk" ],
                  @"Pacific/Wake": @[ @"UM", @19.28333, @166.61667 ], // Wake Island
                  @"Pacific/Wallis": @[ @"WF", @-12.70000, @-175.83333 ],
                  @"Pacific/Yap": @[ @"FM", @7.41667, @151.78333, @"Pacific/Chuuk" ],
                  @"Poland": @[ @"PL", @52.25000, @21.00000, @"Europe/Warsaw" ],
                  @"Portugal": @[ @"PT", @38.71667, @-8.86667, @"Europe/Lisbon" ],
                  @"ROC": @[ @"TW", @25.05000, @121.50000, @"Asia/Taipei" ],
                  @"ROK": @[ @"KR", @37.55000, @126.96667, @"Asia/Seoul" ],
                  @"Singapore": @[ @"SG", @1.28333, @103.85000, @"Asia/Singapore" ],
                  @"Turkey": @[ @"TR", @41.01667, @28.96667, @"Europe/Istanbul" ],
                  @"US/Alaska": @[ @"US", @61.21806, @-148.09972, @"America/Anchorage" ],
                  @"US/Aleutian": @[ @"US", @51.88000, @-175.34194, @"America/Adak" ],
                  @"US/Arizona": @[ @"US", @33.44833, @-111.92667, @"America/Phoenix" ],
                  @"US/Central": @[ @"US", @41.85000, @-86.35000, @"America/Chicago" ],
                  @"US/East-Indiana": @[ @"US", @39.76833, @-85.84194, @"America/Indiana/Indianapolis" ],
                  @"US/Eastern": @[ @"US", @40.71417, @-73.99361, @"America/New_York" ],
                  @"US/Hawaii": @[ @"US", @21.30694, @-156.14167, @"Pacific/Honolulu" ],
                  @"US/Indiana-Starke": @[ @"US", @41.29583, @-85.37500, @"America/Indiana/Knox" ],
                  @"US/Michigan": @[ @"US", @42.33139, @-82.95417, @"America/Detroit" ],
                  @"US/Mountain": @[ @"US", @39.73917, @-103.01583, @"America/Denver" ],
                  @"US/Pacific": @[ @"US", @34.05222, @-117.75722, @"America/Los_Angeles" ],
                  @"US/Samoa": @[ @"AS", @-13.73333, @-169.30000, @"Pacific/Pago_Pago" ],
                  @"W-SU": @[ @"RU", @55.75583, @37.61778, @"Europe/Moscow" ],
                  };
    });
    return codes;
}


@end

