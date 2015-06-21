//
//  FirstViewController.m
//  IronLunchDC
//
//  Created by Jack Borthwick on 6/18/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
// save
// directions
// text fields martching put it where all the other data is

#import "FirstViewController.h"
#import "Results.h"
#import "AppDelegate.h"
@interface FirstViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView  *mapView;
@property (nonatomic, strong) Results *resultsManager;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation FirstViewController

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self removeExistingAnnotations];
    [self getSearchResults];
}

- (void)appleSearch {
    NSLog(@"apple search");
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = _searchBar.text;
    request.region = [_mapView region];
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count == 0) {
            NSLog(@"nada");
        }
        else {
            for (MKMapItem *item in response.mapItems) {
                MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
                pa.coordinate = item.placemark.location.coordinate;
                pa.title = item.name;
                pa.subtitle = [NSString stringWithFormat:@"Local search:%f.%f",item.placemark.location.coordinate.latitude, item.placemark.location.coordinate.longitude];
                [_mapView addAnnotation:pa];
                
            }
        }
    }];
}

#pragma mark - Map Methods

-(void)annotateMapLocations {//THROW ALL OF THE SEARCH RESULTS HERE AND ADD THEM
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_mapView annotations]) {
        [locs addObject:annot];
    }
    [_mapView removeAnnotations:locs];
    
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = CLLocationCoordinate2DMake(39,-77);
    pa.title = @"near the dmv";
    [annotationArray addObject:pa];
    MKPointAnnotation *da = [[MKPointAnnotation alloc] init];
    da.coordinate = CLLocationCoordinate2DMake(39.1,-77);
    da.title = @"kinda near the dmv";
    [annotationArray addObject:da];
    [_mapView addAnnotations:annotationArray];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastLocation = locations.lastObject;
    NSLog(@"location: %f,%f",lastLocation.coordinate.latitude,lastLocation.coordinate.longitude);
    
    [self zoomToLocationWithLat:lastLocation.coordinate.latitude andLon:lastLocation.coordinate.longitude];
    [_locationManager stopUpdatingLocation];
}

- (void)turnOnLocationMonitoring {
    [_locationManager startUpdatingLocation];
    _mapView.showsUserLocation = true;
    
}

- (void) setupLocationMonitoring {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways: //is location services authorized always
                [self turnOnLocationMonitoring];
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self turnOnLocationMonitoring];
                break;
            case kCLAuthorizationStatusDenied:{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AHHHH" message:@"SO TURN IT ON LIKE DIDDY KONG" delegate:self cancelButtonTitle:@"AY" otherButtonTitles: nil];
                [alert show];
                break;
            }
            case kCLAuthorizationStatusNotDetermined:
                if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [_locationManager requestWhenInUseAuthorization];
                }
            default:
                break;
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"locationservices off" message:@"SO TURN IT ON LIKE DIDDY KONG" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}


- (void)zoomToLocationWithLat:(float)latitude andLon:(float)longitude {
    if (latitude == 0 && longitude == 0) {
        NSLog(@"Bad Coordinates");
    } else {
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = latitude;
        zoomLocation.longitude = longitude;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 90000, 90000);
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:true];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation != mapView.userLocation) {
        MKPinAnnotationView *anotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (anotationView == nil) {
            anotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DAT DER SPOT"];
            anotationView.canShowCallout = true;
            anotationView.pinColor = MKPinAnnotationColorGreen;
            anotationView.animatesDrop = true;
        }
        else {
            anotationView.annotation = annotation;
        }
        return anotationView;
    }
    return nil;
}
- (void)getSearchResults {
    _resultsManager = [Results sharedHelper];
    [_resultsManager getResults:_searchBar.text];
    NSLog(@"getting search results");
}
- (void)newDataReceived {
    NSLog(@"TITLE IS %@",[[[_resultsManager dataArray] objectAtIndex:0]title]);
    NSLog(@"COUNT IS %li",[_resultsManager dataArray].count);
    NSLog(@"%@",[[[_resultsManager dataArray] objectAtIndex:1]subtitle]);
    for (MKPointAnnotation *item in [_resultsManager dataArray]) {
        [_mapView addAnnotation:item];
    }
    
}

- (void)removeExistingAnnotations {
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_mapView annotations]) {
        [locs addObject:annot];
    }
    [_mapView removeAnnotations:locs];
    NSLog(@"removing existing annotations");
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLocationMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataReceived) name:@"ResultsDoneNotification" object:nil];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _resultsManager = _appDelegate.resultsManager;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self annotateMapLocations];
    [_mapView showAnnotations:[_mapView annotations] animated:true];
    
    [self removeExistingAnnotations];
    [_mapView addAnnotations:[_resultsManager dataArray]];

//    for (MKPointAnnotation *testPoint in [_resultsManager dataArray]) {
//        NSLog(@"Got: %@",[testPoint title]);
//    }
    NSLog(@"done");
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
