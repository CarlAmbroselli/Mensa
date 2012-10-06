//
//  HPIFoodFirstViewController.m
//  HPI Food
//
//  Created by Carl Ambroselli on 01.10.12.
//  Copyright (c) 2012 Carl Ambroselli. All rights reserved.
//

#import "HPIFoodMensaViewController.h"

@interface HPIFoodMensaViewController ()

@end

@implementation HPIFoodMensaViewController

@synthesize meals;
@synthesize reach;
@synthesize noConnectionView = _noConnectionView;
@synthesize refreshHeaderView = _refreshHeaderView;

- (UIView *) noConnectionView {
    if (_noConnectionView == nil) {
        _noConnectionView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _noConnectionView.center = self.tableView.center;
        
        _noConnectionView.backgroundColor = [UIColor whiteColor];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        //titleLabel.font = [UIFont mediumMightFontOfSize:19.f];
        titleLabel.text = @"Keine Internetverbindung.";
        titleLabel.numberOfLines = 1;
        [_noConnectionView addSubview:titleLabel];
    }
    
    return _noConnectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Defaults"]];
	// Do any additional setup after loading the view, typically from a nib.
    self.reach = [Reachability reachabilityWithHostName:@"mensaapi.herokuapp.com"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Speiseplan wird geladen";
    [hud show:NO];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    //Show the Pull to refresh bar
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
        
        //Background of the refresh header
        view.backgroundColor = [UIColor colorWithRed:210/255.f green:220/255.f blue:227/255.f alpha:1.000];
        
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadData
{
    if(![self.reach isReachable])
    {
        NSLog(@"No Network");
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self doneLoadingTableViewData];
        self.view.backgroundColor = [UIColor whiteColor];
        return;
    }
    
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://mensaapi.herokuapp.com/get.php"]];
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableArray *tmpmeals = [[NSMutableArray alloc] init];
    NSArray *allObjects = [NSArray arrayWithArray:[jsonObjects allObjects]];
    for (id meal in allObjects) {
        [tmpmeals addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             [meal objectForKey:@"date"], @"date",
                             [meal objectForKey:@"meal"], @"meal",
                             nil]];
    }
    
    self.meals = [NSArray arrayWithArray:tmpmeals];
    [self.tableView setSeparatorColor:[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0]];
    [self.tableView reloadData];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"separator.png"]];
    [self doneLoadingTableViewData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![self.reach isReachable]) {
        [self.view addSubview:self.noConnectionView];
    }
    else {
        if (_noConnectionView) {
            [self.noConnectionView removeFromSuperview];
            self.noConnectionView = nil;
        }
    }
    
        return [self.meals count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.meals objectAtIndex:section] objectForKey:@"meal"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *text = [[[self.meals objectAtIndex:indexPath.section] objectForKey:@"meal"] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [[HPIFoodListCell alloc] initWithText:text];
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 25;
}

#define PADDING 7.0f
- (CGFloat)tableView:(UITableView *)t heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[[self.meals objectAtIndex:indexPath.section] objectForKey:@"meal"] objectAtIndex:indexPath.row];
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:@"Signika Negative" size:18.0f] constrainedToSize:CGSizeMake(self.tableView.frame.size.width - PADDING * 3, 1000.0f)];
    
    return textSize.height + PADDING * 3;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    UIImageView * header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(8, 3, 310, 20)];
    
    label.text = [[self.meals objectAtIndex:section] objectForKey:@"date"];
    label.font = [UIFont fontWithName:@"Futura" size:12.0f];
    label.backgroundColor = [UIColor clearColor];
    [header addSubview:label];
    header.backgroundColor = [UIColor colorWithRed:152.0f/255.0f green:164.0f/255.0f blue:175.0f/255.0f alpha:0.8f];;
    return header;
}


#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return;
}

#pragma mark Pull To Refresh Delegate

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

@end
