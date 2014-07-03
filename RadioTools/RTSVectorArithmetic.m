//
//  RTSVectorArithmetic.m
//  RadioTools
//
//  Created by Erik Larsen on 12/23/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

// Base class for multiplication, addition, and subtraction of vectors using
// vDSP

#import "RTSVectorArithmetic.h"

@interface RTSVectorArithmetic()

@property (nonatomic, strong) RTSFloatVector *resultFloat1;
@property (nonatomic, strong) RTSComplexVector *resultComplex1;
@property (nonatomic, strong) RTSFloatVector *resultFloat2;
@property (nonatomic, strong) RTSComplexVector *resultComplex2;

@end

@implementation RTSVectorArithmetic

#pragma mark - Abstract methods

- (void)performOperationComplex:(RTSComplexVector *)A
                                            B:(RTSComplexVector *)B
                                            C:(RTSComplexVector *)C
{
    [self doesNotRecognizeSelector:_cmd]; // Abstract
}

- (void)performOperationFloat:(RTSFloatVector *)A
                            B:(RTSFloatVector *)B
                            C:(RTSFloatVector *)C;
{
    [self doesNotRecognizeSelector:_cmd]; // Abstract
}

#pragma mark - Properties

- (void)setSizeElements:(NSUInteger)sizeElements
{
    if(_sizeElements != sizeElements)
    {
        // If the size changed, force all of the properties to be re-lazy-loaded.
        _resultFloat1 = nil;
        _resultFloat2 = nil;
        _resultComplex1 = nil;
        _resultComplex2 = nil;
        _sizeElements = sizeElements;
    }
}

- (RTSFloatVector *)resultFloat1
{
    if(!_resultFloat1)
    {
        _resultFloat1 = [[RTSFloatVector alloc] initWithSizeElements:self.sizeElements];
    }
    return _resultFloat1;
}

- (RTSFloatVector *)resultFloat2
{
    if(!_resultFloat2)
    {
        _resultFloat2 = [[RTSFloatVector alloc] initWithSizeElements:self.sizeElements];
    }
    return _resultFloat2;
}

- (RTSComplexVector *)resultComplex1
{
    if(!_resultComplex1)
    {
        _resultComplex1 = [[RTSComplexVector alloc] initWithSizeElements:self.sizeElements];
    }
    return _resultComplex1;

}

- (RTSComplexVector *)resultComplex2
{
    if(!_resultComplex2)
    {
        _resultComplex2 = [[RTSComplexVector alloc] initWithSizeElements:self.sizeElements];
    }
    return _resultComplex2;

}

// Multiply by shuffling pointers around to the various vectors rather than copying memory.
- (RTSComplexVector *)internalComplexOperation:(NSArray *)input
{
    RTSComplexVector *A, *B, *C;


    if([input count] < 2)
    {
        return nil;
    }
    self.sizeElements = ((RTSComplexVector *)input[0]).sizeElements;

    // TODO: Check the inputs

    A = (RTSComplexVector *)input[0];
    C = self.resultComplex1;

    for(int i = 1; i < [input count]; i++) // Start with the second element.
    {
        B = (RTSComplexVector *)input[i];

        [self performOperationComplex:A B:B C:C]; // perform vDSP operation defined by the subclass

        A = C;

        C = (C == self.resultComplex1 ? self.resultComplex2 : self.resultComplex1);

    }
    return A; // A was set to the last result from vDSP_zvmul
}

// TODO: consolidate this and the previous method.

- (RTSFloatVector *)internalFloatOperation:(NSArray *)input
{
    RTSFloatVector *A, *B, *C;

    if([input count] < 2)
    {
        return nil;
    }
    self.sizeElements = ((RTSFloatVector *)input[0]).sizeElements;

    // TODO: Check the inputs

    A = (RTSFloatVector *)input[0];
    C = self.resultFloat1;

    for(int i = 1; i < [input count]; i++) // Start with the second element.
    {
        B = (RTSFloatVector *)input[i];

        [self performOperationFloat:A B:B C:C]; // perform vDSP operation defined by the subclass

        A = C;

        C = (C == self.resultFloat1 ? self.resultFloat2 : self.resultFloat1);
        
    }
    return A; // A was set to the last result from vDSP_zvmul
}

@end
