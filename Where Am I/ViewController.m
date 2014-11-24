//
//  ViewController.m
//  Where Am I
//
//  Created by Martin Kiss on 21.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import UIKit;
@import Where;
@import MapKit;


@interface ViewController : UIViewController

@property IBOutlet UISegmentedControl *segmentControl;
@property IBOutlet UISwitch *internetSwitch;
@property IBOutlet UISwitch *locationSwitch;

@property IBOutlet MKMapView *mapView;
@property MKPointAnnotation *travelAnnotation;
@property MKPointAnnotation *homeAnnotation;

@property IBOutlet UILabel *source1Title;
@property IBOutlet UILabel *source2Title;
@property IBOutlet UILabel *source3Title;

@property IBOutlet UILabel *source1Region;
@property IBOutlet UILabel *source2Region;
@property IBOutlet UILabel *source3Region;

@property IBOutlet UILabel *source1Code;
@property IBOutlet UILabel *source2Code;
@property IBOutlet UILabel *source3Code;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.travelAnnotation = [MKPointAnnotation new];
    self.travelAnnotation.title = @"You Are Here";
    
    self.homeAnnotation = [MKPointAnnotation new];
    self.homeAnnotation.title = @"You Live Here";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:WhereDidUpdateNotification object:nil];
    
    [self detect];
}

- (IBAction)detect {
    WhereOptions options = WhereOptionUpdateContinuously;
    if (self.internetSwitch.on) {
        options |= WhereOptionUseInternet;
    }
    if (self.locationSwitch.on) {
        options |= WhereOptionAskForPermission;
    }
    [Where detectWithOptions:options];
}

- (IBAction)update {
    [self updateAnnotation:self.homeAnnotation withLocation:[Where isHome]];
    [self updateAnnotation:self.travelAnnotation withLocation:[Where amI]];
    
    BOOL isTravel = (self.segmentControl.selectedSegmentIndex == 0);
    if (isTravel && [self.mapView.annotations containsObject:self.travelAnnotation]) {
        [self.mapView selectAnnotation:self.travelAnnotation animated:YES];
    }
    if ( ! isTravel && [self.mapView.annotations containsObject:self.homeAnnotation]) {
        [self.mapView selectAnnotation:self.homeAnnotation animated:YES];
    }
    
    WhereSource source1 = (isTravel? WhereSourceWiFiIPAddress : WhereSourceLocale);
    WhereSource source2 = (isTravel? WhereSourceTimeZone : WhereSourceCarrier);
    WhereSource source3 = (isTravel? WhereSourceLocationServices : WhereSourceCellularIPAddress);
    
    self.source1Title.text = [self sourceTitle:source1];
    self.source2Title.text = [self sourceTitle:source2];
    self.source3Title.text = [self sourceTitle:source3];
    
    self.source1Region.text = [[Where forSource:source1] regionName];
    self.source2Region.text = [[Where forSource:source2] regionName];
    self.source3Region.text = [[Where forSource:source3] regionName];
    
    self.source1Code.text = [[Where forSource:source1] regionCode];
    self.source2Code.text = [[Where forSource:source2] regionCode];
    self.source3Code.text = [[Where forSource:source3] regionCode];
}

- (void)updateAnnotation:(MKPointAnnotation *)annotation withLocation:(Where *)location {
    annotation.subtitle = location.regionName;
    annotation.coordinate = location.coordinate;
    if (location) {
        [self.mapView addAnnotation:annotation];
    }
    else {
        [self.mapView removeAnnotation:annotation];
    }
}

- (NSString *)sourceTitle:(WhereSource)source {
    switch (source) {
        case WhereSourceNone: return @"Unwnown";
        case WhereSourceLocale: return @"Locale";
        case WhereSourceCarrier: return @"Carrier";
        case WhereSourceCellularIPAddress: return @"Cellular IP";
        case WhereSourceTimeZone: return @"Time Zone";
        case WhereSourceWiFiIPAddress: return @"Wi-Fi IP";
        case WhereSourceLocationServices: return @"Location";
    }
    return @"Unknown";
}

@end

