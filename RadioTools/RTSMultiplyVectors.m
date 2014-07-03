//
//  RTSMultiplyVectors.m
//  RadioTools
//
//  Created by Erik Larsen on 12/22/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import "RTSMultiplyVectors.h"


@implementation RTSMultiplyVectors

- (RTSComplexVector *)multiplyComplex:(NSArray *)input
{
    return [super internalComplexOperation:input];
}

- (RTSFloatVector *)multiplyFloat:(NSArray *)input
{
    return [super internalFloatOperation:input];
}

- (void)performOperationComplex:(RTSComplexVector *)A B:(RTSComplexVector *)B C:(RTSComplexVector *)C
{
    vDSP_zvmul(A.splitComplexRef, 1, B.splitComplexRef, 1, C.splitComplexRef, 1, self.sizeElements, 1);
}

- (void)performOperationFloat:(RTSFloatVector *)A B:(RTSFloatVector *)B C:(RTSFloatVector *)C
{
    vDSP_vmul(A.vector, 1, B.vector, 1, C.vector, 1, self.sizeElements);
}

@end
