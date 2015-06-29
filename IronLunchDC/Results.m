//
//  Results.m
//  IronLunchDC
//
//  Created by Jack Borthwick on 6/18/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "Results.h"
#import "FirstViewController.h"
#import "GoogleMaps/GoogleMaps.h"
@implementation Results

+ (id)sharedHelper {
    static Results *sharedHelper = nil;
    @synchronized(self) {
        if (sharedHelper == nil)
            sharedHelper = [[self alloc] init];
    }
    return sharedHelper;
}

//GMSMarker *marker = [[GMSMarker alloc] init];
//marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
//marker.title = @"Sydney";
//marker.snippet = @"Australia";
//marker.map = mapViewG;

- (void)getResults:(NSString *) searchString {
    _dataArray = [[NSMutableArray alloc]init];
    NSLog(@"apple search IN RESUKLTS");
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    //request.region = [_mapView region];
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count == 0) {
            NSLog(@"nada");
        }
        else {
            for (MKMapItem *item in response.mapItems) {
                GMSMarker *pa = [[GMSMarker alloc] init];
                pa.position = item.placemark.location.coordinate;
                pa.title = item.name;
                pa.snippet = [NSString stringWithFormat:@"Local search:%f.%f",item.placemark.location.coordinate.latitude, item.placemark.location.coordinate.longitude];
                
                [_dataArray addObject:pa];
                NSLog(@"I GOT %@",pa.title);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsDoneNotification" object:nil];
        }
    }];
}

@end
