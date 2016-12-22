//
//  DummyHttpExecutor.h
//  TestAssignment
//
//  Created by Munir Ahmed on 22/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBURLRequestProtocol.h"


typedef enum : NSUInteger {
    CBHTTPOK,
    CBHTTPServerError,
    CBHTTPTimeout,
} CBReturnType;

@interface DummyHttpExecutor : NSObject<CBURLRequestProtocol>

- (void) setReturnHttpOK;
- (void) setReturnHttpInternalServerError;
- (void) setReturnHttpTimeout;

@end
