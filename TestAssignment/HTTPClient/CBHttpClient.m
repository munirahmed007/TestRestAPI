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
@property         id<CBURLRequestProtocol> executor;
@property         NSInteger  retryCount;

@end

NSString *CBHTTPClientErrorDomain = @"CBHTTPClientErrorDomain";


@implementation CBHTTPClient

//request completion handler
- (void) performOnRequestCompletionWithData:(NSData *)data statusCode:(NSInteger)responseCode error:(NSError *)error
{
    //if no error, call delegate for 200 or 500
    
    if (!error){
        if (responseCode == CBHTTPResponseCode_200) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestOK:)]){
                [self.delegate requestOK:self];
            }
        }
        else if (responseCode == CBHTTPResponseCode_500) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTryAgain:)]){
                [self.delegate requestTryAgain:self];
            }
        }
        else {
                //when error code is different than 200 or 500
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestCompleted:)]){
                [self.delegate requestCompleted:self];
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

- (void) postRequestFailureError
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]){
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"CBHTTPClient consumed all retries.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Operation was unsuccessful", nil)
                                   };
        self.error = [NSError errorWithDomain:CBHTTPClientErrorDomain
                                         code:-57
                                     userInfo:userInfo];
        [self.delegate requestFailed:self];
    }
}

- (void) executeRequest
{
    CBHTTPClient __weak *weakSelf = self;

    [self.executor performRequest:self.requestURL requestMethod:CBHTTPMethodGet requestParameters:self.requestParameters  httpHeaderFields:@{}  timeoutInterval:self.timeout httpCallback:^(NSData *data, NSDictionary *httpHeader, NSInteger responseCode, NSError *error) {
        
        self.httpResponesHeaderFields = httpHeader;
        self.data = data;
        self.statusCode = responseCode;
        self.error = error;
        
        [weakSelf performOnRequestCompletionWithData:data statusCode:responseCode error:error];
    }];
}

//execute request
-(void)sendRequest:(NSDictionary *)params withHttpExecutor:(id<CBURLRequestProtocol>)httpExecutor;
{
    self.requestParameters = params;
    self.executor = httpExecutor;
    
    //decrement retry count
    self.retryCount--;
    
    if (self.retryCount < 0)
    {
        [self postRequestFailureError];
    }
    else {
        [self executeRequest];
    }
}

-(void) retryRequest
{
    [self sendRequest:self.requestParameters withHttpExecutor:self.executor];
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
