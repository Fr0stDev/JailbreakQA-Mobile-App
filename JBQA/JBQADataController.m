//
//  JBQADataController.m
//  JBQA
//
//  Created by Aditya KD on 02/09/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import "JBQADataController.h"
#import "Reachability.h"

@implementation JBQADataController {}

#pragma mark Singleton -
+ (id)sharedDataController
{
    __strong static JBQADataController *sharedDataController;
    if (!sharedDataController) sharedDataController = [[self alloc] init];
    return sharedDataController;
}

#pragma mark Login Check -

- (void)checkLoginStatus
{
    if (self.isInternetActive) {
    loginChecker = [[UIWebView alloc] init];
    [loginChecker setDelegate:self];
    [loginChecker loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SERVICE_URL]]];
    self.checkingLogin = YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    for (id delegate in delegateArray)
        if ([delegate respondsToSelector:@selector(dataControllerDidBeginCheckingLogin)])
            [delegate dataControllerDidBeginCheckingLogin];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    for (id delegate in delegateArray)
        if ([delegate respondsToSelector:@selector(dataControllerFailedLoadWithError:)])
            [delegate dataControllerFailedLoadWithError:error];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finished loading for login check");
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    // run javascript in webview:
    [webView stringByEvaluatingJavaScriptFromString:html];
    
    if ([html rangeOfString:@"logout"].location == NSNotFound) {
        NSLog(@"Not logged in.");
        self.loggedIn = NO;
    }
    else {
        NSLog(@"Logged in.");
        self.loggedIn = YES;
    }
    
    for (id delegate in delegateArray)
        if ([delegate respondsToSelector:@selector(dataControllerFinishedCheckingLoginWithResult:)])
            [delegate dataControllerFinishedCheckingLoginWithResult:self.loggedIn];
}

- (void)setDelegate:(id)delegate
{
    if (!delegateArray) delegateArray = [[NSMutableArray alloc] init];
    [delegateArray addObject:delegate];
    NSLog(@"Added object to the delegate array. No. of objects is: %i", delegateArray.count);
}

- (id)delegateArray
{
    return delegateArray;
}

- (NSMutableString *)currentFeed
{
    if (!currentFeed)
        currentFeed = [[NSMutableString alloc] initWithString:RSS_FEED];
    return currentFeed;
}

- (void)setCurrentFeed:(NSMutableString *)currentFeedz
{
    if (!currentFeed)
        currentFeed = [[NSMutableString alloc] initWithString:currentFeedz];
    else
        currentFeed = currentFeedz;
    
}

#pragma mark Reachability Methods -
- (void)startNetworkStatusNotifications
{    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [JBQAReachability reachabilityForInternetConnection];
    
    self.internetActive = [internetReachable currentReachabilityStatus] != NotReachable;
    
    [internetReachable startNotifier];
    NSLog(@"Starting up notifier");

    hostReachable = [JBQAReachability reachabilityWithHostName: SERVICE_URL];
    self.hostReachable = [hostReachable currentReachabilityStatus] != NotReachable;
    
    [hostReachable startNotifier];
}

- (void)networkStatusChanged:(NSNotification *)notice
{
    // called after network status changes
    self.internetActive = [internetReachable currentReachabilityStatus] != NotReachable;
    self.hostReachable = [hostReachable currentReachabilityStatus] != NotReachable;
}

@end
