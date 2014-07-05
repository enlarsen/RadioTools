//
//  RTSDecimator.m
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <sys/syscall.h>
#include <sys/kdebug.h>

#import "RTSDecimator.h"

@interface RTSDecimator()

@property (nonatomic) int factor;
@property (nonatomic) float *filter;
@property (nonatomic) float filterValue;
@property (nonatomic, strong) RTSComplexVector *outputAsRTSComplexVector;
@property (nonatomic, strong) RTSFloatVector *outputAsRTSFloatVector;
@property (nonatomic) NSUInteger sizeElements;
@property (nonatomic, readonly) NSUInteger sizeBytes;

@end



@implementation RTSDecimator

- (id)init
{
    return nil;
}

- (id)initWithFactor:(int)factor
{
    if(self = [super init])
    {
        _factor = factor;
        _filterValue = 1.0f;
    }
    return self;
}

#pragma mark - Properties

- (float *)filter
{
    if(!_filter)
    {
        _filter = malloc(_factor * sizeof(float));
        vDSP_vfill(&_filterValue, _filter, 1, _factor);
    }
    return _filter;
}

- (DSPSplitComplex)outputSplitComplex
{
    return self.outputAsRTSComplexVector.splitComplex;
}

- (RTSComplexVector *)outputAsRTSComplexVector
{
    if(!_outputAsRTSComplexVector)
    {
        _outputAsRTSComplexVector = [[RTSComplexVector alloc]
                                     initWithSizeElements:self.sizeElements];
    }
    return _outputAsRTSComplexVector;
}

- (RTSFloatVector *)outputAsRTSFloatVector
{
    if(!_outputAsRTSFloatVector)
    {
        _outputAsRTSFloatVector = [[RTSFloatVector alloc]
                                   initWithSizeElements:self.sizeElements ];
    }
    return _outputAsRTSFloatVector;
}



- (void)setSizeElements:(NSUInteger)sizeElements
{
    if(_sizeElements != sizeElements)
    {
        _outputAsRTSComplexVector = nil;
        _outputAsRTSFloatVector = nil;
        _sizeElements = sizeElements;
    }
}

- (NSUInteger)sizeBytes
{
    return self.sizeElements * sizeof(float);
}


#pragma mark - Decimators

- (RTSComplexVector *)decimateComplex:(RTSComplexVector *)input
{
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 3) | DBG_FUNC_START, 0, 0, 0, 0);

    self.sizeElements = input.sizeElements / self.factor;

    vDSP_desamp(input.realp, self.factor, self.filter,
                self.outputAsRTSComplexVector.realp,
                self.sizeElements, self.factor);
    vDSP_desamp(input.imagp, self.factor, self.filter,
                self.outputAsRTSComplexVector.imagp,
                self.sizeElements, self.factor);

    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 3) | DBG_FUNC_END, 0, 0, 0, 0);

    return self.outputAsRTSComplexVector;
}

- (RTSFloatVector *)decimateFloat:(RTSFloatVector *)input
{
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 4) | DBG_FUNC_START, 0, 0, 0, 0);

    self.sizeElements = input.sizeElements / self.factor;

    vDSP_desamp(input.vector, self.factor, self.filter,
                self.outputAsRTSFloatVector.vector,
                self.sizeElements, self.factor);
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 4) | DBG_FUNC_END, 0, 0, 0, 0);

    return self.outputAsRTSFloatVector;
}

@end
