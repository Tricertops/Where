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
@property IBOutlet MKMapView *mapView;
@property MKPointAnnotation *travelAnnotation;
@property MKPointAnnotation *homeAnnotation;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.travelAnnotation = [MKPointAnnotation new];
    self.travelAnnotation.title = @"You Are Here";
    
    self.homeAnnotation = [MKPointAnnotation new];
    self.homeAnnotation.title = @"You Live Here";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:WhereDidUpdateNotification object:nil];
    
    [Where detectWithOptions:(WhereOptionUseInternet | WhereOptionUseLocationServices | WhereOptionUpdateContinuously)];
}

- (IBAction)update {
    [self updateAnnotation:self.homeAnnotation withLocation:[Where isHome]];
    [self updateAnnotation:self.travelAnnotation withLocation:[Where amI]];
    
    NSUInteger selected = self.segmentControl.selectedSegmentIndex;
    if (selected == 0 && [self.mapView.annotations containsObject:self.travelAnnotation]) {
        [self.mapView selectAnnotation:self.travelAnnotation animated:YES];
    }
    else if (selected == 1 && [self.mapView.annotations containsObject:self.homeAnnotation]) {
        [self.mapView selectAnnotation:self.homeAnnotation animated:YES];
    }
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

@end

