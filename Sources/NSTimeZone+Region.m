//
//  NSTimeZone+Region.m
//  Where
//
//  Created by Martin Kiss on 22.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

#import "NSTimeZone+Region.h"


@implementation NSTimeZone (Country)

- (NSString *)regionCode {
    NSString *keypath = [[self.name componentsSeparatedByString:@"/"] componentsJoinedByString:@"."];
    return [[self.class regionCodes] valueForKeyPath:keypath];
}

+ (NSDictionary *)regionCodes {
    static NSDictionary *codes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        codes = @{
                  @"Africa": [self africaRegionCodes],
                  @"America": [self americaRegionCodes],
                  @"Antarctica": [self antarcticaRegionCodes],
                  @"Arctic": [self arcticRegionCodes],
                  @"Asia": [self asiaRegionCodes],
                  @"Atlantic": [self atlanticRegionCodes],
                  @"Australia": [self australiaRegionCodes],
                  @"Europe": [self europeRegionCodes],
                  @"Indian": [self indianRegionCodes],
                  @"Pacific": [self pacificRegionCodes],
                  };
    });
    return codes;
}

+ (NSDictionary *)africaRegionCodes {
    // Prefixed with “Africa/”
    return @{
             @"Abidjan": @"CI",
             @"Accra": @"GH",
             @"Addis_Ababa": @"ET",
             @"Algiers": @"DZ",
             @"Asmara": @"ER",
             @"Bamako": @"ML",
             @"Bangui": @"CF",
             @"Banjul": @"GM",
             @"Bissau": @"GW",
             @"Blantyre": @"MW",
             @"Brazzaville": @"CG",
             @"Bujumbura": @"BI",
             @"Cairo": @"EG",
             @"Casablanca": @"MA",
             @"Ceuta": @"ES", // Spain
             @"Conakry": @"GN",
             @"Dakar": @"SN",
             @"Dar_es_Salaam": @"TZ",
             @"Djibouti": @"DJ",
             @"Douala": @"CM",
             @"El_Aaiun": @"EH",
             @"Freetown": @"SL",
             @"Gaborone": @"BW",
             @"Harare": @"ZW",
             @"Johannesburg": @"ZA",
             @"Juba": @"SS",
             @"Kampala": @"UG",
             @"Khartoum": @"SD",
             @"Kigali": @"RW",
             @"Kinshasa": @"CD", // West
             @"Lagos": @"NG",
             @"Libreville": @"GA",
             @"Lome": @"TG",
             @"Luanda": @"AO",
             @"Lubumbashi": @"CD", // East
             @"Lusaka": @"ZM",
             @"Malabo": @"GQ",
             @"Maputo": @"MZ",
             @"Maseru": @"LS",
             @"Mbabane": @"SZ",
             @"Mogadishu": @"SO",
             @"Monrovia": @"LR",
             @"Nairobi": @"KE",
             @"Ndjamena": @"TD",
             @"Niamey": @"NE",
             @"Nouakchott": @"MR",
             @"Ouagadougou": @"BF",
             @"Porto-Novo": @"BJ",
             @"Sao_Tome": @"ST",
             @"Tripoli": @"LY",
             @"Tunis": @"TN",
             @"Windhoek": @"NA",
             };
}

+ (NSDictionary *)americaRegionCodes {
    // Preficed with “America/”
    return @{
             @"Adak": @"US",
             @"Anchorage": @"US", // Alaska Time
             @"Anguilla": @"AI",
             @"Antigua": @"AG",
             @"Araguaina": @"BR",
             @"Argentina": @{
                     @"Buenos_Aires": @"AR",
                     @"Catamarca": @"AR",
                     @"Cordoba": @"AR",
                     @"Jujuy": @"AR",
                     @"La_Rioja": @"AR",
                     @"Mendoza": @"AR",
                     @"Rio_Gallegos": @"AR",
                     @"Salta": @"AR",
                     @"San_Juan": @"AR",
                     @"San_Luis": @"AR",
                     @"Tucuman": @"AR",
                     @"Ushuaia": @"AR",
                     },
             @"Aruba": @"AW",
             @"Asuncion": @"PY",
             @"Atikokan": @"CA", // Eastern Standard Time
             @"Bahia": @"BR",
             @"Bahia_Banderas": @"MX", // Mexican Central Time
             @"Barbados": @"BB",
             @"Belem": @"BR",
             @"Belize": @"BZ",
             @"Blanc-Sablon": @"CA", // Atlantic Standard Time
             @"Boa_Vista": @"BR",
             @"Bogota": @"CO",
             @"Boise": @"US", // Mountain Time
             @"Cambridge_Bay": @"CA", // Mountain Time
             @"Campo_Grande": @"BR",
             @"Cancun": @"MX", // Central Time
             @"Caracas": @"VE",
             @"Cayenne": @"GF",
             @"Cayman": @"KY",
             @"Chicago": @"US", // Central Time
             @"Chihuahua": @"MX", // Mexican Mountain Time
             @"Costa_Rica": @"CR",
             @"Creston": @"CA", // Mountain Standard Time
             @"Cuiaba": @"BR",
             @"Curacao": @"CW",
             @"Danmarkshavn": @"GL",
             @"Dawson": @"CA", // Pacific Time
             @"Dawson_Creek": @"CA", // Mountain Standard Time
             @"Denver": @"US", // Mountain Time
             @"Detroit": @"US", // Eastern Time
             @"Dominica": @"DM",
             @"Edmonton": @"CA", // Mountain Time
             @"Eirunepe": @"BR",
             @"El_Salvador": @"SV",
             @"Fortaleza": @"BR",
             @"Glace_Bay": @"CA", // Atlantic Time
             @"Godthab": @"GL",
             @"Goose_Bay": @"CA", // Atlantic Time
             @"Grand_Turk": @"TC",
             @"Grenada": @"GD",
             @"Guadeloupe": @"GP",
             @"Guatemala": @"GT",
             @"Guayaquil": @"EC",
             @"Guyana": @"GY",
             @"Halifax": @"CA", // Atlantic Time
             @"Havana": @"CU",
             @"Hermosillo": @"MX", // Mountain Standard Time
             @"Indiana": @{
                     @"Indianapolis": @"US", // Eastern Time
                     @"Knox": @"US", // Central Time
                     @"Marengo": @"US", // Eastern Time
                     @"Petersburg": @"US", // Eastern Time
                     @"Tell_City": @"US", // Central Time
                     @"Vevay": @"US", // Eastern Time
                     @"Vincennes": @"US", // Eastern Time
                     @"Winamac": @"US", // Eastern Time
                     },
             @"Inuvik": @"CA", // Mountain Time
             @"Iqaluit": @"CA", // Eastern Time
             @"Jamaica": @"JM",
             @"Juneau": @"US", // Alaska Time
             @"Kentucky": @{
                     @"Louisville": @"US", // Eastern Time
                     @"Monticello": @"US", // Eastern Time
                     },
             @"Kralendijk": @"BQ",
             @"La_Paz": @"BO",
             @"Lima": @"PE",
             @"Los_Angeles": @"US", // Pacific Time
             @"Lower_Princes": @"SX",
             @"Maceio": @"BR",
             @"Managua": @"NI",
             @"Manaus": @"BR",
             @"Marigot": @"MF",
             @"Martinique": @"MQ",
             @"Matamoros": @"MX", // US Central Time
             @"Mazatlan": @"MX", // Mountain Time
             @"Menominee": @"US", // Central Time
             @"Merida": @"MX", // Central Time
             @"Metlakatla": @"US", // Metlakatla Time
             @"Mexico_City": @"MX", // Central Time
             @"Miquelon": @"PM",
             @"Moncton": @"CA", // Atlantic Time
             @"Monterrey": @"MX", // Mexican Central Time
             @"Montevideo": @"UY",
             @"Montserrat": @"MS",
             @"Nassau": @"BS",
             @"New_York": @"US", // Eastern Time
             @"Nipigon": @"CA", // Eastern Time
             @"Nome": @"US", // Alaska Time
             @"Noronha": @"BR",
             @"North_Dakota": @{
                     @"Beulah": @"US", // Central Time
                     @"Center": @"US", // Central Time
                     @"New_Salem": @"US", // Central Time
                     },
             @"Ojinaga": @"MX", // US Mountain Time
             @"Panama": @"PA",
             @"Pangnirtung": @"CA", // Eastern Time
             @"Paramaribo": @"SR",
             @"Phoenix": @"US", // Mountain Standard Time
             @"Port_of_Spain": @"TT",
             @"Port-au-Prince": @"HT",
             @"Porto_Velho": @"BR",
             @"Puerto_Rico": @"PR",
             @"Rainy_River": @"CA", // Central Time
             @"Rankin_Inlet": @"CA", // Central Time
             @"Recife": @"BR",
             @"Regina": @"CA", // Central Standard Time
             @"Resolute": @"CA", // Central Standard Time
             @"Rio_Branco": @"BR",
             @"Santa_Isabel": @"MX", // Mexican Pacific Time
             @"Santarem": @"BR",
             @"Santiago": @"CL",
             @"Santo_Domingo": @"DO",
             @"Sao_Paulo": @"BR",
             @"Scoresbysund": @"GL",
             @"Sitka": @"US", // Alaska Time
             @"St_Barthelemy": @"BL",
             @"St_Johns": @"CA", // Newfoundland Time
             @"St_Kitts": @"KN",
             @"St_Lucia": @"LC",
             @"St_Thomas": @"VI",
             @"St_Vincent": @"VC",
             @"Swift_Current": @"CA", // Central Standard Time
             @"Tegucigalpa": @"HN",
             @"Thule": @"GL",
             @"Thunder_Bay": @"CA", // Eastern Time
             @"Tijuana": @"MX", // US Pacific Time
             @"Toronto": @"CA",
             @"Tortola": @"VG",
             @"Vancouver": @"CA", // Pacific Time
             @"Whitehorse": @"CA", // Pacific Time
             @"Winnipeg": @"CA", // Central Time
             @"Yakutat": @"US", // Alaska Time
             @"Yellowknife": @"CA", // Mountain Time
             };
}

+ (NSDictionary *)antarcticaRegionCodes {
    // Prefixed with “Antarctica/”
    return @{
             @"Casey": @"AQ",
             @"Davis": @"AQ",
             @"DumontDUrville": @"AQ",
             @"Macquarie": @"AU", // Australia
             @"Mawson": @"AQ",
             @"McMurdo": @"AQ",
             @"Palmer": @"AQ",
             @"Rothera": @"AQ",
             @"Syowa": @"AQ",
             @"Vostok": @"AQ",
             
             };
}

+ (NSDictionary *)arcticRegionCodes {
    // Prefixed with “Arctic/”
    return @{
             @"Longyearbyen": @"SJ",
             };
}

+ (NSDictionary *)asiaRegionCodes {
    // Prefixed with “Asia/”
    return @{
             @"Aden": @"YE",
             @"Almaty": @"KZ",
             @"Amman": @"JO",
             @"Anadyr": @"RU", // Moscow+08
             @"Aqtau": @"KZ",
             @"Aqtobe": @"KZ",
             @"Ashgabat": @"TM",
             @"Baghdad": @"IQ",
             @"Bahrain": @"BH",
             @"Baku": @"AZ",
             @"Bangkok": @"TH",
             @"Beirut": @"LB",
             @"Bishkek": @"KG",
             @"Brunei": @"BN",
             @"Choibalsan": @"MN",
             @"Chongqing": @"CN",
             @"Colombo": @"LK",
             @"Damascus": @"SY",
             @"Dhaka": @"BD",
             @"Dili": @"TL",
             @"Dubai": @"AE",
             @"Dushanbe": @"TJ",
             @"Gaza": @"PS",
             @"Harbin": @"CN",
             @"Hebron": @"PS",
             @"Ho_Chi_Minh": @"VN",
             @"Hong_Kong": @"HK",
             @"Hovd": @"MN",
             @"Irkutsk": @"RU", // Moscow+05
             @"Jakarta": @"ID",
             @"Jayapura": @"ID",
             @"Jerusalem": @"IL",
             @"Kabul": @"AF",
             @"Kamchatka": @"RU", // Moscow+08
             @"Karachi": @"PK",
             @"Kashgar": @"CN",
             @"Kathmandu": @"NP",
             @"Khandyga": @"RU", // Moscow+06
             @"Kolkata": @"IN",
             @"Krasnoyarsk": @"RU", // Moscow+04
             @"Kuala_Lumpur": @"MY",
             @"Kuching": @"MY",
             @"Kuwait": @"KW",
             @"Macau": @"MO",
             @"Magadan": @"RU", // Moscow+08
             @"Makassar": @"ID",
             @"Manila": @"PH",
             @"Muscat": @"OM",
             @"Nicosia": @"CY",
             @"Novokuznetsk": @"RU", // Moscow+03
             @"Novosibirsk": @"RU", // Moscow+03
             @"Omsk": @"RU", // Moscow+03
             @"Oral": @"KZ",
             @"Phnom_Penh": @"KH",
             @"Pontianak": @"ID",
             @"Pyongyang": @"KP",
             @"Qatar": @"QA",
             @"Qyzylorda": @"KZ",
             @"Rangoon": @"MM",
             @"Riyadh": @"SA",
             @"Sakhalin": @"RU", // Moscow+07
             @"Samarkand": @"UZ",
             @"Seoul": @"KR",
             @"Shanghai": @"CN",
             @"Singapore": @"SG",
             @"Taipei": @"TW",
             @"Tashkent": @"UZ",
             @"Tbilisi": @"GE",
             @"Tehran": @"IR",
             @"Thimphu": @"BT",
             @"Tokyo": @"JP",
             @"Ulaanbaatar": @"MN",
             @"Urumqi": @"CN",
             @"Ust-Nera": @"RU", // Moscow+07
             @"Vientiane": @"LA",
             @"Vladivostok": @"RU", // Moscow+07
             @"Yakutsk": @"RU", // Moscow+06
             @"Yekaterinburg": @"RU", // Moscow+02
             @"Yerevan": @"AM",
             };
}

+ (NSDictionary *)atlanticRegionCodes {
    // Prefixed with “Atlantic/”
    return @{
             @"Azores": @"PT", // Portugal
             @"Bermuda": @"BM",
             @"Canary": @"ES", // Spain
             @"Cape_Verde": @"CV",
             @"Faroe": @"FO",
             @"Madeira": @"PT", // Portugal
             @"Reykjavik": @"IS", // Island
             @"South_Georgia": @"GS",
             @"St_Helena": @"SH",
             @"Stanley": @"FK",
             };
}

+ (NSDictionary *)australiaRegionCodes {
    // Prefixed with “Australia/”
    return @{
             @"Adelaide": @"AU",
             @"Brisbane": @"AU",
             @"Broken_Hill": @"AU",
             @"Currie": @"AU",
             @"Darwin": @"AU",
             @"Eucla": @"AU",
             @"Hobart": @"AU",
             @"Lindeman": @"AU",
             @"Lord_Howe": @"AU",
             @"Melbourne": @"AU",
             @"Perth": @"AU",
             @"Sydney": @"AU",
             };
}

+ (NSDictionary *)europeRegionCodes {
    // Prefixed with “Europe/”
    return @{
             @"Amsterdam": @"NL",
             @"Andorra": @"AD",
             @"Athens": @"GR",
             @"Belgrade": @"RS",
             @"Berlin": @"DE",
             @"Bratislava": @"SK",
             @"Brussels": @"BE",
             @"Bucharest": @"RO",
             @"Budapest": @"HU",
             @"Busingen": @"DE",
             @"Chisinau": @"MD",
             @"Copenhagen": @"DK",
             @"Dublin": @"IE",
             @"Gibraltar": @"GI",
             @"Guernsey": @"GG",
             @"Helsinki": @"FI",
             @"Isle_of_Man": @"IM",
             @"Istanbul": @"TR",
             @"Jersey": @"JE",
             @"Kaliningrad": @"RU", // Moscow-01
             @"Kiev": @"UA",
             @"Lisbon": @"PT",
             @"Ljubljana": @"SI",
             @"London": @"GB",
             @"Luxembourg": @"LU",
             @"Madrid": @"ES",
             @"Malta": @"MT",
             @"Mariehamn": @"AX",
             @"Minsk": @"BY",
             @"Monaco": @"MC",
             @"Moscow": @"RU", // Moscow+00
             @"Oslo": @"NO",
             @"Paris": @"FR",
             @"Podgorica": @"ME",
             @"Prague": @"CZ",
             @"Riga": @"LV",
             @"Rome": @"IT",
             @"Samara": @"RU", // Moscow+00
             @"San_Marino": @"SM",
             @"Sarajevo": @"BA",
             @"Simferopol": @"UA",
             @"Skopje": @"MK",
             @"Sofia": @"BG",
             @"Stockholm": @"SE",
             @"Tallinn": @"EE",
             @"Tirane": @"AL",
             @"Uzhgorod": @"UA",
             @"Vaduz": @"LI",
             @"Vatican": @"VA",
             @"Vienna": @"AT",
             @"Vilnius": @"LT",
             @"Volgograd": @"RU", // Moscow+00
             @"Warsaw": @"PL",
             @"Zagreb": @"HR",
             @"Zaporozhye": @"UA",
             @"Zurich": @"CH",
             };
}

+ (NSDictionary *)indianRegionCodes {
    // Prefixed with “Indian/”
    return @{
             @"Antananarivo": @"MG", // Madagascar
             @"Chagos": @"IO",
             @"Christmas": @"CX",
             @"Cocos": @"CC",
             @"Comoro": @"KM", // Comoros
             @"Kerguelen": @"TF",
             @"Mahe": @"SC", // Seychelles
             @"Maldives": @"MV",
             @"Mauritius": @"MU",
             @"Mayotte": @"YT",
             @"Reunion": @"RE",
             };
}

+ (NSDictionary *)pacificRegionCodes {
    // Prefixed with “Pacific/”
    return @{
             @"Apia": @"WS", // Samoa
             @"Auckland": @"NZ", // New Zealand
             @"Chatham": @"NZ", // New Zealand
             @"Chuuk": @"FM", // Micronesia
             @"Easter": @"CL", // Chile
             @"Efate": @"VU", // Vanuatu
             @"Enderbury": @"KI", // Kiribati
             @"Fakaofo": @"TK",
             @"Fiji": @"FJ",
             @"Funafuti": @"TV", // Tuvalu
             @"Galapagos": @"EC", // Ecuador
             @"Gambier": @"PF",
             @"Guadalcanal": @"SB", // Solomon Islands
             @"Guam": @"GU",
             @"Honolulu": @"US", // Hawaii
             @"Johnston": @"UM",
             @"Kiritimati": @"KI", // Kiribati
             @"Kosrae": @"FM", // Micronesia
             @"Kwajalein": @"MH", // Marshall Islands
             @"Majuro": @"MH", // Marshall Islands
             @"Marquesas": @"PF",
             @"Midway": @"UM",
             @"Nauru": @"NR",
             @"Niue": @"NU",
             @"Norfolk": @"NF",
             @"Noumea": @"NC",
             @"Pago_Pago": @"AS",
             @"Palau": @"PW",
             @"Pitcairn": @"PN",
             @"Pohnpei": @"FM", // Micronesia
             @"Port_Moresby": @"PG", // Papua-New Guinea
             @"Rarotonga": @"CK",
             @"Saipan": @"MP",
             @"Tahiti": @"PF",
             @"Tarawa": @"KI", // Kiribati
             @"Tongatapu": @"TO", // Tonga
             @"Wake": @"UM",
             @"Wallis": @"WF",
             };
}

@end

