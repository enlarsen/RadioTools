//
//  RTSSubtractVectors.m
//  RadioTools
//
//  Created by Erik Larsen on 12/23/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import "RTSSubtractVectors.h"

@implementation RTSSubtractVectors

- (RTSComplexVector *)subtractComplex:(NSArray *)input
{
    return [super internalComplexOperation:input];
}

- (RTSFloatVector *)subtractFloat:(NSArray *)input
{
    return [super internalFloatOperation:input];
}

- (void)performOperationComplex:(RTSComplexVector *)A B:(RTSComplexVector *)B C:(RTSComplexVector *)C
{
    vDSP_zvsub(A.splitComplexRef, 1, B.splitComplexRef, 1, C.splitComplexRef, 1, self.sizeElements);
}

- (void)performOperationFloat:(RTSFloatVector *)A B:(RTSFloatVector *)B C:(RTSFloatVector *)C
{
    vDSP_vsub(A.vector, 1, B.vector, 1, C.vector, 1, self.sizeElements);
}

@end
