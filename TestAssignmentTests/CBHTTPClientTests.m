//
//  CBHTTPClientTests.m
//  TestAssignment
//
//  Created by Munir Ahmed on 22/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CBHttpClient.h"
#import "CBHTTPClientDelegate.h"
#import "DummyHttpExecutor.h"

typedef enum : NSUInteger {
    CBHTTPClient_200_Recv,
    CBHTTPClient_500_Recv,
    CBHTTPClient_Timeout_Recv,
    CBHTTPClient_OtherError_Recv,
    CBHTTPClient_noneError_Recv,
} CBHttpClientErrorTypes;

typedef void (^TestCallback)();

@interface CBHTTPClientTests : XCTestCase<CBHTTPClientDelegate>
@property CBHTTPClient *client;
@property CBHttpClientErrorTypes errorType;
@property CBHttpClientErrorTypes expectedError;
@property TestCallback callback;
@end

@implementation CBHTTPClientTests

- (void)setUp {
    [super setUp];
    self.client = [[CBHTTPClient new] initWithURL:[NSURL URLWithString:@"http://127.0.0.1:8080"] requestTimeout:10.0  retryCount:5 delegate:self];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
 }

- (void) performAsyncOperationWithExecutor:(id<CBURLRequestProtocol>)executer Callback:(void (^)())cb
{
    self.callback = cb;
    [self.client sendRequest:@{} withHttpExecutor:executer];
}

- (void) testClientHttp_error_others
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientHttp_error_Unknown"];
    self.errorType = CBHTTPClient_noneError_Recv;
    DummyHttpExecutor *execute = [DummyHttpExecutor new];
    [execute setReturnHttpOtherErrors];
    
    self.expectedError = CBHTTPClient_OtherError_Recv;
    
    CBHTTPClientTests __weak *weakSelf = self;
    
    [self performAsyncOperationWithExecutor:execute Callback:^{
        XCTAssertEqual(weakSelf.errorType, weakSelf.expectedError);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void) testClientHttp_timeout
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientHttp_timeout"];
    self.errorType = CBHTTPClient_noneError_Recv;
    DummyHttpExecutor *execute = [DummyHttpExecutor new];
    [execute setReturnHttpTimeout];
   
    self.expectedError = CBHTTPClient_Timeout_Recv;

    CBHTTPClientTests __weak *weakSelf = self;
    
    [self performAsyncOperationWithExecutor:execute Callback:^{
        XCTAssertEqual(weakSelf.errorType, weakSelf.expectedError);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
 }

- (void) testClientHttp_500
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientHttp_500"];
    self.errorType = CBHTTPClient_noneError_Recv;
    
    DummyHttpExecutor *execute = [DummyHttpExecutor new];
    [execute setReturnHttpInternalServerError];
    
    self.expectedError = CBHTTPClient_500_Recv;
    CBHTTPClientTests __weak *weakSelf = self;
    
    [self performAsyncOperationWithExecutor:execute Callback:^{
        XCTAssertEqual(weakSelf.errorType, weakSelf.expectedError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void) testClientHttp_200
{
    self.errorType = CBHTTPClient_noneError_Recv;
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientHttp_200"];

    DummyHttpExecutor *execute = [DummyHttpExecutor new];
    [execute setReturnHttpOK];
    
    self.expectedError = CBHTTPClient_200_Recv;
    CBHTTPClientTests __weak *weakSelf = self;
    
    [self performAsyncOperationWithExecutor:execute Callback:^{
        XCTAssertEqual(weakSelf.errorType, weakSelf.expectedError);
        [expectation fulfill];
    }];

 
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

#pragma -- CBClientDelegate --


- (void) requestOK:(NSData *)data
{
    self.errorType = CBHTTPClient_200_Recv;
    self.callback();
}

- (void) requestTryAgain:(CBHTTPClient *)client
{
    self.errorType = CBHTTPClient_500_Recv;
    self.callback();
}

- (void) requestFailed:(CBHTTPClient *)client error:(NSError *)error
{
    self.errorType = CBHTTPClient_OtherError_Recv;
    self.callback();
}

- (void) requestTimeout:(CBHTTPClient *)client
{
    self.errorType = CBHTTPClient_Timeout_Recv ;
    self.callback();
}


@end
