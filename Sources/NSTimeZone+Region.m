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
    NSArray *components = [[self.class timeZoneRegionComponents] objectForKey:self.name];
    return components.firstObject;
}


- (CLLocationCoordinate2D)coordinate {
    NSArray *components = [[self.class timeZoneRegionComponents] objectForKey:self.name];
    return CLLocationCoordinate2DMake([components[1] doubleValue], [components[2] doubleValue]);
}


+ (NSArray *)timeZonesForRegion:(NSString *)code {
    code = [NSLocale canonizeRegionCode:code];
    if ( ! code) return nil;
    
    NSMutableArray *zones = [NSMutableArray new];
    [[self.class timeZoneRegionComponents] enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, NSArray *components, BOOL *stop) {
        if ([code isEqualToString:components.firstObject]) {
            [zones addObject:[NSTimeZone timeZoneWithName:identifier]];
        }
    }];
    return zones;
}


#pragma mark -

+ (NSDictionary *)timeZoneRegionComponents {
    static NSDictionary *codes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        codes = @{
                  @"Africa/Abidjan": @[ @"CI", @5.31667, @-3.96667 ],
                  @"Africa/Accra": @[ @"GH", @5.55000, @0.21667 ],
                  @"Africa/Addis_Ababa": @[ @"ET", @9.03333, @38.70000 ],
                  @"Africa/Algiers": @[ @"DZ", @36.78333, @3.05000 ],
                  @"Africa/Asmara": @[ @"ER", @15.33333, @38.88333 ],
                  @"Africa/Bamako": @[ @"ML", @12.65000, @-8.00000 ],
                  @"Africa/Bangui": @[ @"CF", @4.36667, @18.58333 ],
                  @"Africa/Banjul": @[ @"GM", @13.46667, @-15.35000 ],
                  @"Africa/Bissau": @[ @"GW", @11.85000, @-14.41667 ],
                  @"Africa/Blantyre": @[ @"MW", @-14.21667, @35.00000 ],
                  @"Africa/Brazzaville": @[ @"CG", @-3.73333, @15.28333 ],
                  @"Africa/Bujumbura": @[ @"BI", @-2.61667, @29.36667 ],
                  @"Africa/Cairo": @[ @"EG", @30.05000, @31.25000 ],
                  @"Africa/Casablanca": @[ @"MA", @33.65000, @-6.41667 ],
                  @"Africa/Ceuta": @[ @"ES", @35.88333, @-4.68333 ], // Ceuta & Melilla
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
                  @"Africa/Juba": @[ @"SS", @4.85000, @31.60000 ],
                  @"Africa/Kampala": @[ @"UG", @0.31667, @32.41667 ],
                  @"Africa/Khartoum": @[ @"SD", @15.60000, @32.53333 ],
                  @"Africa/Kigali": @[ @"RW", @-0.05000, @30.06667 ],
                  @"Africa/Kinshasa": @[ @"CD", @-3.70000, @15.30000 ], // west Dem. Rep. of Congo
                  @"Africa/Lagos": @[ @"NG", @6.45000, @3.40000 ],
                  @"Africa/Libreville": @[ @"GA", @0.38333, @9.45000 ],
                  @"Africa/Lome": @[ @"TG", @6.13333, @1.21667 ],
                  @"Africa/Luanda": @[ @"AO", @-7.20000, @13.23333 ],
                  @"Africa/Lubumbashi": @[ @"CD", @-10.33333, @27.46667 ], // east Dem. Rep. of Congo
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
                  @"Africa/Tripoli": @[ @"LY", @32.90000, @13.18333 ],
                  @"Africa/Tunis": @[ @"TN", @36.80000, @10.18333 ],
                  @"Africa/Windhoek": @[ @"NA", @-21.43333, @17.10000 ],
                  @"America/Adak": @[ @"US", @51.88000, @-175.34194 ], // Aleutian Islands
                  @"America/Anchorage": @[ @"US", @61.21806, @-148.09972 ], // Alaska Time
                  @"America/Anguilla": @[ @"AI", @18.20000, @-62.93333 ],
                  @"America/Antigua": @[ @"AG", @17.05000, @-60.20000 ],
                  @"America/Araguaina": @[ @"BR", @-6.80000, @-47.80000 ], // Tocantins
                  @"America/Argentina/Buenos_Aires": @[ @"AR", @-33.40000, @-57.55000 ], // Buenos Aires (BA, CF)
                  @"America/Argentina/Catamarca": @[ @"AR", @-27.53333, @-64.21667 ], // Catamarca (CT), Chubut (CH)
                  @"America/Argentina/Cordoba": @[ @"AR", @-30.60000, @-63.81667 ], // most locations (CB, CC, CN, ER, FM, MN, SE, SF)
                  @"America/Argentina/Jujuy": @[ @"AR", @-23.81667, @-64.70000 ], // Jujuy (JY)
                  @"America/Argentina/La_Rioja": @[ @"AR", @-28.56667, @-65.15000 ], // La Rioja (LR)
                  @"America/Argentina/Mendoza": @[ @"AR", @-31.11667, @-67.18333 ], // Mendoza (MZ)
                  @"America/Argentina/Rio_Gallegos": @[ @"AR", @-50.36667, @-68.78333 ], // Santa Cruz (SC)
                  @"America/Argentina/Salta": @[ @"AR", @-23.21667, @-64.58333 ], // (SA, LP, NQ, RN)
                  @"America/Argentina/San_Juan": @[ @"AR", @-30.46667, @-67.48333 ], // San Juan (SJ)
                  @"America/Argentina/San_Luis": @[ @"AR", @-32.68333, @-65.65000 ], // San Luis (SL)
                  @"America/Argentina/Tucuman": @[ @"AR", @-25.18333, @-64.78333 ], // Tucuman (TM)
                  @"America/Argentina/Ushuaia": @[ @"AR", @-53.20000, @-67.70000 ], // Tierra del Fuego (TF)
                  @"America/Aruba": @[ @"AW", @12.50000, @-68.03333 ],
                  @"America/Asuncion": @[ @"PY", @-24.73333, @-56.33333 ],
                  @"America/Atikokan": @[ @"CA", @48.75861, @-90.37833 ], // Eastern Standard Time - Atikokan, Ontario and Southampton I, Nunavut
                  @"America/Bahia": @[ @"BR", @-11.01667, @-37.48333 ], // Bahia
                  @"America/Bahia_Banderas": @[ @"MX", @20.80000, @-104.75000 ], // Mexican Central Time - Bahia de Banderas
                  @"America/Barbados": @[ @"BB", @13.10000, @-58.38333 ],
                  @"America/Belem": @[ @"BR", @-0.55000, @-47.51667 ], // Amapa, E Para
                  @"America/Belize": @[ @"BZ", @17.50000, @-87.80000 ],
                  @"America/Blanc-Sablon": @[ @"CA", @51.41667, @-56.88333 ], // Atlantic Standard Time - Quebec - Lower North Shore
                  @"America/Boa_Vista": @[ @"BR", @2.81667, @-59.33333 ], // Roraima
                  @"America/Bogota": @[ @"CO", @4.60000, @-73.91667 ],
                  @"America/Boise": @[ @"US", @43.61361, @-115.79750 ], // Mountain Time - south Idaho & east Oregon
                  @"America/Cambridge_Bay": @[ @"CA", @69.11389, @-104.94722 ], // Mountain Time - west Nunavut
                  @"America/Campo_Grande": @[ @"BR", @-19.55000, @-53.38333 ], // Mato Grosso do Sul
                  @"America/Cancun": @[ @"MX", @21.08333, @-85.23333 ], // Central Time - Quintana Roo
                  @"America/Caracas": @[ @"VE", @10.50000, @-65.06667 ],
                  @"America/Cayenne": @[ @"GF", @4.93333, @-51.66667 ],
                  @"America/Cayman": @[ @"KY", @19.30000, @-80.61667 ],
                  @"America/Chicago": @[ @"US", @41.85000, @-86.35000 ], // Central Time
                  @"America/Chihuahua": @[ @"MX", @28.63333, @-105.91667 ], // Mexican Mountain Time - Chihuahua away from US border
                  @"America/Costa_Rica": @[ @"CR", @9.93333, @-83.91667 ],
                  @"America/Creston": @[ @"CA", @49.10000, @-115.48333 ], // Mountain Standard Time - Creston, British Columbia
                  @"America/Cuiaba": @[ @"BR", @-14.41667, @-55.91667 ], // Mato Grosso
                  @"America/Curacao": @[ @"CW", @12.18333, @-69.00000 ],
                  @"America/Danmarkshavn": @[ @"GL", @76.76667, @-17.33333 ], // east coast, north of Scoresbysund
                  @"America/Dawson": @[ @"CA", @64.06667, @-138.58333 ], // Pacific Time - north Yukon
                  @"America/Dawson_Creek": @[ @"CA", @59.76667, @-119.76667 ], // Mountain Standard Time - Dawson Creek & Fort Saint John, British Columbia
                  @"America/Denver": @[ @"US", @39.73917, @-103.01583 ], // Mountain Time
                  @"America/Detroit": @[ @"US", @42.33139, @-82.95417 ], // Eastern Time - Michigan - most locations
                  @"America/Dominica": @[ @"DM", @15.30000, @-60.60000 ],
                  @"America/Edmonton": @[ @"CA", @53.55000, @-112.53333 ], // Mountain Time - Alberta, east British Columbia & west Saskatchewan
                  @"America/Eirunepe": @[ @"BR", @-5.33333, @-68.13333 ], // W Amazonas
                  @"America/El_Salvador": @[ @"SV", @13.70000, @-88.80000 ],
                  @"America/Fortaleza": @[ @"BR", @-2.28333, @-37.50000 ], // NE Brazil (MA, PI, CE, RN, PB)
                  @"America/Glace_Bay": @[ @"CA", @46.20000, @-58.05000 ], // Atlantic Time - Nova Scotia - places that did not observe DST 1966-1971
                  @"America/Godthab": @[ @"GL", @64.18333, @-50.26667 ], // most locations
                  @"America/Goose_Bay": @[ @"CA", @53.33333, @-59.58333 ], // Atlantic Time - Labrador - most locations
                  @"America/Grand_Turk": @[ @"TC", @21.46667, @-70.86667 ],
                  @"America/Grenada": @[ @"GD", @12.05000, @-60.25000 ],
                  @"America/Guadeloupe": @[ @"GP", @16.23333, @-60.46667 ],
                  @"America/Guatemala": @[ @"GT", @14.63333, @-89.48333 ],
                  @"America/Guayaquil": @[ @"EC", @-1.83333, @-78.16667 ], // mainland
                  @"America/Guyana": @[ @"GY", @6.80000, @-57.83333 ],
                  @"America/Halifax": @[ @"CA", @44.65000, @-62.40000 ], // Atlantic Time - Nova Scotia (most places), PEI
                  @"America/Havana": @[ @"CU", @23.13333, @-81.63333 ],
                  @"America/Hermosillo": @[ @"MX", @29.06667, @-109.03333 ], // Mountain Standard Time - Sonora
                  @"America/Indiana/Indianapolis": @[ @"US", @39.76833, @-85.84194 ], // Eastern Time - Indiana - most locations
                  @"America/Indiana/Knox": @[ @"US", @41.29583, @-85.37500 ], // Central Time - Indiana - Starke County
                  @"America/Indiana/Marengo": @[ @"US", @38.37556, @-85.65528 ], // Eastern Time - Indiana - Crawford County
                  @"America/Indiana/Petersburg": @[ @"US", @38.49194, @-86.72139 ], // Eastern Time - Indiana - Pike County
                  @"America/Indiana/Tell_City": @[ @"US", @37.95306, @-85.23861 ], // Central Time - Indiana - Perry County
                  @"America/Indiana/Vevay": @[ @"US", @38.74778, @-84.93278 ], // Eastern Time - Indiana - Switzerland County
                  @"America/Indiana/Vincennes": @[ @"US", @38.67722, @-86.47139 ], // Eastern Time - Indiana - Daviess, Dubois, Knox & Martin Counties
                  @"America/Indiana/Winamac": @[ @"US", @41.05139, @-85.39694 ], // Eastern Time - Indiana - Pulaski County
                  @"America/Inuvik": @[ @"CA", @68.34972, @-132.28333 ], // Mountain Time - west Northwest Territories
                  @"America/Iqaluit": @[ @"CA", @63.73333, @-67.53333 ], // Eastern Time - east Nunavut - most locations
                  @"America/Jamaica": @[ @"JM", @17.96806, @-75.20667 ],
                  @"America/Juneau": @[ @"US", @58.30194, @-133.58028 ], // Alaska Time - Alaska panhandle
                  @"America/Kentucky/Louisville": @[ @"US", @38.25417, @-84.24056 ], // Eastern Time - Kentucky - Louisville area
                  @"America/Kentucky/Monticello": @[ @"US", @36.82972, @-83.15083 ], // Eastern Time - Kentucky - Wayne County
                  @"America/Kralendijk": @[ @"BQ", @12.15083, @-67.72333 ],
                  @"America/La_Paz": @[ @"BO", @-15.50000, @-67.85000 ],
                  @"America/Lima": @[ @"PE", @-11.95000, @-76.95000 ],
                  @"America/Los_Angeles": @[ @"US", @34.05222, @-117.75722 ], // Pacific Time
                  @"America/Lower_Princes": @[ @"SX", @18.05139, @-62.95278 ],
                  @"America/Maceio": @[ @"BR", @-8.33333, @-34.28333 ], // Alagoas, Sergipe
                  @"America/Managua": @[ @"NI", @12.15000, @-85.71667 ],
                  @"America/Manaus": @[ @"BR", @-2.86667, @-59.98333 ], // E Amazonas
                  @"America/Marigot": @[ @"MF", @18.06667, @-62.91667 ],
                  @"America/Martinique": @[ @"MQ", @14.60000, @-60.91667 ],
                  @"America/Matamoros": @[ @"MX", @25.83333, @-96.50000 ], // US Central Time - Coahuila, Durango, Nuevo Leon, Tamaulipas near US border
                  @"America/Mazatlan": @[ @"MX", @23.21667, @-105.58333 ], // Mountain Time - S Baja, Nayarit, Sinaloa
                  @"America/Menominee": @[ @"US", @45.10778, @-86.38583 ], // Central Time - Michigan - Dickinson, Gogebic, Iron & Menominee Counties
                  @"America/Merida": @[ @"MX", @20.96667, @-88.38333 ], // Central Time - Campeche, Yucatan
                  @"America/Metlakatla": @[ @"US", @55.12694, @-130.42361 ], // Pacific Standard Time - Annette Island, Alaska
                  @"America/Mexico_City": @[ @"MX", @19.40000, @-98.85000 ], // Central Time - most locations
                  @"America/Miquelon": @[ @"PM", @47.05000, @-55.66667 ],
                  @"America/Moncton": @[ @"CA", @46.10000, @-63.21667 ], // Atlantic Time - New Brunswick
                  @"America/Monterrey": @[ @"MX", @25.66667, @-99.68333 ], // Mexican Central Time - Coahuila, Durango, Nuevo Leon, Tamaulipas away from US border
                  @"America/Montevideo": @[ @"UY", @-33.11667, @-55.81667 ],
                  @"America/Montserrat": @[ @"MS", @16.71667, @-61.78333 ],
                  @"America/Nassau": @[ @"BS", @25.08333, @-76.65000 ],
                  @"America/New_York": @[ @"US", @40.71417, @-73.99361 ], // Eastern Time
                  @"America/Nipigon": @[ @"CA", @49.01667, @-87.73333 ], // Eastern Time - Ontario & Quebec - places that did not observe DST 1967-1973
                  @"America/Nome": @[ @"US", @64.50111, @-164.59361 ], // Alaska Time - west Alaska
                  @"America/Noronha": @[ @"BR", @-2.15000, @-31.58333 ], // Atlantic islands
                  @"America/North_Dakota/Beulah": @[ @"US", @47.26417, @-100.22222 ], // Central Time - North Dakota - Mercer County
                  @"America/North_Dakota/Center": @[ @"US", @47.11639, @-100.70083 ], // Central Time - North Dakota - Oliver County
                  @"America/North_Dakota/New_Salem": @[ @"US", @46.84500, @-100.58917 ], // Central Time - North Dakota - Morton County (except Mandan area)
                  @"America/Ojinaga": @[ @"MX", @29.56667, @-103.58333 ], // US Mountain Time - Chihuahua near US border
                  @"America/Panama": @[ @"PA", @8.96667, @-78.46667 ],
                  @"America/Pangnirtung": @[ @"CA", @66.13333, @-64.26667 ], // Eastern Time - Pangnirtung, Nunavut
                  @"America/Paramaribo": @[ @"SR", @5.83333, @-54.83333 ],
                  @"America/Phoenix": @[ @"US", @33.44833, @-111.92667 ], // Mountain Standard Time - Arizona (except Navajo)
                  @"America/Port-au-Prince": @[ @"HT", @18.53333, @-71.66667 ],
                  @"America/Port_of_Spain": @[ @"TT", @10.65000, @-60.48333 ],
                  @"America/Porto_Velho": @[ @"BR", @-7.23333, @-62.10000 ], // Rondonia
                  @"America/Puerto_Rico": @[ @"PR", @18.46833, @-65.89389 ],
                  @"America/Rainy_River": @[ @"CA", @48.71667, @-93.43333 ], // Central Time - Rainy River & Fort Frances, Ontario
                  @"America/Rankin_Inlet": @[ @"CA", @62.81667, @-91.91694 ], // Central Time - central Nunavut
                  @"America/Recife": @[ @"BR", @-7.95000, @-33.10000 ], // Pernambuco
                  @"America/Regina": @[ @"CA", @50.40000, @-103.35000 ], // Central Standard Time - Saskatchewan - most locations
                  @"America/Resolute": @[ @"CA", @74.69556, @-93.17083 ], // Central Time - Resolute, Nunavut
                  @"America/Rio_Branco": @[ @"BR", @-8.03333, @-66.20000 ], // Acre
                  @"America/Santa_Isabel": @[ @"MX", @30.30000, @-113.13333 ], // Mexican Pacific Time - Baja California away from US border
                  @"America/Santarem": @[ @"BR", @-1.56667, @-53.13333 ], // W Para
                  @"America/Santiago": @[ @"CL", @-32.55000, @-69.33333 ], // most locations
                  @"America/Santo_Domingo": @[ @"DO", @18.46667, @-68.10000 ],
                  @"America/Sao_Paulo": @[ @"BR", @-22.46667, @-45.38333 ], // S & SE Brazil (GO, DF, MG, ES, RJ, SP, PR, SC, RS)
                  @"America/Scoresbysund": @[ @"GL", @70.48333, @-20.03333 ], // Scoresbysund / Ittoqqortoormiit
                  @"America/Sitka": @[ @"US", @57.17639, @-134.69806 ], // Alaska Time - southeast Alaska panhandle
                  @"America/St_Barthelemy": @[ @"BL", @17.88333, @-61.15000 ],
                  @"America/St_Johns": @[ @"CA", @47.56667, @-51.28333 ], // Newfoundland Time, including SE Labrador
                  @"America/St_Kitts": @[ @"KN", @17.30000, @-61.28333 ],
                  @"America/St_Lucia": @[ @"LC", @14.01667, @-61.00000 ],
                  @"America/St_Thomas": @[ @"VI", @18.35000, @-63.06667 ],
                  @"America/St_Vincent": @[ @"VC", @13.15000, @-60.76667 ],
                  @"America/Swift_Current": @[ @"CA", @50.28333, @-106.16667 ], // Central Standard Time - Saskatchewan - midwest
                  @"America/Tegucigalpa": @[ @"HN", @14.10000, @-86.78333 ],
                  @"America/Thule": @[ @"GL", @76.56667, @-67.21667 ], // Thule / Pituffik
                  @"America/Thunder_Bay": @[ @"CA", @48.38333, @-88.75000 ], // Eastern Time - Thunder Bay, Ontario
                  @"America/Tijuana": @[ @"MX", @32.53333, @-116.98333 ], // US Pacific Time - Baja California near US border
                  @"America/Toronto": @[ @"CA", @43.65000, @-78.61667 ], // Eastern Time - Ontario & Quebec - most locations
                  @"America/Tortola": @[ @"VG", @18.45000, @-63.38333 ],
                  @"America/Vancouver": @[ @"CA", @49.26667, @-122.88333 ], // Pacific Time - west British Columbia
                  @"America/Whitehorse": @[ @"CA", @60.71667, @-134.95000 ], // Pacific Time - south Yukon
                  @"America/Winnipeg": @[ @"CA", @49.88333, @-96.85000 ], // Central Time - Manitoba & west Ontario
                  @"America/Yakutat": @[ @"US", @59.54694, @-138.27278 ], // Alaska Time - Alaska panhandle neck
                  @"America/Yellowknife": @[ @"CA", @62.45000, @-113.65000 ], // Mountain Time - central Northwest Territories
                  @"Antarctica/Casey": @[ @"AQ", @-65.71667, @110.51667 ], // Casey Station, Bailey Peninsula
                  @"Antarctica/Davis": @[ @"AQ", @-67.41667, @77.96667 ], // Davis Station, Vestfold Hills
                  @"Antarctica/DumontDUrville": @[ @"AQ", @-65.33333, @140.01667 ], // Dumont-d'Urville Station, Adelie Land
                  @"Antarctica/Macquarie": @[ @"AU", @-53.50000, @158.95000 ], // Macquarie Island
                  @"Antarctica/Mawson": @[ @"AQ", @-66.40000, @62.88333 ], // Mawson Station, Holme Bay
                  @"Antarctica/McMurdo": @[ @"AQ", @-76.16667, @166.60000 ], // McMurdo, South Pole, Scott (New Zealand time)
                  @"Antarctica/Palmer": @[ @"AQ", @-63.20000, @-63.90000 ], // Palmer Station, Anvers Island
                  @"Antarctica/Rothera": @[ @"AQ", @-66.43333, @-67.86667 ], // Rothera Station, Adelaide Island
                  @"Antarctica/Syowa": @[ @"AQ", @-68.99389, @39.59000 ], // Syowa Station, E Ongul I
                  @"Antarctica/Troll": @[ @"AQ", @-71.98861, @2.53500 ], // Troll Station, Queen Maud Land
                  @"Antarctica/Vostok": @[ @"AQ", @-77.60000, @106.90000 ], // Vostok Station, Lake Vostok
                  @"Arctic/Longyearbyen": @[ @"SJ", @78.00000, @16.00000 ],
                  @"Asia/Aden": @[ @"YE", @12.75000, @45.20000 ],
                  @"Asia/Almaty": @[ @"KZ", @43.25000, @76.95000 ], // most locations
                  @"Asia/Amman": @[ @"JO", @31.95000, @35.93333 ],
                  @"Asia/Anadyr": @[ @"RU", @64.75000, @177.48333 ], // Moscow+08 (Moscow+09 after 2014-10-26) - Bering Sea
                  @"Asia/Aqtau": @[ @"KZ", @44.51667, @50.26667 ], // Atyrau (Atirau, Gur'yev), Mangghystau (Mankistau)
                  @"Asia/Aqtobe": @[ @"KZ", @50.28333, @57.16667 ], // Aqtobe (Aktobe)
                  @"Asia/Ashgabat": @[ @"TM", @37.95000, @58.38333 ],
                  @"Asia/Baghdad": @[ @"IQ", @33.35000, @44.41667 ],
                  @"Asia/Bahrain": @[ @"BH", @26.38333, @50.58333 ],
                  @"Asia/Baku": @[ @"AZ", @40.38333, @49.85000 ],
                  @"Asia/Bangkok": @[ @"TH", @13.75000, @100.51667 ],
                  @"Asia/Beirut": @[ @"LB", @33.88333, @35.50000 ],
                  @"Asia/Bishkek": @[ @"KG", @42.90000, @74.60000 ],
                  @"Asia/Brunei": @[ @"BN", @4.93333, @114.91667 ],
                  @"Asia/Chita": @[ @"RU", @52.05000, @113.46667 ], // Moscow+06 (Moscow+05 after 2014-10-26) - Zabaykalsky
                  @"Asia/Choibalsan": @[ @"MN", @48.06667, @114.50000 ], // Dornod, Sukhbaatar
                  @"Asia/Colombo": @[ @"LK", @6.93333, @79.85000 ],
                  @"Asia/Damascus": @[ @"SY", @33.50000, @36.30000 ],
                  @"Asia/Dhaka": @[ @"BD", @23.71667, @90.41667 ],
                  @"Asia/Dili": @[ @"TL", @-7.45000, @125.58333 ],
                  @"Asia/Dubai": @[ @"AE", @25.30000, @55.30000 ],
                  @"Asia/Dushanbe": @[ @"TJ", @38.58333, @68.80000 ],
                  @"Asia/Gaza": @[ @"PS", @31.50000, @34.46667 ], // Gaza Strip
                  @"Asia/Hebron": @[ @"PS", @31.53333, @35.09500 ], // West Bank
                  @"Asia/Ho_Chi_Minh": @[ @"VN", @10.75000, @106.66667 ],
                  @"Asia/Hong_Kong": @[ @"HK", @22.28333, @114.15000 ],
                  @"Asia/Hovd": @[ @"MN", @48.01667, @91.65000 ], // Bayan-Olgiy, Govi-Altai, Hovd, Uvs, Zavkhan
                  @"Asia/Irkutsk": @[ @"RU", @52.26667, @104.33333 ], // Moscow+05 - Lake Baikal
                  @"Asia/Jakarta": @[ @"ID", @-5.83333, @106.80000 ], // Java & Sumatra
                  @"Asia/Jayapura": @[ @"ID", @-1.46667, @140.70000 ], // west New Guinea (Irian Jaya) & Malukus (Moluccas)
                  @"Asia/Jerusalem": @[ @"IL", @31.78056, @35.22389 ],
                  @"Asia/Kabul": @[ @"AF", @34.51667, @69.20000 ],
                  @"Asia/Kamchatka": @[ @"RU", @53.01667, @158.65000 ], // Moscow+08 (Moscow+09 after 2014-10-26) - Kamchatka
                  @"Asia/Karachi": @[ @"PK", @24.86667, @67.05000 ],
                  @"Asia/Kathmandu": @[ @"NP", @27.71667, @85.31667 ],
                  @"Asia/Khandyga": @[ @"RU", @62.65639, @135.55389 ], // Moscow+06 - Tomponsky, Ust-Maysky
                  @"Asia/Kolkata": @[ @"IN", @22.53333, @88.36667 ],
                  @"Asia/Krasnoyarsk": @[ @"RU", @56.01667, @92.83333 ], // Moscow+04 - Yenisei River
                  @"Asia/Kuala_Lumpur": @[ @"MY", @3.16667, @101.70000 ], // peninsular Malaysia
                  @"Asia/Kuching": @[ @"MY", @1.55000, @110.33333 ], // Sabah & Sarawak
                  @"Asia/Kuwait": @[ @"KW", @29.33333, @47.98333 ],
                  @"Asia/Macau": @[ @"MO", @22.23333, @113.58333 ],
                  @"Asia/Magadan": @[ @"RU", @59.56667, @150.80000 ], // Moscow+08 (Moscow+07 after 2014-10-26) - Magadan
                  @"Asia/Makassar": @[ @"ID", @-4.88333, @119.40000 ], // east & south Borneo, Sulawesi (Celebes), Bali, Nusa Tengarra, west Timor
                  @"Asia/Manila": @[ @"PH", @14.58333, @121.00000 ],
                  @"Asia/Muscat": @[ @"OM", @23.60000, @58.58333 ],
                  @"Asia/Nicosia": @[ @"CY", @35.16667, @33.36667 ],
                  @"Asia/Novokuznetsk": @[ @"RU", @53.75000, @87.11667 ], // Moscow+03 (Moscow+04 after 2014-10-26) - Kemerovo
                  @"Asia/Novosibirsk": @[ @"RU", @55.03333, @82.91667 ], // Moscow+03 - Novosibirsk
                  @"Asia/Omsk": @[ @"RU", @55.00000, @73.40000 ], // Moscow+03 - west Siberia
                  @"Asia/Oral": @[ @"KZ", @51.21667, @51.35000 ], // West Kazakhstan
                  @"Asia/Phnom_Penh": @[ @"KH", @11.55000, @104.91667 ],
                  @"Asia/Pontianak": @[ @"ID", @0.03333, @109.33333 ], // west & central Borneo
                  @"Asia/Pyongyang": @[ @"KP", @39.01667, @125.75000 ],
                  @"Asia/Qatar": @[ @"QA", @25.28333, @51.53333 ],
                  @"Asia/Qyzylorda": @[ @"KZ", @44.80000, @65.46667 ], // Qyzylorda (Kyzylorda, Kzyl-Orda)
                  @"Asia/Rangoon": @[ @"MM", @16.78333, @96.16667 ],
                  @"Asia/Riyadh": @[ @"SA", @24.63333, @46.71667 ],
                  @"Asia/Sakhalin": @[ @"RU", @46.96667, @142.70000 ], // Moscow+07 - Sakhalin Island
                  @"Asia/Samarkand": @[ @"UZ", @39.66667, @66.80000 ], // west Uzbekistan
                  @"Asia/Seoul": @[ @"KR", @37.55000, @126.96667 ],
                  @"Asia/Shanghai": @[ @"CN", @31.23333, @121.46667 ], // Beijing Time
                  @"Asia/Singapore": @[ @"SG", @1.28333, @103.85000 ],
                  @"Asia/Srednekolymsk": @[ @"RU", @67.46667, @153.71667 ], // Moscow+08 - E Sakha, N Kuril Is
                  @"Asia/Taipei": @[ @"TW", @25.05000, @121.50000 ],
                  @"Asia/Tashkent": @[ @"UZ", @41.33333, @69.30000 ], // east Uzbekistan
                  @"Asia/Tbilisi": @[ @"GE", @41.71667, @44.81667 ],
                  @"Asia/Tehran": @[ @"IR", @35.66667, @51.43333 ],
                  @"Asia/Thimphu": @[ @"BT", @27.46667, @89.65000 ],
                  @"Asia/Tokyo": @[ @"JP", @35.65444, @139.74472 ],
                  @"Asia/Ulaanbaatar": @[ @"MN", @47.91667, @106.88333 ], // most locations
                  @"Asia/Urumqi": @[ @"CN", @43.80000, @87.58333 ], // Xinjiang Time
                  @"Asia/Ust-Nera": @[ @"RU", @64.56028, @143.22667 ], // Moscow+07 - Oymyakonsky
                  @"Asia/Vientiane": @[ @"LA", @17.96667, @102.60000 ],
                  @"Asia/Vladivostok": @[ @"RU", @43.16667, @131.93333 ], // Moscow+07 - Amur River
                  @"Asia/Yakutsk": @[ @"RU", @62.00000, @129.66667 ], // Moscow+06 - Lena River
                  @"Asia/Yekaterinburg": @[ @"RU", @56.85000, @60.60000 ], // Moscow+02 - Urals
                  @"Asia/Yerevan": @[ @"AM", @40.18333, @44.50000 ],
                  @"Atlantic/Azores": @[ @"PT", @37.73333, @-24.33333 ], // Azores
                  @"Atlantic/Bermuda": @[ @"BM", @32.28333, @-63.23333 ],
                  @"Atlantic/Canary": @[ @"ES", @28.10000, @-14.60000 ], // Canary Islands
                  @"Atlantic/Cape_Verde": @[ @"CV", @14.91667, @-22.48333 ],
                  @"Atlantic/Faroe": @[ @"FO", @62.01667, @-5.23333 ],
                  @"Atlantic/Madeira": @[ @"PT", @32.63333, @-15.10000 ], // Madeira Islands
                  @"Atlantic/Reykjavik": @[ @"IS", @64.15000, @-20.15000 ],
                  @"Atlantic/South_Georgia": @[ @"GS", @-53.73333, @-35.46667 ],
                  @"Atlantic/St_Helena": @[ @"SH", @-14.08333, @-4.30000 ],
                  @"Atlantic/Stanley": @[ @"FK", @-50.30000, @-56.15000 ],
                  @"Australia/Adelaide": @[ @"AU", @-33.08333, @138.58333 ], // South Australia
                  @"Australia/Brisbane": @[ @"AU", @-26.53333, @153.03333 ], // Queensland - most locations
                  @"Australia/Broken_Hill": @[ @"AU", @-30.05000, @141.45000 ], // New South Wales - Yancowinna
                  @"Australia/Currie": @[ @"AU", @-38.06667, @143.86667 ], // Tasmania - King Island
                  @"Australia/Darwin": @[ @"AU", @-11.53333, @130.83333 ], // Northern Territory
                  @"Australia/Eucla": @[ @"AU", @-30.28333, @128.86667 ], // Western Australia - Eucla area
                  @"Australia/Hobart": @[ @"AU", @-41.11667, @147.31667 ], // Tasmania - most locations
                  @"Australia/Lindeman": @[ @"AU", @-19.73333, @149.00000 ], // Queensland - Holiday Islands
                  @"Australia/Lord_Howe": @[ @"AU", @-30.45000, @159.08333 ], // Lord Howe Island
                  @"Australia/Melbourne": @[ @"AU", @-36.18333, @144.96667 ], // Victoria
                  @"Australia/Perth": @[ @"AU", @-30.05000, @115.85000 ], // Western Australia - most locations
                  @"Australia/Sydney": @[ @"AU", @-32.13333, @151.21667 ], // New South Wales - most locations
                  @"Europe/Amsterdam": @[ @"NL", @52.36667, @4.90000 ],
                  @"Europe/Andorra": @[ @"AD", @42.50000, @1.51667 ],
                  @"Europe/Athens": @[ @"GR", @37.96667, @23.71667 ],
                  @"Europe/Belgrade": @[ @"RS", @44.83333, @20.50000 ],
                  @"Europe/Berlin": @[ @"DE", @52.50000, @13.36667 ], // most locations
                  @"Europe/Bratislava": @[ @"SK", @48.15000, @17.11667 ],
                  @"Europe/Brussels": @[ @"BE", @50.83333, @4.33333 ],
                  @"Europe/Bucharest": @[ @"RO", @44.43333, @26.10000 ],
                  @"Europe/Budapest": @[ @"HU", @47.50000, @19.08333 ],
                  @"Europe/Busingen": @[ @"DE", @47.70000, @8.68333 ], // Busingen
                  @"Europe/Chisinau": @[ @"MD", @47.00000, @28.83333 ],
                  @"Europe/Copenhagen": @[ @"DK", @55.66667, @12.58333 ],
                  @"Europe/Dublin": @[ @"IE", @53.33333, @-5.75000 ],
                  @"Europe/Gibraltar": @[ @"GI", @36.13333, @-4.65000 ],
                  @"Europe/Guernsey": @[ @"GG", @49.45000, @-1.46667 ],
                  @"Europe/Helsinki": @[ @"FI", @60.16667, @24.96667 ],
                  @"Europe/Isle_of_Man": @[ @"IM", @54.15000, @-3.53333 ],
                  @"Europe/Istanbul": @[ @"TR", @41.01667, @28.96667 ],
                  @"Europe/Jersey": @[ @"JE", @49.20000, @-1.88333 ],
                  @"Europe/Kaliningrad": @[ @"RU", @54.71667, @20.50000 ], // Moscow-01 - Kaliningrad
                  @"Europe/Kiev": @[ @"UA", @50.43333, @30.51667 ], // most locations
                  @"Europe/Lisbon": @[ @"PT", @38.71667, @-8.86667 ], // mainland
                  @"Europe/Ljubljana": @[ @"SI", @46.05000, @14.51667 ],
                  @"Europe/London": @[ @"GB", @51.50833, @0.12528 ],
                  @"Europe/Luxembourg": @[ @"LU", @49.60000, @6.15000 ],
                  @"Europe/Madrid": @[ @"ES", @40.40000, @-2.31667 ], // mainland
                  @"Europe/Malta": @[ @"MT", @35.90000, @14.51667 ],
                  @"Europe/Mariehamn": @[ @"AX", @60.10000, @19.95000 ],
                  @"Europe/Minsk": @[ @"BY", @53.90000, @27.56667 ],
                  @"Europe/Monaco": @[ @"MC", @43.70000, @7.38333 ],
                  @"Europe/Moscow": @[ @"RU", @55.75583, @37.61778 ], // Moscow+00 - west Russia
                  @"Europe/Oslo": @[ @"NO", @59.91667, @10.75000 ],
                  @"Europe/Paris": @[ @"FR", @48.86667, @2.33333 ],
                  @"Europe/Podgorica": @[ @"ME", @42.43333, @19.26667 ],
                  @"Europe/Prague": @[ @"CZ", @50.08333, @14.43333 ],
                  @"Europe/Riga": @[ @"LV", @56.95000, @24.10000 ],
                  @"Europe/Rome": @[ @"IT", @41.90000, @12.48333 ],
                  @"Europe/Samara": @[ @"RU", @53.20000, @50.15000 ], // Moscow+00 (Moscow+01 after 2014-10-26) - Samara, Udmurtia
                  @"Europe/San_Marino": @[ @"SM", @43.91667, @12.46667 ],
                  @"Europe/Sarajevo": @[ @"BA", @43.86667, @18.41667 ],
                  @"Europe/Simferopol": @[ @"RU", @44.95000, @34.10000 ], // Moscow+00 - Crimea
                  @"Europe/Skopje": @[ @"MK", @41.98333, @21.43333 ],
                  @"Europe/Sofia": @[ @"BG", @42.68333, @23.31667 ],
                  @"Europe/Stockholm": @[ @"SE", @59.33333, @18.05000 ],
                  @"Europe/Tallinn": @[ @"EE", @59.41667, @24.75000 ],
                  @"Europe/Tirane": @[ @"AL", @41.33333, @19.83333 ],
                  @"Europe/Uzhgorod": @[ @"UA", @48.61667, @22.30000 ], // Ruthenia
                  @"Europe/Vaduz": @[ @"LI", @47.15000, @9.51667 ],
                  @"Europe/Vatican": @[ @"VA", @41.90222, @12.45306 ],
                  @"Europe/Vienna": @[ @"AT", @48.21667, @16.33333 ],
                  @"Europe/Vilnius": @[ @"LT", @54.68333, @25.31667 ],
                  @"Europe/Volgograd": @[ @"RU", @48.73333, @44.41667 ], // Moscow+00 - Caspian Sea
                  @"Europe/Warsaw": @[ @"PL", @52.25000, @21.00000 ],
                  @"Europe/Zagreb": @[ @"HR", @45.80000, @15.96667 ],
                  @"Europe/Zaporozhye": @[ @"UA", @47.83333, @35.16667 ], // Zaporozh'ye, E Lugansk / Zaporizhia, E Luhansk
                  @"Europe/Zurich": @[ @"CH", @47.38333, @8.53333 ],
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
                  @"Pacific/Apia": @[ @"WS", @-12.16667, @-170.26667 ],
                  @"Pacific/Auckland": @[ @"NZ", @-35.13333, @174.76667 ], // most locations
                  @"Pacific/Bougainville": @[ @"PG", @-5.78333, @155.56667 ], // Bougainville
                  @"Pacific/Chatham": @[ @"NZ", @-42.05000, @-175.45000 ], // Chatham Islands
                  @"Pacific/Chuuk": @[ @"FM", @7.41667, @151.78333 ], // Chuuk (Truk) and Yap
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
                  @"Pacific/Johnston": @[ @"UM", @16.75000, @-168.48333 ], // Johnston Atoll
                  @"Pacific/Kiritimati": @[ @"KI", @1.86667, @-156.66667 ], // Line Islands
                  @"Pacific/Kosrae": @[ @"FM", @5.31667, @162.98333 ], // Kosrae
                  @"Pacific/Kwajalein": @[ @"MH", @9.08333, @167.33333 ], // Kwajalein
                  @"Pacific/Majuro": @[ @"MH", @7.15000, @171.20000 ], // most locations
                  @"Pacific/Marquesas": @[ @"PF", @-9.00000, @-138.50000 ], // Marquesas Islands
                  @"Pacific/Midway": @[ @"UM", @28.21667, @-176.63333 ], // Midway Islands
                  @"Pacific/Nauru": @[ @"NR", @0.51667, @166.91667 ],
                  @"Pacific/Niue": @[ @"NU", @-18.98333, @-168.08333 ],
                  @"Pacific/Norfolk": @[ @"NF", @-28.95000, @167.96667 ],
                  @"Pacific/Noumea": @[ @"NC", @-21.73333, @166.45000 ],
                  @"Pacific/Pago_Pago": @[ @"AS", @-13.73333, @-169.30000 ],
                  @"Pacific/Palau": @[ @"PW", @7.33333, @134.48333 ],
                  @"Pacific/Pitcairn": @[ @"PN", @-24.93333, @-129.91667 ],
                  @"Pacific/Pohnpei": @[ @"FM", @6.96667, @158.21667 ], // Pohnpei (Ponape)
                  @"Pacific/Port_Moresby": @[ @"PG", @-8.50000, @147.16667 ], // most locations
                  @"Pacific/Rarotonga": @[ @"CK", @-20.76667, @-158.23333 ],
                  @"Pacific/Saipan": @[ @"MP", @15.20000, @145.75000 ],
                  @"Pacific/Tahiti": @[ @"PF", @-16.46667, @-148.43333 ], // Society Islands
                  @"Pacific/Tarawa": @[ @"KI", @1.41667, @173.00000 ], // Gilbert Islands
                  @"Pacific/Tongatapu": @[ @"TO", @-20.83333, @-174.83333 ],
                  @"Pacific/Wake": @[ @"UM", @19.28333, @166.61667 ], // Wake Island
                  @"Pacific/Wallis": @[ @"WF", @-12.70000, @-175.83333 ],
                  };
    });
    return codes;
}


@end

