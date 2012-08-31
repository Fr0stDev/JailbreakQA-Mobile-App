//
//  JBQAMasterViewController.h
//  JBQA
//
//  Created by Guillermo Moran on 8/11/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "JBQAFeedParser.h"

@class JBQADetailViewController, JBQAFeedParser, JBQAReachability, ODRefreshControl, Reachability;

@interface JBQAMasterViewController : UITableViewController <JBQAParserDelegate, UIActionSheetDelegate>
{    
    //UI
    UITableView *table;
    ODRefreshControl *refreshControl;
    UIBarButtonItem *menuBtn;
    UIBarButtonItem *leftFlex;
    UIActionSheet *menuSheet;
    IBOutlet UIWebView *webView;
    
    //Whatever
    JBQAFeedParser __strong *feedParser;
	CGSize cellSize;
    NSMutableArray *stories;
    //Using Grand Central Dispatch for now, since such a simple thing hardly warrants using NSOperations
    dispatch_queue_t backgroundQueue;
    
    JBQAReachability *reachability;
}

@property (strong, nonatomic) JBQADetailViewController *detailViewController;
@property (strong, nonatomic) NSMutableArray *stories;
@property (strong, nonatomic) JBQAReachability *reachability;
@property (nonatomic) BOOL isLoggedIn;

- (void)refreshData;
- (void)ask;
- (void)displayUserMenu:(id)sender event:(UIEvent *)event;

@end

