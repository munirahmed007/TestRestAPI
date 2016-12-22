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

- (void) requestOK:(NSData *)data;
- (void) requestTryAgain:(CBHTTPClient *)client;
- (void) requestTimeout:(CBHTTPClient *)client;
- (void) requestFailed:(CBHTTPClient *)client error:(NSError *)error;

@end
