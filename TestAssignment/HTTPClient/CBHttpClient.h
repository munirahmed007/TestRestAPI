//
//  CBHttpClient.h
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBHTTPClientDelegate.h"
#import "CBURLRequestProtocol.h"

@interface CBHTTPClient : NSObject

/* status code returned as part of http response*/
@property NSInteger statusCode;

/* response http header fields */
@property NSDictionary *httpResponesHeaderFields;

/* request http header fields */
@property NSDictionary *httpRequestHeaderFields;

/* request parameters sent as part of GET/POST request */
@property NSDictionary *requestParameters;

/* data recvd as part of http request execution */
@property NSData *data;

/* error when request is failed. */
@property NSError *error;

-(void)sendRequest:(NSDictionary *)params withHttpExecutor:(id<CBURLRequestProtocol>)httpExecutor;
-(CBHTTPClient *) initWithURL:(NSURL *)url requestTimeout:(NSInteger)timeout retryCount:(NSInteger)retry delegate:(id<CBHTTPClientDelegate>) delegate;

-(NSURL *) requestedURL;

-(void) retryRequest;


@end
