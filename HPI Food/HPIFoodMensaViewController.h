//
//  HPIFoodFirstViewController.h
//  HPI Food
//
//  Created by Carl Ambroselli on 01.10.12.
//  Copyright (c) 2012 Carl Ambroselli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPIFoodAppDelegate.h"
#import "HPIFoodListCell.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

@interface HPIFoodMensaViewController : UITableViewController <EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) UIView * noConnectionView;
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;

@property NSArray *meals;
@property Reachability *reach;
@end
