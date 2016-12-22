//
//  CBHTTPClientTests.m
//  TestAssignment
//
//  Created by Munir Ahmed on 22/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CBHttpClient.h"
#import "CBHttpServerController.h"
#import "CBHTTPClientDelegate.h"
#import "SimpleHttpServer.h"

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
@property SimpleHttpServer *server;
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

- (void) performAsyncOperationWithCallback:(void (^)())cb
{
    self.callback = cb;
    [self.client performSelector:@selector(sendRequest:) withObject:@{} afterDelay:1.5];
}

- (void) testClientHttp_timeout
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientHttp_500"];
    self.errorType = CBHTTPClient_noneError_Recv;
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.server = [SimpleHttpServer new];
        [self.server startServer];
    });
    
    CBHttpServerController *ctrl = [CBHttpServerController sharedController];
    ctrl.timeout = YES;
    self.expectedError = CBHTTPClient_Timeout_Recv;

    CBHTTPClientTests __weak *weakSelf = self;
    
    [self performAsyncOperationWithCallback:^{
        XCTAssertEqual(weakSelf.errorType, weakSelf.expectedError);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
 }

- (void) testClientHttp_500
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientHttp_500"];
    self.errorType = CBHTTPClient_noneError_Recv;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.server = [SimpleHttpServer new];
        [self.server startServer];
    });
    
    CBHttpServerController *ctrl = [CBHttpServerController sharedController];
    ctrl.timeout = NO;
    ctrl.statusCode = 500;
    self.expectedError = CBHTTPClient_500_Recv;
    CBHTTPClientTests __weak *weakSelf = self;
    
    [self performAsyncOperationWithCallback:^{
        XCTAssertEqual(weakSelf.errorType, weakSelf.expectedError);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void) testClientHttp_200
{
    self.errorType = CBHTTPClient_noneError_Recv;
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientHttp_200"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.server = [SimpleHttpServer new];
        [self.server startServer];
    });
    
    CBHttpServerController *ctrl = [CBHttpServerController sharedController];
    ctrl.timeout = NO;
    ctrl.statusCode = 200;
    self.expectedError = CBHTTPClient_200_Recv;
    CBHTTPClientTests __weak *weakSelf = self;
    
    [self performAsyncOperationWithCallback:^{
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

- (void) requestFailed:(CBHTTPClient *)client
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
