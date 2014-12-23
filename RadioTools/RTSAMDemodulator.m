//
//  RTSAMDemodulator.m
//  RadioTools
//
//  Created by Erik Larsen on 12/15/14.
//  Copyright (c) 2013 Erik Larsen.
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

#import "RTSAMDemodulator.h"

@interface RTSAMDemodulator()

@property (nonatomic, strong) RTSFloatVector *output;
@property (nonatomic, readonly) NSUInteger sizeBytes;
@property (nonatomic) NSUInteger sizeElements;

@end

@implementation RTSAMDemodulator

- (id)init
{
    if(self = [super init])
    {
    }
    return self;
}

#pragma mark - Properties


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

//    vDSP_vdist(input.realp, 1, input.imagp, 1, self.output.vector, 1, input.sizeElements);
    vDSP_zvmags(input.splitComplexRef, 1, self.output.vector, 1, input.sizeElements);

    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 2) | DBG_FUNC_END, 0, 0, 0, 0);
    return self.output;

}

@end

