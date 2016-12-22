//
//  CBHttpClient.m
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import "CBHttpClient.h"
#import "CBURLRequestImp.h"

@interface CBHTTPClient ()

@property (weak) id<CBHTTPClientDelegate> delegate;
@property         NSURL *requestURL;
@property         NSInteger timeout;
@property         CBURLRequestImp *requestImp;
@property         NSDictionary *parameters;
@property         NSInteger  retryCount;
@end

@implementation CBHTTPClient

//request completion handler
- (void) performOnRequestCompletionWithData:(NSData *)data statusCode:(NSInteger)responseCode error:(NSError *)error
{
    //if no error, call delegate for 200 or 500
    if (!error){
        if (responseCode == CBHTTPResponseCode_200) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestOK:)]){
                [self.delegate requestOK:data];
            }
        }
        else if (responseCode == CBHTTPResponseCode_500) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTryAgain:)]){
                [self.delegate requestTryAgain:self];
            }
        }
    }
    else {
        //when there is an error.
        if ([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == -1001)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTimeout:)]){
                [self.delegate requestTimeout:self];
            }
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]){
                [self.delegate requestFailed:self];
            }
            
        }
        
    }
}

- (NSURL *) requestedURL
{
    return self.requestURL;
}

//execute request
-(void)sendRequest:(NSDictionary *)params
{
    self.requestImp = [CBURLRequestImp new];
    CBHTTPClient __weak *weakSelf = self;
    self.parameters = params;
    
    //decrement retry count
    self.retryCount--;
    
    if (self.retryCount < 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]){
            [self.delegate requestFailed:self];
        }
    }
    else {
        [self.requestImp performRequest:self.requestURL requestMethod:CBHTTPMethodGet requestParameters:params  httpHeaderFields:@{}  timeoutInterval:self.timeout httpCallback:^(NSData *data, NSInteger responseCode, NSError *error) {
            [weakSelf performOnRequestCompletionWithData:data statusCode:responseCode error:error];
        }];
    }
}

-(void) retryRequest
{
    [self sendRequest:self.parameters];
}

//ctor
-(CBHTTPClient *) initWithURL:(NSURL *)url requestTimeout:(NSInteger)timeout retryCount:(NSInteger)retry delegate:(id<CBHTTPClientDelegate>) delegate
{
    self = [super init];
    
    if (self)
    {
        self.requestURL = url;
        self.delegate = delegate;
        self.timeout = timeout;
        self.retryCount = retry;
    }
    
    return self;
}

@end