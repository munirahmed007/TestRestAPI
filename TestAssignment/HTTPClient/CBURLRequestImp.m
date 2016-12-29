//
//  CBURLRequestImp.m
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import "CBURLRequestImp.h"

@interface CBURLRequestImp ()
  @property CBHttpClientCallback clientCallback;
@end

@implementation CBURLRequestImp

//prepare NSURL appening query string parameters.
- (NSURL *) urlForGetMethod:(NSURL *)url withQueryParameters:(NSDictionary *)params
{
    NSString *completeUrlStr = [[url absoluteString] stringByAppendingString:@"?"];
    
    for (NSString *paramKey in [params allKeys])
    {
        NSString *encodedString = [params[paramKey] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        
        completeUrlStr = [completeUrlStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", paramKey, encodedString]];
    }
    
    completeUrlStr = [completeUrlStr substringWithRange:NSMakeRange(0, completeUrlStr.length - 1)];
    
    return [NSURL URLWithString:completeUrlStr];
}

//prepares a body for POST METHOD
- (NSData *) bodyForPostMethod:(NSDictionary *)params
{
    NSString *body = @"";
    
    for (NSString *paramKey in [params allKeys])
    {
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", paramKey, params[paramKey]]];
    }
    
    body = [body substringWithRange:NSMakeRange(0, body.length - 1)];
    
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}


//adds Http Headers
- (void) addHttpHeaders:(NSDictionary *)headers toRequest:(NSMutableURLRequest *)request
{
    for (NSString *paramKey in [headers allKeys])
    {
        [request setValue:headers[paramKey] forHTTPHeaderField:paramKey];
    }
}

/* Prepares an URLRequest object */
- (NSMutableURLRequest *) prepareRequestForURL:(NSURL *)url httpMethod:(CBHTTPMethod)httpMethod requestParameters:(NSDictionary *)parameters httpHeaderFields:(NSDictionary *)httpHeaders timeoutInterval:(NSInteger)timeout
{
    NSData *httpMsgBody;

    if (httpMethod == CBHTTPMethodGet)
    {
        url = [self urlForGetMethod:url withQueryParameters:parameters];
    }
    else if (httpMethod == CBHTTPMethodPost)
    {
        httpMsgBody = [self bodyForPostMethod:parameters];
        NSMutableDictionary *headersCopy = [httpHeaders mutableCopy];
        [headersCopy setObject:[@(httpMsgBody.length) stringValue] forKey:@"Content-Length"];
        httpHeaders = [NSDictionary dictionaryWithDictionary:headersCopy];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    
    [self addHttpHeaders:httpHeaders toRequest:request];

    return request;
}

//execute API request
- (void) performRequest:(NSURL *)url requestMethod:(CBHTTPMethod)httpMethod requestParameters:(NSDictionary *)parameters httpHeaderFields:(NSDictionary *)httpHeaders timeoutInterval:(NSInteger)timeout httpCallback:(CBHttpClientCallback) callback
{
    NSMutableURLRequest *request;
    CBURLRequestImp __weak *weakSelf = self;
    
    request = [self prepareRequestForURL:url httpMethod:httpMethod requestParameters:parameters httpHeaderFields:httpHeaders timeoutInterval:timeout];
   
    self.clientCallback = callback;
    
    // Create a api request task.
    NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data,
                                                      NSURLResponse *httpResponse,
                                                      NSError *error) {
                                      NSInteger code = 0;
                                      NSDictionary *httpHeaders;
                                      
                                      if (httpResponse) httpHeaders =  [(NSHTTPURLResponse *)httpResponse allHeaderFields];
                                      if (!error) {
                                          code = (long)[(NSHTTPURLResponse *)httpResponse statusCode];
                                      }
                                      weakSelf.clientCallback(data, httpHeaders, code, error);
                                  }];
    // Start the task.
    [task resume];

}

@end
