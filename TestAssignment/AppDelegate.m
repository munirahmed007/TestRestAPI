//
//  AppDelegate.m
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import "AppDelegate.h"
#import "CBHttpClient.h"
#import "CBURLRequestImp.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property CBHTTPClient *client;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    //test run.
    NSURL *url = [NSURL URLWithString:@"https://www.google.com.pk"];
    self.client = [[CBHTTPClient new] initWithURL:url requestTimeout:100.0 retryCount:5 delegate:self];
    [self.client sendRequest:@{} withHttpExecutor:[CBURLRequestImp new]];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (void) requestOK:(CBHTTPClient *)client
{
    NSLog(@"recv data of length %ld", client.data.length);
}

- (void) requestTryAgain:(CBHTTPClient *)client
{
    NSLog(@"try again for status code %ld", client.statusCode);
    [client retryRequest];
    
}

- (void) requestCompleted:(CBHTTPClient *)client
{
    NSLog(@"request completed with status code %ld", client.statusCode);
    
}

- (void) requestFailed:(CBHTTPClient *)client
{
    NSLog(@"request failed for error %@", client.error);
    
}

- (void) requestTimeout:(CBHTTPClient *)client
{
    NSLog(@"timeout %@", client.error);
}


@end
