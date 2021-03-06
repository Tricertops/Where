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

@property MKPointAnnotation *source1Annotation;
@property MKPointAnnotation *source2Annotation;
@property MKPointAnnotation *source3Annotation;

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
    
    self.source1Annotation = [MKPointAnnotation new];
    self.source2Annotation = [MKPointAnnotation new];
    self.source3Annotation = [MKPointAnnotation new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:WhereDidUpdateNotification object:nil];
    
    [self detect];
}

- (IBAction)detect {
    WhereOptions options = WhereOptionUpdateContinuously;
    if (self.internetSwitch.on) {
        options |= WhereOptionUseInternet;
        self.locationSwitch.enabled = YES;
    }
    else {
        self.locationSwitch.enabled = NO;
        [self.locationSwitch setOn:NO animated:YES];
    }
    if (self.locationSwitch.on) {
        options |= WhereOptionAskForPermission;
    }
    [Where detectWithOptions:options];
}

- (IBAction)update {
    BOOL isTravel = (self.segmentControl.selectedSegmentIndex == 0);
    WhereSource source1 = (isTravel? WhereSourceWiFiIPAddress : WhereSourceLocale);
    WhereSource source2 = (isTravel? WhereSourceTimeZone : WhereSourceCarrier);
    WhereSource source3 = (isTravel? WhereSourceLocationServices : WhereSourceCellularIPAddress);
    
    Where *location1 = [Where forSource:source1];
    Where *location2 = [Where forSource:source2];
    Where *location3 = [Where forSource:source3];
    
    [self updateAnnotation:self.source1Annotation withLocation:location1];
    [self updateAnnotation:self.source2Annotation withLocation:location2];
    [self updateAnnotation:self.source3Annotation withLocation:location3];
    
    NSArray *annotations = @[ self.source3Annotation, self.source2Annotation, self.source1Annotation ];
    MKPointAnnotation *selected = [annotations firstObjectCommonWithArray:self.mapView.annotations];
    if (selected) {
        [self.mapView selectAnnotation:selected animated:YES];
    }
    
    self.source1Title.text = [self sourceTitle:source1];
    self.source2Title.text = [self sourceTitle:source2];
    self.source3Title.text = [self sourceTitle:source3];
    
    self.source1Region.text = location1.regionName;
    self.source2Region.text = location2.regionName;
    self.source3Region.text = location3.regionName;
    
    self.source1Code.text = location1.regionCode;
    self.source2Code.text = location2.regionCode;
    self.source3Code.text = location3.regionCode;
}

- (void)updateAnnotation:(MKPointAnnotation *)annotation withLocation:(Where *)location {
    [self.mapView removeAnnotation:annotation];
    
    annotation.title = [self sourceTitle:location.source];
    annotation.subtitle = location.regionName;
    annotation.coordinate = location.coordinate;
    if (location) {
        [self.mapView addAnnotation:annotation];
    }
}

- (NSString *)sourceTitle:(WhereSource)source {
    switch (source) {
        case WhereSourceNone: return @"Unknown";
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

