//
//  CBHttpServerController.h
//  TestAssignment
//
//  Created by Munir Ahmed on 21/12/2016.
//  Copyright © 2016 Upwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBHttpServerController : NSObject

@property NSInteger statusCode;
@property BOOL timeout;

+ (id) sharedController;

@end
