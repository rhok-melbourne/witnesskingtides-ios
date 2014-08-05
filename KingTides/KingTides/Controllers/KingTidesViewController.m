#import "KingTidesViewController.h"
#import "KingTideLocationViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"
#import "Notifications.h"
#import "UIImageView+AFNetworking.h"
#import "TideInfo.h"
#import "KingTidesService.h"
#import "MBProgressHUD.h"


#define kHeightOfSearchBar 40
#define kHeightOfCell 20
#define kIndicatingWindowShowingTime 2


@interface KingTidesViewController ()
@property(nonatomic,strong) NSDictionary* tideInfoDivideByState;
@property(nonatomic,strong)UISearchBar* searchBar;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic, strong) NSArray *locations;
-(void)setupSearchBar;

//-(BOOL)parseJSONData:(NSArray*)JSONData;
//-(NSArray*)calculateNumbersOfJSON;

@end

@implementation KingTidesViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
 self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.opaque = NO;
  self.tableView.separatorStyle=UITableViewStylePlain;
  //  self.tableView.separatorStyle= UITableViewStyleGrouped;
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default-background.jpg"]];
  [[[GAI sharedInstance] defaultTracker] send:[[[GAIDictionaryBuilder createAppView] set:@"TideList"
                                                    forKey:kGAIScreenName] build]];
  [[KingTidesService sharedService] retrieveTideData:
   ^(id retrievedData)
    {
        if ([retrievedData isKindOfClass:[NSArray class]])
        {
            NSArray* recordArray= [TideInfo parseJSON:retrievedData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tideInfoDivideByState=[TideInfo groupDataByState:recordArray];
                [[self tableView] reloadData];

            });
        }
                 
    }
    failure: ^(NSError *error)
    {
        {
            MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view] ;
            [self.view addSubview:HUD];
            HUD.labelText = @"Fail! Please try again";
            HUD.mode = MBProgressHUDModeText;
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(kIndicatingWindowShowingTime);
            } completionBlock:^{
                [HUD removeFromSuperview];
                //[HUD release];
                //HUD = nil;
            }];
            
        }

            
            
    }
    ];
        
  
    [self setupSearchBar];
    
    

}
-(void)setupSearchBar
{
    CGRect rect= [[self view] frame];
    self.searchBar= [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, kHeightOfSearchBar)];
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = NO;
    self.searchBar.barStyle=UIBarStyleDefault;
    self.searchBar.placeholder=@"ENTER TAS SA WA NT QLD NSW VIC UNDEFINED";
    self.searchBar.hidden=NO;
    self.searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    self.searchBar.alpha=0;
    //mySearchBar.scopeButtonTitles = @[@"城市搜索", @"全国搜索"];
    [self.searchBar sizeToFit];
    //[self setSearchBar:mySearchBar];
    //[[self view] addSubview: [self searchBar]];

    
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dismissView {
  [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)search
{
    [[self view] addSubview:self.searchBar];
    [UISearchBar animateWithDuration:0.25 animations:^{
        self.searchBar.alpha=1;
    }];
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightOfCell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* rowsOfSection=nil;
    if ([self.searchBar.text isEqualToString:@""]) {
        rowsOfSection=[self.tideInfoDivideByState objectForKey:@"nsw"];
    }
    else
        rowsOfSection=[self.tideInfoDivideByState objectForKey:self.searchBar.text];
    
    return [rowsOfSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
    CGRect frame = cell.textLabel.frame;
    frame.size.height = 20;
    cell.textLabel.frame = frame;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor colorWithRed:(68.0f/255.0f) green:(168.0f/255.0f) blue:(218.0f/255.0f) alpha:1];

    
    
    NSMutableArray* rowsOfSection=nil;
    if ([self.searchBar.text isEqualToString:@""])
    {
        rowsOfSection=[self.tideInfoDivideByState objectForKey:@"nsw"];
    }
    else
        rowsOfSection=[self.tideInfoDivideByState objectForKey:self.searchBar.text];
    TideInfo* info=[rowsOfSection objectAtIndex:indexPath.row];
    cell.textLabel.text=info.location;
    return  cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //NSMutableArray* rowsOfSection=nil;
    if ([self.searchBar.text isEqualToString:@""])
    {
        return @"NSW State";
    }
    else
        return [NSString stringWithFormat:@"%@ State",[[self searchBar] text] ];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  // This will create a "invisible" footer
  return kHeightOfSearchBar;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  KingTideLocationViewController *detailViewController = [[KingTideLocationViewController alloc] init];
  
    NSMutableArray* rowsOfSection=nil;
    if ([self.searchBar.text isEqualToString:@""]) {
        rowsOfSection=[self.tideInfoDivideByState objectForKey:@"nsw"];
    }
    else
        rowsOfSection=[self.tideInfoDivideByState objectForKey:self.searchBar.text];
    TideInfo* info= [rowsOfSection objectAtIndex:indexPath.row];
    detailViewController.locationName=info.location;
    detailViewController.description=info.description;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    

}

#pragma UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar

{
    [searchBar setShowsCancelButton:YES animated:YES];
    searchBar.showsScopeBar = NO;
    searchBar.selectedScopeButtonIndex = 0;
    searchBar.placeholder=@"";
    [searchBar sizeToFit];
    
    
}
/* not applicable
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope

{
    
    NSString *s0 = [searchBar.scopeButtonTitles objectAtIndex: selectedScope];
    
    
}
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(searchText);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [ searchBar resignFirstResponder];
    
    // The above statement will disable "Cancel" button. We need to enable it
    for (id subview in searchBar.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview setEnabled:YES];
        }
    }
    
    [UISearchBar animateWithDuration:0.25 animations:^{
        self.searchBar.alpha=0;
    }];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [UISearchBar animateWithDuration:0.25 animations:^{
        self.searchBar.alpha=0;
    }];
    [[self tableView] reloadData];
    
    [ searchBar resignFirstResponder];
    
    // The above statement will disable "Cancel" button. We need to enable it
    for (id subview in searchBar.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview setEnabled:YES];
        }
    }

    
}




@end
