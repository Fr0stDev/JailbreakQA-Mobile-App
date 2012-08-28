//
//  JBQAMasterViewController.m
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQALinks.h"

#import "JBQAMasterViewController.h"
#import "JBQADetailViewController.h"
#import "JBQAQuestionController.h"
#import "JBQALoginController.h"

#import "JBQAReachability.h"
#import "JBQAFeedParser.h"

#import "TSActionSheet.h"
#import "ODRefreshControl.h"

@interface JBQAMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation JBQAMasterViewController

#pragma mark View Stuff -
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"JBQA";
    }
    backgroundQueue = dispatch_queue_create("jbqamobile.bgqueue", NULL);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startReachability];
    //Add Buttons
    menuBtn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(displayUserMenu:event:)];
   
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"light_noise_diagonal"]]];
    dispatch_async(backgroundQueue, ^(void){[self refreshData];});
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    cellSize = CGSizeMake([self.tableView bounds].size.width, 60);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Login and Refresh Methods -

- (void)displayUserMenu:(id)sender event:(UIEvent *)event {
    
    /*
     This is pretty fucking lazy, I know. I'll fix it later, I promise
    */
    
    JBQALoginController *loginView = [[JBQALoginController alloc] init];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SERVICE_URL]]];
     
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    if ([html rangeOfString:@"login"].location == NSNotFound) {
        
        actionSheet = [[TSActionSheet alloc] initWithTitle:@"JailbreakQA"];
        [actionSheet destructiveButtonWithTitle:@"Logout" block:^(void) {
            
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jailbreakqa.com/logout/"]]];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"JailbreakQA" message:@"You are now logged out of JailbreakQA." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }];
        
        id cats = self; //I had to rename it "cats".
        [actionSheet addButtonWithTitle:@"Ask a Question" block:^{
            [cats ask];
        }];
        
        actionSheet.cornerRadius = 5;
        [actionSheet showWithTouch:event];
        NSLog(@"Already logged in");
    }
    
    else {
        loginView.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:loginView animated:YES completion:NULL];
    }
}


- (void)refreshData
{
    feedParser = [[JBQAFeedParser alloc] init];
    feedParser.delegate = self;
    
    [refreshControl beginRefreshing];
    
    if (reachability.isInternetActive)
        dispatch_async(backgroundQueue, ^(void) {
            NSLog(@"Calling -parseXMLFileAtURL:");
            [feedParser parseXMLFileAtURL:RSS_FEED];
        });
    else
        [self parseErrorOccurred:nil];
}
- (void)startReachability
{
    //Reachability!
    reachability = [[JBQAReachability alloc] init];
    [reachability startNetworkStatusNotifications];
}
- (void)ask
{
    if (reachability.isInternetActive) {
        JBQAQuestionController *qController = [[JBQAQuestionController alloc] initWithNibName:@"JBQAQuestionController" bundle:nil];
        qController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:qController animated:YES completion:NULL];
    }
    else
        [self parseErrorOccurred:nil];
}

#pragma mark Parser Delegate Methods -

- (void)parseErrorOccurred:(NSError *)parseError
{
    feedParser.parsing = NO;
    if (reachability.isInternetActive && reachability.isHostReachable) {
        NSString *errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Please check your internet connection and try again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorAlert show];
    }
    [refreshControl endRefreshing];
    self.navigationItem.rightBarButtonItem = menuBtn; //Unhide it.... because it was hidden.
}


- (void)parserDidEndDocumentWithResults:(id)parseResults
{
    stories = parseResults;
    [self.tableView reloadData];
    NSLog(@"tableView updated, with %d items", [stories count]); //always thirty GAR! I WANT MOAR
    
    feedParser.parsing = NO;
    [refreshControl endRefreshing];
    self.navigationItem.rightBarButtonItem = menuBtn; //Unhide it.... because it was hidden.
}



#pragma mark Table -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stories count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
    
    NSString *questionTitle = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString *questionAuthor = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    
	cell.textLabel.text = questionTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Asked by: %@",questionAuthor];
    
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO

;
}

/*
 // Override to support rearranging the table view.
 -(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 -(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
    
    NSString *currentQuestion = [[stories objectAtIndex:storyIndex] objectForKey:@"summary"];
    NSString *title = [[stories objectAtIndex:storyIndex] objectForKey:@"title"];
    NSString *asker = [[stories objectAtIndex:storyIndex] objectForKey:@"author"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:[[stories objectAtIndex:storyIndex] objectForKey:@"pubDate"]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    
        if (!self.detailViewController) {
            
	        self.detailViewController = [[JBQADetailViewController alloc] initWithNibName:@"JBQADetailViewController_iPhone" bundle:nil];
	    }
        
	    self.detailViewController.detailItem = object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
        
    }
    else {
        self.detailViewController.detailItem = object;
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[stories objectAtIndex:storyIndex] objectForKey:@"link"]]]];
    
    NSString *img = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].src;"];
    
    NSURL *imageURL = [NSURL URLWithString:img];
    [self.detailViewController setQuestionTitle:title asker:asker date:date];
    [self.detailViewController setAvatarFromURL:imageURL];
    [self.detailViewController setQuestionContent:currentQuestion];
    self.detailViewController.title = @"Details";
    

}
 
@end
