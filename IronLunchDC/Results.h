//
//  Results.h
//  IronLunchDC
//
//  Created by Jack Borthwick on 6/18/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirstViewController.h"
@interface Results : NSObject 

@property (nonatomic, strong) NSMutableArray *dataArray;

+ (id)sharedHelper;
- (void)getResults:(NSString *) searchString;

@end
