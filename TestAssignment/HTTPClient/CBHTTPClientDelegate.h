//
//  CBHTTPClientDelegate.h
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBHTTPClient;

//delegate protocol to get result back from CBHTTPClient
@protocol CBHTTPClientDelegate <NSObject>

/* this method is fired when request completes with 200 response code..*/
- (void) requestOK:(CBHTTPClient *)client;

/* this method is fired when request completed a response code is not 500 and 200.*/
- (void) requestCompleted:(CBHTTPClient *)client;

/* this method is fired when request completed a response code is 500.*/
- (void) requestTryAgain:(CBHTTPClient *)client;

/* this method is fired when request gets timed out.*/
- (void) requestTimeout:(CBHTTPClient *)client;

/* this method is fired when request failed for an error other than timeout error.*/
- (void) requestFailed:(CBHTTPClient *)client;

@end
