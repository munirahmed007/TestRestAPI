//
//  CBURLRequestProtocol.h
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <Foundation/Foundation.h>

//enumeration for HTTP method
typedef enum : NSUInteger {
    CBHTTPMethodGet,
    CBHTTPMethodPost,
} CBHTTPMethod;


//enumeration for HTTP response code.
typedef enum : NSUInteger {
    CBHTTPResponseCode_200 = 200,
    CBHTTPResponseCode_500 = 500,
    CBHTTPResponseCodeOthers,
} CBHTTPResponseCode;


//callback typedef
typedef void (^CBHttpClientCallback)(NSData *data, NSDictionary *responseHeaders, NSInteger responseCode, NSError *error);

@protocol CBURLRequestProtocol <NSObject>

- (void) performRequest:(NSURL *)url requestMethod:(CBHTTPMethod)httpMethod requestParameters:(NSDictionary *)parameters httpHeaderFields:(NSDictionary *)httpHeaders timeoutInterval:(NSInteger)timeout httpCallback:(CBHttpClientCallback) callback;

@end
