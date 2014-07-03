//
//  RTSAddVectors.m
//  RadioTools
//
//  Created by Erik Larsen on 12/22/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import "RTSAddVectors.h"

@implementation RTSAddVectors

- (RTSComplexVector *)addComplex:(NSArray *)input
{
    return [super internalComplexOperation:input];
}

- (RTSFloatVector *)addFloat:(NSArray *)input
{
    return [super internalFloatOperation:input];
}

- (void)performOperationComplex:(RTSComplexVector *)A B:(RTSComplexVector *)B C:(RTSComplexVector *)C
{
    vDSP_zvadd(A.splitComplexRef, 1, B.splitComplexRef, 1, C.splitComplexRef, 1, self.sizeElements);
}

- (void)performOperationFloat:(RTSFloatVector *)A B:(RTSFloatVector *)B C:(RTSFloatVector *)C
{
    vDSP_vadd(A.vector, 1, B.vector, 1, C.vector, 1, self.sizeElements);
}

@end
