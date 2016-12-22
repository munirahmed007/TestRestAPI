//
//  DummyHttpExecutor.m
//  TestAssignment
//
//  Created by Munir Ahmed on 22/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import "DummyHttpExecutor.h"

@interface DummyHttpExecutor()

@property CBReturnType returnType;
@end

@implementation DummyHttpExecutor

- (void) setReturnHttpOK
{
    self.returnType = CBHTTPOK;
}

- (void) setReturnHttpInternalServerError
{
    self.returnType = CBHTTPServerError;
}

- (void) setReturnHttpTimeout
{
    self.returnType = CBHTTPTimeout;
}

//execute API request
- (void) performRequest:(NSURL *)url requestMethod:(CBHTTPMethod)httpMethod requestParameters:(NSDictionary *)parameters httpHeaderFields:(NSDictionary *)httpHeaders timeoutInterval:(NSInteger)timeout httpCallback:(CBHttpClientCallback) callback
{
    if (self.returnType == CBHTTPOK)
    {
        callback([NSData data], 200, nil);
    }
    else if (self.returnType == CBHTTPServerError)
    {
        callback([NSData data], 500, nil);
    }
    else if (self.returnType == CBHTTPTimeout)
    {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                                   };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:-1001
                                         userInfo:userInfo];
        callback(nil, 0, error);
    }
}

@end
