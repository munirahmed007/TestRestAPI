//
//  CBHttpClient.h
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBHTTPClientDelegate.h"


@interface CBHTTPClient : NSObject

-(void)sendRequest:(NSDictionary *)params;
-(CBHTTPClient *) initWithURL:(NSURL *)url requestTimeout:(NSInteger)timeout retryCount:(NSInteger)retry delegate:(id<CBHTTPClientDelegate>) delegate;
-(NSURL *) requestedURL;
-(void) retryRequest;
@end
