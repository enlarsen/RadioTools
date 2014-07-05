//
//  RTSFMDemodulator.m
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

#import "RTSFMDemodulator.h"

@interface RTSFMDemodulator()

@property (nonatomic) float previousReal;
@property (nonatomic) float previousImaginary;
@property (nonatomic) DSPSplitComplex laggedInput;
@property (nonatomic, readonly) DSPSplitComplex *laggedInputRef;
@property (nonatomic) DSPSplitComplex temp;
@property (nonatomic, readonly) DSPSplitComplex *tempRef;
@property (nonatomic, strong) RTSFloatVector *output;
@property (nonatomic, readonly) NSUInteger sizeBytes;
@property (nonatomic) NSUInteger sizeElements;

@end

@implementation RTSFMDemodulator

- (id)init
{
    if(self = [super init])
    {
        self.previousReal = 0.0f;
        self.previousImaginary = 0.0f;
    }
    return self;
}

#pragma mark - Properties

- (DSPSplitComplex)laggedInput
{
    [self checkSplitComplex:&_laggedInput];
    return _laggedInput;
}

- (DSPSplitComplex *)laggedInputRef
{
    [self checkSplitComplex:&_laggedInput];
    return &_laggedInput;
}

- (DSPSplitComplex)temp
{
    [self checkSplitComplex:&_temp];
    return _temp;
}

- (DSPSplitComplex *)tempRef
{
    [self checkSplitComplex:&_temp];
    return &_temp;
}


- (void)checkSplitComplex:(DSPSplitComplex *)value
{
    if(!value->realp)
    {
        value->realp = malloc(self.sizeBytes);
    }
    if(!value->imagp)
    {
        value->imagp = malloc(self.sizeBytes);
    }
}

- (void)clearSplitComplex:(DSPSplitComplex)value
{
    value.realp = NULL;
    value.imagp = NULL;
}

- (RTSFloatVector *)output
{
    if(!_output)
    {
        _output = [[RTSFloatVector alloc]
                    initWithSizeElements:self.sizeElements ];
    }
    return _output;
}

- (void)setSizeElements:(NSUInteger)sizeElements
{
    if(_sizeElements != sizeElements)
    {
        _output = nil;
        [self clearSplitComplex:_temp];
        [self clearSplitComplex:_laggedInput];
        _sizeElements = sizeElements;
    }
}

- (NSUInteger)sizeBytes
{
    return self.sizeElements * sizeof(float);
}

- (RTSFloatVector *)demodulate:(RTSComplexVector *)input
{
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 2) | DBG_FUNC_START, 0, 0, 0, 0);
    self.sizeElements = input.sizeElements;

    self.laggedInput.realp[0] = self.previousReal;
    self.laggedInput.imagp[0] = self.previousImaginary;

    self.previousReal = input.realp[input.sizeElements - 1];
    self.previousImaginary = input.imagp[input.sizeElements - 1];

    memcpy(&self.laggedInput.realp[1], input.realp,
           (input.sizeElements - 1) * sizeof(float));
    memcpy(&self.laggedInput.imagp[1], input.imagp,
           (input.sizeElements - 1)* sizeof(float));

    vDSP_zvcmul(input.splitComplexRef, 1, self.laggedInputRef, 1,
                self.tempRef, 1, input.sizeElements);
    vDSP_zvphas(self.tempRef, 1, self.output.vector, 1, input.sizeElements);

    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 2) | DBG_FUNC_END, 0, 0, 0, 0);
    return self.output;

}

@end

