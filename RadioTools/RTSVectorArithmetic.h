//
//  RTSVectorArithmetic.h
//  RadioTools
//
//  Created by Erik Larsen on 12/23/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSComplexVector.h"
#import "RTSFloatVector.h"


@interface RTSVectorArithmetic : NSObject

@property (nonatomic) NSUInteger sizeElements;

- (void)performOperationComplex:(RTSComplexVector *)A
                                            B:(RTSComplexVector *)B
                                            C:(RTSComplexVector *)C;
- (void)performOperationFloat:(RTSFloatVector *)A
                                        B:(RTSFloatVector *)B
                                        C:(RTSFloatVector *)C;

- (RTSComplexVector *)internalComplexOperation:(NSArray *)input;
- (RTSFloatVector *)internalFloatOperation:(NSArray *)input;

@end
