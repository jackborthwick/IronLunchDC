//
//  SecondViewController.m
//  IronLunchDC
//
//  Created by Jack Borthwick on 6/18/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"
@interface SecondViewController ()

@property (nonatomic, strong) Results               *resultsManager;
@property (nonatomic, strong) IBOutlet UITableView  *resultsTableView;
@property (nonatomic, strong) AppDelegate           *appDelegate;
@property (nonatomic, strong) NSString              *searchString;

@end




@implementation SecondViewController

#pragma mark - data methods
-(void) newDataReceivedForTable {
    NSLog(@"NDRFT:%li",[_resultsManager dataArray].count);
    [_resultsTableView reloadData];
    NSLog(@"reloading table");
}

#pragma mark - search methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_resultsManager getResults:_searchBarForTable.text];
    NSLog(@"getting search results");
}

#pragma mark - table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_resultsManager dataArray].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.text = [[[_resultsManager dataArray]objectAtIndex:indexPath.row]title];
    return cell;
}




#pragma mark - life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataReceivedForTable) name:@"ResultsDoneNotification" object:nil];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _resultsManager = _appDelegate.resultsManager;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
