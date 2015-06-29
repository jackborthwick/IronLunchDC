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
#import <GoogleMaps/GoogleMaps.h>

@interface FirstViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView  *mapView;
@property (nonatomic, strong) Results *resultsManager;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) CLLocation *lastLocation;

@end

@implementation FirstViewController{
    GMSMapView *mapViewG;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
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

#pragma mark - google map methods

- (void)zoomToCurrentLocation {
    GMSCameraPosition *myLocationCP =  [GMSCameraPosition cameraWithLatitude:_lastLocation.coordinate.latitude
                                                                   longitude:_lastLocation.coordinate.longitude
                                                                        zoom:6];
    NSLog(@"ZOOMIN TO %f %f",_lastLocation.coordinate.latitude,_lastLocation.coordinate.longitude);
    mapViewG.camera = myLocationCP;
    [mapViewG reloadInputViews];
}


#pragma mark - Map Methods


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _lastLocation = locations.lastObject;
    NSLog(@"location: %f,%f",_lastLocation.coordinate.latitude,_lastLocation.coordinate.longitude);
    [self zoomToCurrentLocation];
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


- (void)getSearchResults {
    _resultsManager = [Results sharedHelper];
    [_resultsManager getResults:_searchBar.text];
    NSLog(@"getting search results");
}
- (void)newDataReceived {
    NSLog(@"TITLE IS %@",[[[_resultsManager dataArray] objectAtIndex:0]title]);
    NSLog(@"COUNT IS %li",(unsigned long)[_resultsManager dataArray].count);
    NSLog(@"%@",[[[_resultsManager dataArray] objectAtIndex:1]snippet]);
    for (GMSMarker *item in [_resultsManager dataArray]) {
        item.map = mapViewG;
    }
    
}



#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLocationMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataReceived) name:@"ResultsDoneNotification" object:nil];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _resultsManager = _appDelegate.resultsManager;
    


    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mapViewG.myLocation.coordinate.latitude
                                                            longitude:mapViewG.myLocation.coordinate.longitude
                                                                 zoom:6];
    mapViewG = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapViewG.myLocationEnabled = YES;
    self.view = mapViewG;
    [self zoomToCurrentLocation];
    //mapViewG.reloadInputViews;

    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self zoomToCurrentLocation];
    //mapViewG.reloadInputViews;
    
    NSLog(@"done");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
