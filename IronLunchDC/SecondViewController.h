//
//  SecondViewController.h
//  IronLunchDC
//
//  Created by Jack Borthwick on 6/18/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Results.h"
@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBarForTable;

@end

